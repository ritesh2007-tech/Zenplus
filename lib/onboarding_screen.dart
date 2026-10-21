import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _startButtonTimer();
  }

  void _startButtonTimer() {
    setState(() {
      _showButton = false;
    });
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: NeverScrollableScrollPhysics(), // Disable scrolling
                onPageChanged: (index) {
                  setState(() {
                    isLastPage = index == 2;
                  });
                  _startButtonTimer();
                },
                children: [
                  buildPage(
                    "assets/images/logo.jpg",
                    "Welcome to Zenplus",
                    "Relax. Reflect. Reconnect — anytime, offline.",
                    isTablet,
                  ),
                  buildFeaturePage(isTablet),
                  buildPageWithNote(
                    "assets/images/logo.jpg",
                    "Ready to Begin?",
                    "\"Small steps every day lead to a healthier you.\"",
                    isTablet,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: WormEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child:
                        _showButton
                            ? ElevatedButton(
                              key: ValueKey("button"),
                              onPressed: () async {
                                if (isLastPage) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('seenOnboarding', true);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                } else {
                                  _controller.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.indigo,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 100 : 60,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                isLastPage ? "Get Started" : "Next",
                                style: TextStyle(fontSize: isTablet ? 20 : 16),
                              ),
                            )
                            : Text(
                              "⏳ Please take a moment to read.\nButton will appear in 10 seconds...",
                              key: ValueKey("text"),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: isTablet ? 14 : 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPage(String image, String title, String subtitle, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: isTablet ? 300 : 240),
        SizedBox(height: isTablet ? 40 : 30),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 28 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget buildPageWithNote(
    String image,
    String title,
    String subtitle,
    bool isTablet,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: isTablet ? 300 : 240),
        SizedBox(height: isTablet ? 40 : 30),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 28 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: isTablet ? 18 : 16),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Note: This app works fully offline using local storage only.\nSome features may improve with future updates.\nThank you for your support! 💙",
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget buildFeaturePage(bool isTablet) {
    final features = [
      [
        '🎵',
        "Sound Therapy",
        "Blend calming sounds like rain, wind, and chimes\n(Create your own mix)",
      ],
      ['🎧', "Music Library", "Your chill zone\n(pop on your headphones)"],
      ['🖊️', "Scribble", "Doodle freely to calm your mind"],
      ['📔', "Journal", "Write freely, your way"],
      ['🎮', "Memory Game", "Play, focus, and train your mind"],
      ['😌', "Mood Tracker", "Track your emotions daily"],
      ['🧪', "Assessments", "Gauge your mental well-being"],
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Text(
            "What's Inside",
            style: TextStyle(
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ...features.map(
            (f) => ListTile(
              leading: Text(f[0], style: TextStyle(fontSize: 28)),
              title: Text(
                f[1],
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                f[2],
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
          ),
          SizedBox(height: 120), // Add space at bottom to prevent overlay
        ],
      ),
    );
  }
}
