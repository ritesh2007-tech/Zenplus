import 'package:flutter/material.dart';
import 'package:mindmat/Mood/mood_entry_model.dart';
import 'dart:math' as math;
import 'package:mindmat/db_helper/db_manager.dart' as db;

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({Key? key}) : super(key: key);

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  String? selectedMood;
  final TextEditingController _reflectionController = TextEditingController();

  final List<MoodOption> moodOptions = [
    MoodOption(
      emoji: '😊',
      label: 'Happy',
      color: Color(0xFF81C784),
      prompt: 'What made you smile today?',
    ),
    MoodOption(
      emoji: '😔',
      label: 'Sad',
      color: Color(0xFF90CAF9),
      prompt: 'Would you like to describe what made you feel sad today?',
    ),
    MoodOption(
      emoji: '😠',
      label: 'Angry',
      color: Color(0xFFEF5350),
      prompt: 'What triggered these feelings of anger?',
    ),
    MoodOption(
      emoji: '😨',
      label: 'Anxious',
      color: Color(0xFFFFB74D),
      prompt: 'What thoughts or situations are making you feel anxious?',
    ),
    MoodOption(
      emoji: '😐',
      label: 'Neutral',
      color: Color(0xFFB0BEC5),
      prompt: 'How has your day been so far?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'How are you feeling?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildMoodWheel(),
              SizedBox(height: 40),
              if (selectedMood != null) ...[
                _buildReflectionSection(),
                SizedBox(height: 40),
              ],
              _buildActionButtons(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodWheel() {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selectedMood != null
                          ? Color(0xFF4F46E5)
                          : Color(0xFF333333),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        selectedMood != null
                            ? Color(0xFF4F46E5).withOpacity(0.3)
                            : Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child:
                  selectedMood != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getSelectedMoodEmoji(),
                              style: TextStyle(fontSize: 36),
                            ),
                            SizedBox(height: 4),
                            Text(
                              selectedMood!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Center(
                        child: Text(
                          'Select\nMood',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ),
            ),
          ),
          ...moodOptions.asMap().entries.map((entry) {
            int index = entry.key;
            MoodOption mood = entry.value;
            double angle =
                (index * 2 * math.pi) / moodOptions.length - math.pi / 2;
            double radius = 120;
            double x = 150 + radius * math.cos(angle) - 30;
            double y = 150 + radius * math.sin(angle) - 30;
            bool isSelected = selectedMood == mood.label;

            return Positioned(
              left: x,
              top: y,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = mood.label;
                    _reflectionController.clear();
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? mood.color : Color(0xFF333333),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mood.color.withOpacity(isSelected ? 0.6 : 0.3),
                        blurRadius: isSelected ? 25 : 15,
                        spreadRadius: isSelected ? 3 : 1,
                      ),
                      BoxShadow(
                        color: mood.color.withOpacity(isSelected ? 0.4 : 0.2),
                        blurRadius: isSelected ? 15 : 8,
                        spreadRadius: isSelected ? 1 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(mood.emoji, style: TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReflectionSection() {
    MoodOption selectedMoodOption = moodOptions.firstWhere(
      (mood) => mood.label == selectedMood,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedMoodOption.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selectedMoodOption.color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedMoodOption.prompt,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _reflectionController,
            maxLines: 4,
            maxLength: 200,
            buildCounter: (
              BuildContext context, {
              required int currentLength,
              required int? maxLength,
              required bool isFocused,
            }) {
              return Text(
                '$currentLength / $maxLength',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              );
            },
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF333333)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: selectedMoodOption.color,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF333333)),
              ),
              filled: true,
              fillColor: Color(0xFF0F0F0F),
              contentPadding: EdgeInsets.all(16),
            ),
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    bool canSubmit = selectedMood != null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  canSubmit
                      ? [
                        BoxShadow(
                          color: Color(0xFF4F46E5).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ]
                      : [],
            ),
            child: ElevatedButton(
              onPressed: canSubmit ? _submitMoodEntry : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canSubmit ? Color(0xFF4F46E5) : Color(0xFF333333),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Entry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Skip for now',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getSelectedMoodEmoji() {
    return moodOptions.firstWhere((mood) => mood.label == selectedMood).emoji;
  }

  void _submitMoodEntry() async {
    if (selectedMood == null) return;

    final mood = moodOptions.firstWhere((m) => m.label == selectedMood!);
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    final newEntry = MoodEntry(
      emoji: mood.emoji,
      mood: mood.label,
      description: _reflectionController.text.trim(),
      date: dateOnly,
    );

    final existingEntry = await db.MoodDatabase.instance.getMoodByDate(
      dateOnly,
    );

    if (existingEntry != null) {
      await db.MoodDatabase.instance.updateMood(newEntry);
    } else {
      await db.MoodDatabase.instance.insertMood(newEntry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingEntry != null
              ? 'Mood entry updated successfully!'
              : 'Mood entry saved successfully!',
        ),
        backgroundColor: Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Navigator.pop(context);
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final String prompt;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.prompt,
  });
}
