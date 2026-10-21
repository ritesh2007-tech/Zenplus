import 'dart:convert';

class ModelNote {
  final int id;
  final String title;
  final String body;
  final String date;
  String? mood;
  List<Map<String, String>> images;

  ModelNote({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.mood,
    required this.images,
  });

  factory ModelNote.fromMap(Map<String, dynamic> map) {
    return ModelNote(
      id: map['id'],
      title: map['TITLE'],
      body: map['BODY'],
      date: map['DATE'],
      mood: map['MOOD'],
      images:
          map['IMAGES'] != null
              ? List<Map<String, String>>.from(
                (jsonDecode(map['IMAGES']) as List).map(
                  (item) => Map<String, String>.from(item),
                ),
              )
              : [],
    );
  }

  // Convert a ModelNote into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'TITLE': title,
      'BODY': body,
      'DATE': date,
      'MOOD': mood,
      'IMAGES': jsonEncode(images),
    };
  }
}
