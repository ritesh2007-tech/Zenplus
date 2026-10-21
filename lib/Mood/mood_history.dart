import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mindmat/db_helper/db_manager.dart' as db;
import 'package:mindmat/Mood/mood_entry_model.dart';

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  late int selectedMonth;
  late int selectedYear;

  // Fixed mood order from best to worst
  final List<String> emojiOrder = ['😊', '😐', '😨', '😔', '😠'];
  final Map<String, int> emojiScore = {
    '😊': 5, // Happy (top)
    '😐': 4, // Neutral
    '😨': 3, // Anxious
    '😔': 2, // Sad
    '😠': 1, // Angry (bottom)
  };

  @override
  void initState() {
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mood Insights',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 18 : 15,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<MoodEntry>>(
        future: db.MoodDatabase.instance.getAllMoods(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.deepPurple[300],
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading mood data...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final allMoods = snapshot.data!;
          final filtered =
              allMoods
                  .where(
                    (m) =>
                        m.date.month == selectedMonth &&
                        m.date.year == selectedYear,
                  )
                  .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              children: [
                _buildMonthDropdown(allMoods, isTablet),
                const SizedBox(height: 24),
                if (filtered.isNotEmpty) ...[
                  _buildStatsCards(filtered, isTablet),
                  const SizedBox(height: 24),
                  _buildChartsSection(filtered, isTablet),
                  const SizedBox(height: 24),
                ] else
                  _buildEmptyState(isTablet),
                _buildMoodList(filtered, isTablet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthDropdown(List<MoodEntry> allMoods, bool isTablet) {
    final months =
        allMoods
            .map((e) => DateTime(e.date.year, e.date.month))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT PERIOD',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DateTime>(
            dropdownColor: const Color(0xFF2A2A2A),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.deepPurple.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isTablet ? 16 : 12,
              ),
            ),
            value:
                months.contains(DateTime(selectedYear, selectedMonth))
                    ? DateTime(selectedYear, selectedMonth)
                    : (months.isNotEmpty ? months.first : null),
            items:
                months.map((dt) {
                  final label = DateFormat.yMMM().format(dt);
                  return DropdownMenuItem(
                    value: dt,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (dt) {
              if (dt != null) {
                setState(() {
                  selectedMonth = dt.month;
                  selectedYear = dt.year;
                });
              }
            },
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.deepPurple[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<MoodEntry> moods, bool isTablet) {
    final moodStats = _calculateMoodStats(moods);
    final totalDays = DateUtils.getDaysInMonth(selectedYear, selectedMonth);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple[800]!.withOpacity(0.3),
            Colors.deepPurple[600]!.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.deepPurple[300],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Monthly Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isTablet
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total Entries',
                    moods.length,
                    Icons.event_note,
                  ),
                  _buildStatCard(
                    'Days Tracked',
                    '${moods.length}/$totalDays',
                    Icons.calendar_today,
                  ),
                  _buildStatCard(
                    'Most Common',
                    moodStats['mostCommon'] ?? 'N/A',
                    Icons.trending_up,
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total Entries',
                        moods.length,
                        Icons.event_note,
                      ),
                      _buildStatCard(
                        'Days Tracked',
                        '${moods.length}/$totalDays',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    'Most Common',
                    moodStats['mostCommon'] ?? 'N/A',
                    Icons.trending_up,
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, dynamic value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.deepPurple[300], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(List<MoodEntry> moods, bool isTablet) {
    return isTablet
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildLineGraph(moods, isTablet)),
            const SizedBox(width: 16),
            Expanded(flex: 1, child: _buildBarGraph(moods, isTablet)),
          ],
        )
        : Column(
          children: [
            _buildLineGraph(moods, isTablet),
            const SizedBox(height: 16),
            _buildBarGraph(moods, isTablet),
          ],
        );
  }

  Widget _buildLineGraph(List<MoodEntry> moods, bool isTablet) {
    final spots =
        moods.map((mood) {
          double x = mood.date.day.toDouble();
          double y = emojiScore[mood.emoji]?.toDouble() ?? 3;
          return FlSpot(x, y);
        }).toList();

    return Container(
      height: isTablet ? 350 : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Progression',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0.5,
                maxY: 5.5,
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval: 5,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Only show emojis for integer values that exist in our mapping
                        int intValue = value.toInt();
                        if (value == intValue.toDouble() &&
                            emojiScore.containsValue(intValue)) {
                          // Convert score back to emoji (reverse lookup)
                          String? emoji;
                          for (var entry in emojiScore.entries) {
                            if (entry.value == intValue) {
                              emoji = entry.key;
                              break;
                            }
                          }
                          return emoji != null
                              ? Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  emoji,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        return const SizedBox.shrink();
                      },
                      interval: 1,
                      reservedSize: 35,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: isTablet ? 2 : 5,
                      getTitlesWidget:
                          (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isTablet ? 12 : 10,
                              ),
                            ),
                          ),
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple[400]!,
                        Colors.deepPurple[600]!,
                      ],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter:
                          (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.deepPurple[400]!,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple[400]!.withOpacity(0.3),
                          Colors.deepPurple[600]!.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarGraph(List<MoodEntry> moods, bool isTablet) {
    final Map<String, int> moodCount = {for (var e in emojiOrder) e: 0};
    for (var mood in moods) {
      if (moodCount.containsKey(mood.emoji)) {
        moodCount[mood.emoji] = moodCount[mood.emoji]! + 1;
      }
    }

    final totalMoods = moods.length;
    final List<BarChartGroupData> bars = [];

    for (int i = 0; i < emojiOrder.length; i++) {
      final emoji = emojiOrder[i];
      final count = moodCount[emoji] ?? 0;

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              width: isTablet ? 28 : 24,
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [Colors.deepPurple[400]!, Colors.deepPurple[600]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: isTablet ? 350 : 280,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: bars,
                groupsSpace: isTablet ? 20 : 16,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: moods.length > 10 ? 5 : 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isTablet ? 50 : 45,
                      interval: moods.length > 10 ? 5 : 2,
                      getTitlesWidget: (value, meta) {
                        if (totalMoods == 0) return const SizedBox.shrink();

                        final percentage = ((value / totalMoods) * 100).round();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${value.toInt()} (${percentage}%)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 10 : 8,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: isTablet ? 40 : 35,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        return index >= 0 && index < emojiOrder.length
                            ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                emojiOrder[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 20 : 18,
                                ),
                              ),
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 60 : 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mood_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No mood entries this month',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your daily mood to see insights here',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodList(List<MoodEntry> moods, bool isTablet) {
    if (moods.isEmpty) {
      return const SizedBox.shrink();
    }

    moods.sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.deepPurple[300], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Mood Timeline',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: isTablet ? 400 : 350,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: moods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mood = moods[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (index < moods.length - 1)
                          Container(
                            width: 2,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple[400]!.withOpacity(0.6),
                                  Colors.deepPurple[400]!.withOpacity(0.2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  mood.emoji,
                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    mood.mood,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('EEE, dd MMM yyyy').format(mood.date),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (mood.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                mood.description,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isTablet ? 15 : 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateMoodStats(List<MoodEntry> moods) {
    if (moods.isEmpty) return {'mostCommon': 'N/A'};

    final Map<String, int> moodCounts = {};
    for (var mood in moods) {
      moodCounts[mood.emoji] = (moodCounts[mood.emoji] ?? 0) + 1;
    }

    final mostCommon =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {'mostCommon': mostCommon};
  }
}
