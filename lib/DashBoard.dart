import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindmat/Activities/drawing_screen.dart';
import 'package:mindmat/Journal/Journal_Screen.dart';
import 'package:mindmat/Mood/mood_history.dart';
import 'package:mindmat/assessment.dart';
import 'package:mindmat/Music/Music_Screen.dart';
import 'package:mindmat/Mood/mood_entry.dart';
import 'package:mindmat/game.dart';
import 'package:mindmat/progress.dart';
import 'package:mindmat/responsive.dart';
import 'package:intl/intl.dart';
import 'package:mindmat/soundtherapy.dart';
import 'package:mindmat/db_helper/db_manager.dart';

class MentalHealthDashboard extends StatefulWidget {
  final String userName;

  const MentalHealthDashboard({Key? key, required this.userName})
    : super(key: key);

  @override
  _MentalHealthDashboardState createState() => _MentalHealthDashboardState();
}

class _MentalHealthDashboardState extends State<MentalHealthDashboard> {
  String savedQuote = '';

  @override
  void initState() {
    super.initState();
    _loadSavedQuote();
  }

  void _loadSavedQuote() async {
    String quote = await QuoteDB.getQuote();
    setState(() {
      savedQuote = quote;
    });
  }

  void _showQuoteDialog(BuildContext context) {
    TextEditingController quoteController = TextEditingController(
      text: savedQuote,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder:
                    (context, setState) => SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Save Quote',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: quoteController,
                            maxLines: 3,
                            maxLength: 100,
                            buildCounter: (
                              BuildContext context, {
                              required int currentLength,
                              required bool isFocused,
                              required int? maxLength,
                            }) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$currentLength / $maxLength',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        currentLength > 100
                                            ? Colors.red
                                            : Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: "Enter your quote",
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  String quote = quoteController.text.trim();
                                  if (quote.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Quote cannot be empty"),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  } else if (quote.length > 100) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Quote cannot exceed 100 characters",
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  } else {
                                    await QuoteDB.updateQuote(quote);
                                    _loadSavedQuote();
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  shadowColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.4),
                                  elevation: 10,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                ),
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Get sky gradient based on time
  LinearGradient _getSkyGradient() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      // Morning - Light blue to white
      return LinearGradient(
        colors: [
          Color.fromARGB(255, 104, 167, 193),
          Color.fromARGB(255, 196, 238, 255),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 12 && hour < 17) {
      // Afternoon - Bright blue
      return LinearGradient(
        colors: [
          Color.fromARGB(255, 249, 249, 137),
          Color.fromARGB(255, 34, 65, 101),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (hour >= 17 && hour < 19) {
      // Evening - Orange to purple
      return LinearGradient(
        colors: [Color.fromARGB(255, 222, 181, 101), Color(0xFF16213E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // Night - Dark blue to black
      return LinearGradient(
        colors: [
          Color.fromARGB(255, 10, 10, 26),
          Color.fromARGB(255, 42, 42, 75),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // Get celestial body (sun/moon) based on time
  Widget _getCelestialBody() {
    final hour = DateTime.now().hour;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    // Responsive sizing
    final double sunSize = isTablet ? 80 : 60;
    final double moonSize = isTablet ? 70 : 50;
    final double sunGlow1 = isTablet ? 30 : 20;
    final double sunGlow2 = isTablet ? 60 : 40;
    final double sunSpread1 = isTablet ? 8 : 5;
    final double sunSpread2 = isTablet ? 15 : 10;
    final double moonGlow = isTablet ? 25 : 15;
    final double moonSpread = isTablet ? 5 : 3;

    if (hour >= 6 && hour < 18) {
      // Sun during day
      Color sunColor = hour >= 17 ? Colors.orange : Colors.yellow;

      return Container(
        width: sunSize,
        height: sunSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: sunColor,
          boxShadow: [
            BoxShadow(
              color: sunColor.withOpacity(0.6),
              blurRadius: sunGlow1,
              spreadRadius: sunSpread1,
            ),
            BoxShadow(
              color: sunColor.withOpacity(0.3),
              blurRadius: sunGlow2,
              spreadRadius: sunSpread2,
            ),
          ],
        ),
      );
    } else {
      // Moon during night
      return Container(
        width: moonSize,
        height: moonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!.withOpacity(0.5),
              blurRadius: moonGlow,
              spreadRadius: moonSpread,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Moon craters (dark spots) - responsive positioning and sizing
            Positioned(
              top: moonSize * 0.2,
              left: moonSize * 0.3,
              child: Container(
                width: isTablet ? 8 : 6,
                height: isTablet ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Positioned(
              top: moonSize * 0.5,
              left: moonSize * 0.5,
              child: Container(
                width: isTablet ? 6 : 4,
                height: isTablet ? 6 : 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Positioned(
              top: moonSize * 0.3,
              left: moonSize * 0.6,
              child: Container(
                width: isTablet ? 4 : 3,
                height: isTablet ? 4 : 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Positioned(
              top: moonSize * 0.6,
              left: moonSize * 0.2,
              child: Container(
                width: isTablet ? 7 : 5,
                height: isTablet ? 7 : 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
              ),
            ),
            // Additional crater for tablets to make it look more detailed
            if (isTablet)
              Positioned(
                top: moonSize * 0.15,
                left: moonSize * 0.45,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            if (isTablet)
              Positioned(
                top: moonSize * 0.7,
                left: moonSize * 0.35,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[400],
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  // Get mountain colors based on time
  List<Color> _getMountainColors() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning - Green mountains
      return [Color(0xFF228B22), Color(0xFF32CD32)];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon - Bright green
      return [Color(0xFF228B22), Color(0xFF32CD32)];
    } else if (hour >= 17 && hour < 19) {
      // Evening - Darker green with orange tint
      return [Color(0xFF2F4F2F), Color(0xFF556B2F)];
    } else {
      // Night - Very dark green
      return [Color(0xFF1C3A1C), Color(0xFF2F4F2F)];
    }
  }

  // Create mountain silhouette
  Widget _buildMountains() {
    final mountainColors = _getMountainColors();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isTablet ? 180 : 120,
        child: Stack(
          children: [
            // Back mountain - extends further left
            Positioned(
              bottom: 0,
              left: isTablet ? -100 : -20,
              child: Container(
                width: isTablet ? screenWidth * 0.55 : 200,
                height: isTablet ? 130 : 100,
                decoration: BoxDecoration(
                  color: mountainColors[0].withOpacity(0.7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? 150 : 100),
                    topRight: Radius.circular(isTablet ? 120 : 80),
                  ),
                ),
              ),
            ),
            // Middle mountain - covers more area
            Positioned(
              bottom: 0,
              right: isTablet ? -120 : -30,
              child: Container(
                width: isTablet ? screenWidth * 0.65 : 250,
                height: isTablet ? 125 : 90,
                decoration: BoxDecoration(
                  color: mountainColors[1].withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? 180 : 120),
                    topRight: Radius.circular(isTablet ? 100 : 60),
                  ),
                ),
              ),
            ),
            // Front mountain - better positioned for tablets
            Positioned(
              bottom: 0,
              left: isTablet ? screenWidth * 0.15 : 50,
              child: Container(
                width: isTablet ? screenWidth * 0.45 : 200,
                height: isTablet ? 115 : 80,
                decoration: BoxDecoration(
                  color: mountainColors[0],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? 120 : 90),
                    topRight: Radius.circular(isTablet ? 140 : 100),
                  ),
                ),
              ),
            ),
            // Additional mountain for better tablet coverage (optional)
            if (isTablet)
              Positioned(
                bottom: 0,
                left: screenWidth * 0.6,
                child: Container(
                  width: screenWidth * 0.4,
                  height: 100,
                  decoration: BoxDecoration(
                    color: mountainColors[1].withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(120),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) return 'Good Morning ';
      if (hour >= 12 && hour < 15) return 'Good Afternoon ';
      if (hour >= 15 && hour < 19) return 'Good Evening ';
      return 'Good Night ';
    }

    String greetingEmoji() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) return '🌅';
      if (hour >= 12 && hour < 15) return ' 🌇';
      if (hour >= 15 && hour < 19) return ' 🌆';
      return ' 🌙';
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double spacing = Responsive.responsiveSpacing(context, 12, 16, 20);
    double padding = Responsive.responsivePadding(context, 16, 20, 24);
    double fontSizeSmall = Responsive.getResponsiveFontSize(
      context,
      10,
      12,
      14,
    );
    double fontSizeMedium = Responsive.getResponsiveFontSize(
      context,
      14,
      16,
      18,
    );
    double fontSizeLarge = Responsive.getResponsiveFontSize(
      context,
      18,
      20,
      24,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: spacing * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                gradient: _getSkyGradient(),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(spacing * 2),
                  bottomRight: Radius.circular(spacing * 2),
                ),
              ),
              child: Stack(
                children: [
                  // Mountains in background
                  _buildMountains(),

                  // Main content
                  Positioned(
                    top: screenHeight * 0.08,
                    left: padding,
                    right: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getGreeting(),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.userName} ${greetingEmoji()}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: spacing / 2),
                                  Text(
                                    DateFormat(
                                      'EEEE, MMMM d',
                                    ).format(DateTime.now()),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white70,
                                      fontSize: fontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: spacing),
                            // Dynamic celestial body (sun/moon)
                            _getCelestialBody(),
                          ],
                        ),
                        SizedBox(height: spacing * 1.5),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(spacing * 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(spacing * 2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    color: Colors.white70,
                                    size: fontSizeMedium,
                                  ),
                                  SizedBox(width: spacing * 0.5),
                                  Text(
                                    'Your Daily Quote',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'Poppins',
                                      fontSize: fontSizeSmall,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: spacing * 0.8),
                              IntrinsicHeight(
                                child: GestureDetector(
                                  onTap: () => _showQuoteDialog(context),
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(
                                      minHeight:
                                          Responsive.isMobile(context)
                                              ? 60
                                              : 80,
                                    ),
                                    padding: EdgeInsets.all(spacing * 1.2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        spacing * 1.5,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        savedQuote.isNotEmpty
                                            ? savedQuote
                                            : '"Tap here to add your inspirational quote..."',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontSize:
                                              savedQuote.isNotEmpty
                                                  ? fontSizeMedium
                                                  : fontSizeSmall,
                                          fontWeight:
                                              savedQuote.isNotEmpty
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                          fontStyle:
                                              savedQuote.isNotEmpty
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines:
                                            Responsive.isMobile(context)
                                                ? 3
                                                : 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing * 2),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(spacing * 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: spacing, bottom: spacing),
                      child: Text(
                        'What would you like to do today?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    _buildResponsiveGrid(context, screenWidth, spacing),
                  ],
                ),
              ),
            ),

            SizedBox(height: spacing * 2),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(spacing * 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: spacing, bottom: spacing),
                      child: Text(
                        'Extras',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: 0.8,
                      children: [
                        _buildOptionCard(
                          context,
                          'Scribble',
                          'Scribble & Relax',
                          Icons.brush_rounded,
                          Color(0xFFFFEBF0),
                          Color(0xFFFF6B9D),
                        ),
                        _buildOptionCard(
                          context,
                          'Sound Therapy',
                          'Mix your sounds',
                          Icons.headphones_rounded,
                          Color(0xFFE0F7FA),
                          Color(0xFF0097A7),
                        ),
                        _buildOptionCard(
                          context,
                          'Memory Game',
                          'Train your brain',
                          Icons.extension_rounded,
                          Color(0xFFE1F5FE),
                          Color(0xFF039BE5),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 1.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    double screenWidth,
    double spacing,
  ) {
    List<Widget> optionCards = [
      _buildOptionCard(
        context,
        'Music',
        'Relax & unwind',
        Icons.music_note_rounded,
        Color(0xFFE8F5E8),
        Color(0xFF4CAF50),
      ),
      _buildOptionCard(
        context,
        'Progress',
        'Check your progress',
        Icons.map_outlined,
        Color(0xFFFFF3E0),
        Color(0xFFFF9800),
      ),
      _buildOptionCard(
        context,
        'Mood History',
        'Track your mood',
        Icons.timeline_rounded,
        Color(0xFFE3F2FD),
        Color(0xFF2196F3),
      ),
      _buildOptionCard(
        context,
        'Journal',
        'Write & reflect',
        Icons.book_rounded,
        Color(0xFFF3E5F5),
        Color(0xFF9C27B0),
      ),
      _buildOptionCard(
        context,
        'Assessment',
        'Check wellbeing',
        Icons.psychology_alt_rounded,
        Color(0xFFFCE4EC),
        Color(0xFFE91E63),
      ),
      _buildOptionCard(
        context,
        'Mood Entry',
        'Log how you feel',
        Icons.mood_rounded,
        Color(0xFFE8F5E8),
        Color(0xFF4CAF50),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: 0.8,
      children: optionCards,
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    double spacing = Responsive.responsiveSpacing(context, 12, 16, 20);
    double fontSizeSmall = Responsive.getResponsiveFontSize(context, 8, 10, 12);
    double fontSizeMedium = Responsive.getResponsiveFontSize(
      context,
      10,
      12,
      14,
    );

    return GestureDetector(
      onTap: () {
        if (title == 'Music') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Musicscreen()),
          );
        } else if (title == 'Journal') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JournalScreen()),
          );
        } else if (title == 'Mood Entry') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MoodEntryScreen()),
          );
        } else if (title == 'Assessment') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AssessmentScreen()),
          );
        } else if (title == 'Scribble') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ScribbleScreen()),
          );
        } else if (title == 'Sound Therapy') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SoundTherapyScreen()),
          );
        } else if (title == 'Memory Game') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemoryGameScreen()),
          );
        } else if (title == 'Mood History') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MoodHistoryScreen()),
          );
        } else if (title == 'Progress') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResultsHistoryScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title feature coming soon!')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(spacing * 1.5),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: spacing,
              offset: Offset(0, spacing / 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing * 0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(spacing * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: spacing * 1.5),
              ),
              SizedBox(height: spacing * 0.5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacing * 0.2),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontSizeSmall,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF718096),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
