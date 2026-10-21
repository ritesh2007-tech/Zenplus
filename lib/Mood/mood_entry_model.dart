class MoodEntry {
  final int? id;
  final String emoji;
  final String mood;
  final String description;
  final DateTime date;

  MoodEntry({
    this.id,
    required this.emoji,
    required this.mood,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'emoji': emoji,
      'mood': mood,
      'description': description,
      'date': date.toIso8601String(),
    };
    if (includeId && id != null) {
      map['id'] = id as String; // ✅ Do NOT use .toString() here
    }
    return map;
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?, // ✅ explicitly cast
      emoji: map['emoji'],
      mood: map['mood'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
