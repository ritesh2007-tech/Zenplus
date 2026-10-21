// Add this to your pubspec.yaml dependencies:
// dependencies:
//   flutter:
//     sdk: flutter
//   fl_chart: ^0.68.0

// assessment_screen.dart
import 'package:flutter/material.dart';
import 'package:mindmat/db_helper/db_manager.dart';
import 'responsive.dart';
import 'package:fl_chart/fl_chart.dart';

class AssessmentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int currentQuestionIndex = 0;
  String? selectedLabel;

  final ScrollController _scrollController = ScrollController();

  final Map<String, List<String>> questionBank = {
    "Mood": [
      "I felt positive when using social media today.",
      "I smiled genuinely today.",
      "I felt happy without any specific reason.",
      "I laughed at something funny today.",
      "I felt good about myself today.",
      "I had a positive interaction with someone today.",
      "I felt grateful for something in my life today.",
      "I enjoyed a moment of peace today.",
      "I felt confident about myself today.",
      "I felt energetic and upbeat today.",
    ],
    "Sleep": [
      "I went to bed on time last night.",
      "I woke up feeling refreshed today.",
      "I slept for at least 7 hours last night.",
      "I followed a consistent sleep schedule recently.",
      "I felt well-rested when I woke up today.",
      "I avoided screens before bedtime last night.",
      "I fell asleep easily last night.",
      "I slept through the night without waking up.",
      "I felt naturally tired at bedtime yesterday.",
      "I woke up at my planned time today.",
    ],
    "Anxiety": [
      "I felt calm when checking my phone today.",
      "I handled stressful situations well today.",
      "I felt relaxed about upcoming events.",
      "I approached conversations with confidence today.",
      "I managed my responsibilities without feeling overwhelmed.",
      "I felt physically relaxed today.",
      "I felt optimistic about the future today.",
      "I trusted my own judgment today.",
      "I easily found time to relax today.",
      "I had clear, calm thoughts today.",
    ],
    "Motivation": [
      "I felt excited to start my day.",
      "I completed tasks on my to-do list today.",
      "I started important tasks without hesitation.",
      "I accomplished what I planned for today.",
      "I felt energized after completing tasks.",
      "I found internal motivation to do things today.",
      "I persisted through challenging tasks today.",
      "I took initiative on something I care about.",
      "I felt proud of what I accomplished today.",
      "I stayed consistent with my goals today.",
    ],
    "Focus": [
      "I stayed focused while working today.",
      "I completed tasks without losing concentration.",
      "I avoided distractions during important work.",
      "I maintained deep focus for extended periods.",
      "I was fully present in conversations today.",
      "I stayed productive while multitasking.",
      "I remained alert during important moments.",
      "I stuck to my planned schedule today.",
      "I followed through on my daily plan.",
      "I easily refocused after brief interruptions.",
    ],
  };

  late final List<MapEntry<String, String>> finalQuestions;

  final Map<String, Color> responseMap = {
    "Often": Color(0xFFDCEDC8),
    "Likely": Color(0xFFE8F5E9),
    "Sometimes": Color(0xFFFFF9C4),
    "Rarely": Color(0xFFFFE0B2),
    "Never": Color(0xFFFFCDD2),
  };

  // Scoring system: Higher scores mean better mental health
  final Map<String, int> scoreMap = {
    "Often": 5,
    "Likely": 4,
    "Sometimes": 3,
    "Rarely": 2,
    "Never": 1,
  };

  final Map<int, String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();

    // Select 2 random questions from each field
    List<MapEntry<String, String>> tempList = [];
    questionBank.forEach((field, questions) {
      questions.shuffle();
      tempList.addAll(questions.take(2).map((q) => MapEntry(field, q)));
    });

    tempList.shuffle(); // Shuffle the final list of 10 questions
    finalQuestions = tempList;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  // Calculate results and navigate to results screen
  void _calculateAndShowResults() {
    // Group answers by field
    Map<String, List<String>> fieldAnswers = {};

    for (int i = 0; i < finalQuestions.length; i++) {
      String field = finalQuestions[i].key;
      String answer = selectedAnswers[i] ?? "Never";

      if (!fieldAnswers.containsKey(field)) {
        fieldAnswers[field] = [];
      }
      fieldAnswers[field]!.add(answer);
    }

    // Calculate field scores and percentages
    Map<String, double> fieldPercentages = {};
    Map<String, int> fieldScores = {};
    int totalScore = 0;
    int totalQuestions = finalQuestions.length;

    fieldAnswers.forEach((field, answers) {
      int fieldTotal = 0;
      for (String answer in answers) {
        fieldTotal += scoreMap[answer] ?? 5;
      }

      fieldScores[field] = fieldTotal;
      totalScore += fieldTotal;

      // Convert to percentage (higher score = better mental health)
      // Max possible score per question is 5, so for 2 questions max is 10
      double maxPossible = answers.length * 5.0;
      double wellbeingLevel = (fieldTotal / maxPossible) * 100;
      fieldPercentages[field] = wellbeingLevel;
    });

    // Calculate overall mental health score (0-100, higher is better)
    double maxTotalScore = totalQuestions * 5.0;
    double mentalHealthScore = (totalScore / maxTotalScore) * 100;

    // Navigate to results screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultsScreen(
              fieldPercentages: fieldPercentages,
              mentalHealthScore: mentalHealthScore,
              selectedAnswers: selectedAnswers,
              finalQuestions: finalQuestions,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = Responsive.getResponsiveFontSize(context, 18, 30, 28);
    double padding = Responsive.responsivePadding(context, 16, 30, 32);
    double spacing = Responsive.responsiveSpacing(context, 12, 30, 24);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerWidth =
        Responsive.isMobile(context) ? screenWidth * 0.8 : screenWidth * 0.9;

    double containerHeight =
        Responsive.isMobile(context) ? screenHeight * 0.25 : screenHeight * 0.2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cancel icon
              Padding(
                padding: EdgeInsets.only(top: spacing + 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.cancel),
                ),
              ),

              SizedBox(height: spacing * 2),

              // Question card
              Center(
                child: Container(
                  width: (containerWidth * 0.95) + 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: spacing,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1} of ${finalQuestions.length}",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colors.grey,
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            14,
                            20,
                            18,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        finalQuestions[currentQuestionIndex].key, // Field name
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        finalQuestions[currentQuestionIndex].value, // Question
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSize + 2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: spacing * 2),

              // Option buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                    responseMap.entries.map((entry) {
                      String label = entry.key;
                      Color color = entry.value;
                      bool isSelected = selectedLabel == label;

                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLabel = label;
                                selectedAnswers[currentQuestionIndex] = label;
                              });
                              scrollToBottom();
                            },
                            child: Container(
                              width: (containerWidth * 0.95) + 30,
                              height: containerHeight * 0.3,
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing,
                                vertical: spacing * 0.8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: Responsive.getResponsiveFontSize(
                                      context,
                                      14,
                                      20,
                                      18,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              // Navigation buttons
              if (selectedLabel != null) ...[
                SizedBox(height: spacing * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    TextButton(
                      onPressed: () {
                        if (currentQuestionIndex > 0) {
                          setState(() {
                            currentQuestionIndex--;
                            selectedLabel =
                                selectedAnswers[currentQuestionIndex];
                          });
                          _scrollController.animateTo(
                            0,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Back",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ),

                    // Continue button
                    TextButton(
                      onPressed: () {
                        if (currentQuestionIndex < finalQuestions.length - 1) {
                          setState(() {
                            currentQuestionIndex++;
                            selectedLabel =
                                selectedAnswers[currentQuestionIndex];
                          });
                          _scrollController.animateTo(
                            0,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        } else {
                          // Calculate results and show results screen
                          _calculateAndShowResults();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        currentQuestionIndex == finalQuestions.length - 1
                            ? "Finish"
                            : "Continue",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final Map<String, double> fieldPercentages;
  final double mentalHealthScore;
  final Map<int, String> selectedAnswers;
  final List<MapEntry<String, String>> finalQuestions;

  const ResultsScreen({
    Key? key,
    required this.fieldPercentages,
    required this.mentalHealthScore,
    required this.selectedAnswers,
    required this.finalQuestions,
  }) : super(key: key);

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.lightGreen;
    if (percentage >= 40) return Colors.yellow[700]!;
    if (percentage >= 20) return Colors.orange;
    return Colors.red;
  }

  String _getMentalHealthDescription(double score) {
    if (score >= 80) return "Excellent mental well-being!";
    if (score >= 65) return "Good mental health with minor concerns";
    if (score >= 50) return "Moderate mental health - consider some changes";
    if (score >= 35) return "Below average - recommend seeking support";
    return "Low mental health score - please consider professional help";
  }

  List<String> _getRecommendations() {
    List<String> recommendations = [];

    fieldPercentages.forEach((field, percentage) {
      if (percentage < 40) {
        switch (field) {
          case "Mood":
            recommendations.add("🌈 Try mood tracking and practice gratitude.");
            break;
          case "Sleep":
            recommendations.add("🛌 Maintain a consistent sleep schedule.");
            break;
          case "Anxiety":
            recommendations.add(
              "🧘 Practice breathing exercises & mindfulness.",
            );
            break;
          case "Motivation":
            recommendations.add("🏁 Set small goals and celebrate wins.");
            break;
          case "Focus":
            recommendations.add("📵 Avoid distractions using time blocks.");
            break;
        }
      }
    });

    if (recommendations.isEmpty) {
      recommendations.add("🎉 Great job! Keep up the positive habits!");
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    double padding = Responsive.responsivePadding(context, 16, 30, 32);
    double spacing = Responsive.responsiveSpacing(context, 12, 30, 24);

    List<Color> chartColors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.deepPurpleAccent,
      Colors.pinkAccent,
    ];

    List<PieChartSectionData> pieChartSections = [];
    int colorIndex = 0;

    fieldPercentages.forEach((field, percentage) {
      pieChartSections.add(
        PieChartSectionData(
          color: chartColors[colorIndex % chartColors.length],
          value: percentage,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 55,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: "Poppins",
          ),
        ),
      );
      colorIndex++;
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Assessment Summary",
          style: TextStyle(fontFamily: "Poppins"),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Overall Score Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.greenAccent.shade200,
                    Colors.lightGreenAccent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.green.shade100, blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Mental Health Score",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    "${mentalHealthScore.toStringAsFixed(1)}/100",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    _getMentalHealthDescription(mentalHealthScore),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing * 2),

            // 📊 Pie Chart
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
                ],
              ),
              padding: EdgeInsets.all(spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Wellbeing Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  SizedBox(height: spacing),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Wrap(
                    spacing: 12,
                    children:
                        fieldPercentages.keys.map((field) {
                          int index = fieldPercentages.keys.toList().indexOf(
                            field,
                          );
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor:
                                    chartColors[index % chartColors.length],
                              ),
                              SizedBox(width: 6),
                              Text(
                                field,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing * 2),

            // 🧠 Field Cards
            Text(
              "Category Scores",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: spacing),
            ...fieldPercentages.entries.map((entry) {
              String field = entry.key;
              double percent = entry.value;
              Color color = _getColorForPercentage(percent);
              return Container(
                margin: EdgeInsets.only(bottom: spacing),
                padding: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 1.5),
                  color: color.withOpacity(0.07),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      field,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      "${percent.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: spacing * 2),

            // 💡 Recommendations
            Text(
              "Recommendations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: spacing),
            ..._getRecommendations().map((tip) {
              return Container(
                margin: EdgeInsets.only(bottom: spacing),
                padding: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.indigo),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: spacing * 2),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => AssessmentScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Retake",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      await AssessmentResultsDB.saveOrUpdateResult(
                        score: mentalHealthScore,
                        fieldPercentages: fieldPercentages,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Results saved!"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Pop to root (main screen)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },

                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.green),
                      ),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
