import 'dart:ui'; // Add this for blur effect
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../responsive.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final String audioPath;

  const MusicPlayerScreen({
    required this.imagePath,
    required this.title,
    required this.audioPath,
  });

  @override
  State<MusicPlayerScreen> createState() => MusicplayerscreenState();
}

class MusicplayerscreenState extends State<MusicPlayerScreen> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((Duration d) {
      setState(() {
        totalDuration = d;
      });
    });

    player.onPositionChanged.listen((Duration p) {
      setState(() {
        currentPosition = p;
      });
    });

    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    try {
      // Stop the player completely
      await player.stop();
      setState(() {
        isPlaying = false;
        currentPosition = Duration.zero;
      });
    } catch (e) {
      print('Error stopping player: $e');
    }
    return true; // Allow the back navigation
  }

  // Format duration to mm:ss
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Skip forward 10 seconds
  void skipForward() async {
    final newPosition = currentPosition + Duration(seconds: 10);
    if (newPosition < totalDuration) {
      await player.seek(newPosition);
    } else {
      await player.seek(totalDuration);
    }
  }

  // Skip backward 10 seconds
  void skipBackward() async {
    final newPosition = currentPosition - Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await player.seek(newPosition);
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    bool isDesktop = Responsive.isDesktop(context);
    // bool isTablet = Responsive.isTablet(context);
    // bool isMobile = Responsive.isMobile(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),

            SafeArea(
              child:
                  isDesktop
                      ? _buildDesktopLayout(screensize)
                      : _buildMobileTabletLayout(screensize),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop layout - horizontal orientation
  Widget _buildDesktopLayout(Size screensize) {
    return Padding(
      padding: EdgeInsets.all(
        Responsive.responsivePadding(context, 20, 30, 40),
      ),
      child: Row(
        children: [
          // Left side - Album art
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () async {
                      await _onWillPop();
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 400,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(widget.imagePath, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 60),

          // Right side - Controls
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Song title and artist
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            26,
                            32,
                            42,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),

                SizedBox(height: 60),

                // Controls
                _buildControlsSection(screensize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile and tablet layout - vertical orientation
  Widget _buildMobileTabletLayout(Size screensize) {
    return Column(
      children: [
        // Back button
        Padding(
          padding: EdgeInsets.only(
            top: Responsive.responsivePadding(context, 20, 25, 30),
            left: Responsive.responsivePadding(context, 10, 15, 20),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: Responsive.getResponsiveFontSize(context, 28, 32, 36),
              ),
              onPressed: () async {
                await _onWillPop();
                Navigator.pop(context);
              },
            ),
          ),
        ),

        Spacer(flex: 1),

        // Album Art
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: Responsive.responsivePadding(context, 40, 60, 80),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              widget.imagePath,
              width:
                  Responsive.isMobile(context)
                      ? screensize.width * 0.8
                      : screensize.width * 0.9,
              height:
                  Responsive.isMobile(context)
                      ? screensize.height * 0.35
                      : screensize.height * 0.4,
              fit: BoxFit.cover,
            ),
          ),
        ),

        Spacer(flex: 1),

        // Song title and artist
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.responsivePadding(context, 30, 40, 50),
          ),
          child: Column(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    26,
                    30,
                    34,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
            ],
          ),
        ),

        SizedBox(height: Responsive.responsiveSpacing(context, 40, 50, 60)),

        // Controls
        _buildControlsSection(screensize),

        Spacer(flex: 1),
      ],
    );
  }

  // Shared controls section
  Widget _buildControlsSection(Size screensize) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsivePadding(context, 20, 40, 60),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: Responsive.isDesktop(context) ? 500 : double.infinity,
            ),
            padding: EdgeInsets.symmetric(
              vertical: Responsive.responsivePadding(
                context,
                screensize.height * 0.03,
                screensize.height * 0.035,
                screensize.height * 0.04,
              ),
              horizontal: Responsive.responsivePadding(
                context,
                screensize.width * 0.06,
                screensize.width * 0.05,
                30,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Column(
              children: [
                // Time labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(currentPosition),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          14,
                          16,
                          18,
                        ),
                      ),
                    ),
                    Text(
                      formatDuration(totalDuration),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          14,
                          16,
                          18,
                        ),
                      ),
                    ),
                  ],
                ),
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: Colors.white,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: Responsive.getResponsiveFontSize(
                        context,
                        8,
                        10,
                        12,
                      ),
                    ),
                    overlayColor: Colors.white.withOpacity(0.2),
                    trackHeight: Responsive.getResponsiveFontSize(
                      context,
                      4,
                      5,
                      6,
                    ),
                  ),
                  child: Slider(
                    min: 0,
                    max: totalDuration.inSeconds.toDouble(),
                    value: currentPosition.inSeconds.toDouble().clamp(
                      0.0,
                      totalDuration.inSeconds.toDouble(),
                    ),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await player.seek(position);
                    },
                  ),
                ),
                SizedBox(
                  height: Responsive.responsiveSpacing(context, 20, 25, 30),
                ),
                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Back 10s
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        iconSize: Responsive.getResponsiveFontSize(
                          context,
                          35,
                          40,
                          45,
                        ),
                        icon: Icon(Icons.replay_10, color: Colors.white),
                        onPressed: skipBackward,
                      ),
                    ),
                    // Play/Pause
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: Responsive.getResponsiveFontSize(
                          context,
                          60,
                          70,
                          80,
                        ),
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          if (isPlaying) {
                            await player.pause();
                          } else {
                            await player.play(AssetSource(widget.audioPath));
                          }
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                      ),
                    ),
                    // Forward 10s
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        iconSize: Responsive.getResponsiveFontSize(
                          context,
                          35,
                          40,
                          45,
                        ),
                        icon: Icon(Icons.forward_10, color: Colors.white),
                        onPressed: skipForward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
