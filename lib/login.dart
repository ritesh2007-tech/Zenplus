import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome👋",
                  style: TextStyle(
                    fontSize: width * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  "Let's begin your journey.",
                  style: TextStyle(fontSize: width * 0.045),
                ),
                SizedBox(height: height * 0.05),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your name',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: height * 0.018,
                      horizontal: width * 0.05,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),
                ElevatedButton(
                  onPressed: () async {
                    String name = _nameController.text.trim();
                    if (name.isNotEmpty) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('userName', name);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  MentalHealthDashboard(userName: name),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter your name')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: EdgeInsets.symmetric(
                      vertical: height * 0.018,
                      horizontal: width * 0.28,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: width * 0.03),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
