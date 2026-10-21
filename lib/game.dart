import 'package:flutter/material.dart';
import 'dart:async';

class MemoryGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory Card Game',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  void startGame(BuildContext context, int gridSize) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(gridSize: gridSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple[100]!,
              Colors.deepPurple[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: 60,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Memory Master',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple[800],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Improve Memory Skills by Playing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🃏', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 10),
                            Text('🎯', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 10),
                            Text('🧠', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Flip cards and match all pairs to win!\nChoose your difficulty level below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[700],
                            fontFamily: 'Poppins',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildDifficultyButton(
                    context,
                    'Easy',
                    '4×4 Grid',
                    Colors.green,
                    Icons.sentiment_satisfied,
                    () => startGame(context, 4),
                  ),
                  SizedBox(height: 16),
                  _buildDifficultyButton(
                    context,
                    'Medium',
                    '6×6 Grid',
                    Colors.orange,
                    Icons.sentiment_neutral,
                    () => startGame(context, 6),
                  ),
                  SizedBox(height: 16),
                  _buildDifficultyButton(
                    context,
                    'Hard',
                    '8×8 Grid',
                    Colors.red,
                    Icons.sentiment_very_dissatisfied,
                    () => startGame(context, 8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.9),
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

class GameScreen extends StatefulWidget {
  final int gridSize;
  GameScreen({required this.gridSize});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<String> cards;
  List<bool> revealed = [];
  List<int> selectedIndexes = [];
  int moves = 0;
  Timer? flipBackTimer;
  bool gameOver = false;
  late AnimationController _winAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _winAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _winAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _initializeCards() {
    int pairCount = (widget.gridSize * widget.gridSize) ~/ 2;
    List<String> baseCards = List.generate(
      pairCount,
      (i) => String.fromCharCode(65 + i),
    );
    cards = [...baseCards, ...baseCards];
    cards.shuffle();
    revealed = List.filled(cards.length, false);
    selectedIndexes.clear();
    moves = 0;
    gameOver = false;
  }

  void onCardTap(int index) {
    if (revealed[index] ||
        selectedIndexes.contains(index) ||
        selectedIndexes.length == 2 ||
        gameOver)
      return;

    setState(() {
      selectedIndexes.add(index);
    });

    if (selectedIndexes.length == 2) {
      moves++;
      int i1 = selectedIndexes[0];
      int i2 = selectedIndexes[1];

      if (cards[i1] == cards[i2]) {
        setState(() {
          revealed[i1] = true;
          revealed[i2] = true;
          selectedIndexes.clear();
        });
        if (revealed.every((r) => r)) {
          setState(() {
            gameOver = true;
          });
          _winAnimationController.forward();
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pop(context);
          });
        }
      } else {
        flipBackTimer?.cancel();
        flipBackTimer = Timer(Duration(seconds: 1), () {
          setState(() {
            selectedIndexes.clear();
          });
        });
      }
    }
  }

  @override
  void dispose() {
    flipBackTimer?.cancel();
    _winAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int size = widget.gridSize;
    String difficulty =
        size == 4
            ? 'Easy'
            : size == 6
            ? 'Medium'
            : 'Hard';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memory Master - $difficulty',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.deepPurple[100]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Moves', moves.toString(), Icons.touch_app),
                  _buildStatCard('Grid', '${size}×$size', Icons.grid_view),
                  _buildStatCard(
                    'Pairs',
                    '${(size * size) ~/ 2}',
                    Icons.favorite,
                  ),
                ],
              ),
            ),
            if (gameOver) ...[
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('🎉', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 10),
                          Text(
                            'Congratulations!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'You completed the game in $moves moves!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Returning to main menu...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[500],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    bool isFlipped =
                        revealed[index] || selectedIndexes.contains(index);
                    return GestureDetector(
                      onTap: () => onCardTap(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors:
                                isFlipped
                                    ? [Colors.white, Colors.grey[50]!]
                                    : [
                                      Colors.deepPurple[300]!,
                                      Colors.deepPurple[500]!,
                                    ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border:
                              isFlipped
                                  ? Border.all(
                                    color: Colors.deepPurple,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child:
                                isFlipped
                                    ? Text(
                                      cards[index],
                                      key: ValueKey('front_$index'),
                                      style: TextStyle(
                                        fontSize:
                                            size <= 4
                                                ? 32
                                                : size <= 6
                                                ? 24
                                                : 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.deepPurple,
                                        fontFamily: 'Poppins',
                                      ),
                                    )
                                    : Icon(
                                      Icons.help_outline,
                                      key: ValueKey('back_$index'),
                                      size:
                                          size <= 4
                                              ? 32
                                              : size <= 6
                                              ? 24
                                              : 20,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
