import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mindmat/db_helper/db_manager.dart';

class ResultsHistoryScreen extends StatefulWidget {
  @override
  _ResultsHistoryScreenState createState() => _ResultsHistoryScreenState();
}

class _ResultsHistoryScreenState extends State<ResultsHistoryScreen> {
  List<Map<String, dynamic>> allResults = [];
  List<Map<String, dynamic>> filteredResults = [];

  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    loadResults();
  }

  Future<void> loadResults() async {
    final results = await AssessmentResultsDB.getAllResults();
    setState(() {
      allResults = results;
    });
    filterByMonthYear();
  }

  void filterByMonthYear() {
    setState(() {
      filteredResults =
          allResults.where((item) {
            final date = DateTime.parse(item['date']);
            return date.month == selectedMonth && date.year == selectedYear;
          }).toList();
    });
  }

  List<FlSpot> getChartData() {
    Map<int, double> dayToScore = {};

    for (var result in filteredResults) {
      final date = DateTime.parse(result['date']);
      final day = date.day;
      final score = result['score'] as double;
      dayToScore[day] = score;
    }

    int daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    List<FlSpot> spots = [];

    for (int i = 1; i <= daysInMonth; i++) {
      if (dayToScore.containsKey(i)) {
        spots.add(FlSpot(i.toDouble(), dayToScore[i]!));
      } else {
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }

    return spots;
  }

  List<DropdownMenuItem<int>> buildMonthItems() {
    return List.generate(12, (index) {
      return DropdownMenuItem(
        value: index + 1,
        child: Text(
          DateFormat.MMMM().format(DateTime(0, index + 1)),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    });
  }

  List<DropdownMenuItem<int>> buildYearItems() {
    final years =
        allResults.map((r) => DateTime.parse(r['date']).year).toSet().toList()
          ..sort();
    return years
        .map(
          (y) => DropdownMenuItem(
            value: y,
            child: Text(
              "$y",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        )
        .toList();
  }

  Widget _buildDropdownSelector(
    String label,
    int value,
    List<DropdownMenuItem<int>> items,
    Function(int?) onChanged,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          DropdownButton<int>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            underline: SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isTablet) {
    if (filteredResults.isEmpty) return SizedBox();

    final scores = filteredResults.map((r) => r['score'] as double).toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child:
          isTablet
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem("Average", avgScore, Colors.blue),
                  _buildStatItem("Highest", maxScore, Colors.green),
                  _buildStatItem("Lowest", minScore, Colors.orange),
                  _buildStatItem(
                    "Assessments",
                    filteredResults.length.toDouble(),
                    Colors.purple,
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Average", avgScore, Colors.blue),
                      _buildStatItem("Highest", maxScore, Colors.green),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Lowest", minScore, Colors.orange),
                      _buildStatItem(
                        "Assessments",
                        filteredResults.length.toDouble(),
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getStatIcon(label), color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label == "Assessments"
              ? value.toInt().toString()
              : "${value.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getStatIcon(String label) {
    switch (label) {
      case "Average":
        return Icons.trending_up;
      case "Highest":
        return Icons.arrow_upward;
      case "Lowest":
        return Icons.arrow_downward;
      case "Assessments":
        return Icons.assessment;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildChart(bool isTablet) {
    final graphSpots = getChartData();
    final daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    final chartWidth = daysInMonth * (isTablet ? 50.0 : 30.0); // dynamic width

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Assessment Progress",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: isTablet ? 280 : 220,
              child: LineChart(
                LineChartData(
                  minX: 0.5, // Start slightly before 1
                  maxX:
                      daysInMonth.toDouble() +
                      0.5, // End slightly after last day
                  minY: 0,
                  maxY: 105, // Increased from 100 to 105 to prevent clipping
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    verticalInterval: 1,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey[300]!, strokeWidth: 0.5),
                    getDrawingVerticalLine:
                        (value) =>
                            FlLine(color: Colors.grey[200]!, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30, // Added reserved size
                        getTitlesWidget: (value, _) {
                          if (value >= 1 &&
                              value <= daysInMonth &&
                              value == value.toInt()) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) {
                          // Only show values that are multiples of 20 and within 0-100
                          if (value >= 0 && value <= 100 && value % 20 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: graphSpots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.indigo[600]!],
                      ),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue[400]!.withOpacity(0.3),
                            Colors.indigo[600]!.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 2,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Colors.indigo[600]!,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(bool isTablet) {
    if (filteredResults.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No assessments this month",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Start taking assessments to track your progress",
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Assessment History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              itemCount: filteredResults.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final item = filteredResults[index];
                final date = DateFormat.yMMMd().format(
                  DateTime.parse(item['date']),
                );
                final score = item['score'] as double;

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getScoreColor(score).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getScoreIcon(score),
                          color: _getScoreColor(score),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _getScoreDescription(score),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${score.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(score),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    if (score >= 40) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return "Excellent mental health";
    if (score >= 60) return "Good mental health";
    if (score >= 40) return "Fair mental health";
    return "Needs attention";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Mental Health Insights",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            // Date selectors
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child:
                  isTablet
                      ? Row(
                        children: [
                          Expanded(
                            child: _buildDropdownSelector(
                              "MONTH",
                              selectedMonth,
                              buildMonthItems(),
                              (value) {
                                setState(() {
                                  selectedMonth = value!;
                                  filterByMonthYear();
                                });
                              },
                              isTablet,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownSelector(
                              "YEAR",
                              selectedYear,
                              buildYearItems(),
                              (value) {
                                setState(() {
                                  selectedYear = value!;
                                  filterByMonthYear();
                                });
                              },
                              isTablet,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          _buildDropdownSelector(
                            "MONTH",
                            selectedMonth,
                            buildMonthItems(),
                            (value) {
                              setState(() {
                                selectedMonth = value!;
                                filterByMonthYear();
                              });
                            },
                            isTablet,
                          ),
                          SizedBox(height: 16),
                          _buildDropdownSelector(
                            "YEAR",
                            selectedYear,
                            buildYearItems(),
                            (value) {
                              setState(() {
                                selectedYear = value!;
                                filterByMonthYear();
                              });
                            },
                            isTablet,
                          ),
                        ],
                      ),
            ),

            SizedBox(height: 24),

            // Statistics cards
            _buildStatsCards(isTablet),

            SizedBox(height: 24),

            // Chart
            _buildChart(isTablet),

            SizedBox(height: 24),

            // Results list
            SizedBox(
              height: isTablet ? 400 : 350,
              child: _buildResultsList(isTablet),
            ),
          ],
        ),
      ),
    );
  }
}
