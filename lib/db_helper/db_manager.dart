import 'dart:io';
import 'package:mindmat/Mood/mood_entry_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mindmat/Journal/Model_Note.dart';
import 'dart:convert';

/// ------------------------------------Journal Entry Manager---------------------------------------------------------------------------

class DBHandler {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'flutterappdatabase.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE JOURNAL(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            TITLE TEXT,
            BODY TEXT,
            DATE TEXT,
            MOOD TEXT,
            IMAGES TEXT
          )''');
      },
    );

    return _database!;
  }

  /// ✅ Insert a new journal entry with optional image list
  Future<void> insertData(
    String title,
    String body,
    String date,
    String mood,
    List<Map<String, String>> images,
  ) async {
    final db = await database;
    await db!.insert("JOURNAL", {
      'TITLE': title,
      'BODY': body,
      'DATE': date,
      'MOOD': mood,
      'IMAGES': jsonEncode(images), // store image+description list
    });
  }

  /// ✅ Read all journal entries with image decoding
  Future<List<ModelNote>> readData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query("JOURNAL");
    return maps.map((map) => ModelNote.fromMap(map)).toList();
  }

  /// ✅ Delete a journal by ID
  Future<void> deleteData(num id) async {
    final db = await database;
    await db!.delete("JOURNAL", where: 'id = ?', whereArgs: [id]);
  }

  /// ✅ Update a journal entry (including images)
  Future<int> updateData(ModelNote note) async {
    final db = await database;
    return await db!.update(
      'JOURNAL',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
}

///-------------------------------Mood Entry Manager------------------------------------------------------------------------------------

class MoodDatabase {
  static final MoodDatabase instance = MoodDatabase._init();
  static Database? _database;

  MoodDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moods.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emoji TEXT NOT NULL,
        mood TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<MoodEntry?> getMoodByDate(DateTime date) async {
    final db = await instance.database;
    final result = await db.query(
      'moods',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return MoodEntry.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> insertMood(MoodEntry entry) async {
    final db = await instance.database;
    return await db.insert('moods', entry.toMap(includeId: false));
  }

  Future<int> updateMood(MoodEntry entry) async {
    final db = await instance.database;
    return await db.update(
      'moods',
      entry.toMap(includeId: false),
      where: 'date = ?',
      whereArgs: [entry.date.toIso8601String()],
    );
  }

  Future<List<MoodEntry>> getAllMoods() async {
    final db = await instance.database;
    final result = await db.query('moods', orderBy: 'date DESC');
    return result.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

/// ------------------------------------------------------------------------------------------------------------------------------------
class AssessmentResultsDB {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'mental_health.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            score REAL,
            mood REAL,
            sleep REAL,
            anxiety REAL,
            motivation REAL,
            focus REAL
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<void> saveOrUpdateResult({
    required double score,
    required Map<String, double> fieldPercentages,
  }) async {
    final db = await getDatabase();
    String today = DateTime.now().toIso8601String().split('T').first;

    // Check if entry exists for today
    final result = await db.query(
      'results',
      where: "date LIKE ?",
      whereArgs: ['$today%'],
    );

    Map<String, dynamic> entry = {
      'date': DateTime.now().toIso8601String(),
      'score': score,
      'mood': fieldPercentages['Mood'],
      'sleep': fieldPercentages['Sleep'],
      'anxiety': fieldPercentages['Anxiety'],
      'motivation': fieldPercentages['Motivation'],
      'focus': fieldPercentages['Focus'],
    };

    if (result.isNotEmpty) {
      await db.update(
        'results',
        entry,
        where: "id = ?",
        whereArgs: [result.first['id']],
      );
    } else {
      await db.insert('results', entry);
    }
  }

  static Future<List<Map<String, dynamic>>> getAllResults() async {
    final db = await getDatabase();
    return await db.query('results', orderBy: 'date DESC');
  }
}

/// ----------------------------------Quote----------------------------
class QuoteDB {
  static Database? _db;

  static Future<void> initDB() async {
    if (_db != null) return;

    final path = join(await getDatabasesPath(), 'quote.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE quote (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT
          )
        ''');

        // Insert default empty quote
        await db.insert('quote', {'text': ''});
      },
    );
  }

  static Future<String> getQuote() async {
    await initDB();
    final result = await _db!.query('quote', limit: 1);
    return result.isNotEmpty ? result.first['text'] as String : '';
  }

  static Future<void> updateQuote(String text) async {
    await initDB();
    await _db!.update('quote', {'text': text}, where: 'id = 1');
  }
}
