import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmat/login.dart';
import 'package:mindmat/onboarding_screen.dart';
import 'package:mindmat/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👉 Lock to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 👉 Hide system bars completely, show only floating icons
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 👉 Make system bars completely invisible - only icons visible
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0x00000000), // Completely transparent
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // 👉 Check onboarding & login state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  String? userName = prefs.getString('userName');

  Widget startScreen;
  if (!seenOnboarding) {
    startScreen = OnboardingScreen();
  } else if (userName == null || userName.isEmpty) {
    startScreen = LoginScreen();
  } else {
    startScreen = MentalHealthDashboard(userName: userName);
  }

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0x00000000), // Fully invisible
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: MaterialApp(
        title: 'MindMat Journal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          // 👉 Ensure app bar theme is transparent
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
        home: startScreen,
      ),
    );
  }
}

// 👉 Optional: Create a wrapper widget for screens that need transparent system bars
class TransparentSystemBarWrapper extends StatelessWidget {
  final Widget child;
  final Brightness statusBarIconBrightness;
  final Brightness systemNavigationBarIconBrightness;

  const TransparentSystemBarWrapper({
    Key? key,
    required this.child,
    this.statusBarIconBrightness = Brightness.dark,
    this.systemNavigationBarIconBrightness = Brightness.dark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness:
            statusBarIconBrightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarColor: Color(0x00000000), // Completely invisible
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
