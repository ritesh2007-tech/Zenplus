import 'package:flutter/material.dart';
import 'package:mindmat/Music/Player_screen.dart';
import 'package:mindmat/responsive.dart';

class Musicscreen extends StatelessWidget {
  final List<Map<String, String>> musicList = [
    {
      "title": "Coffee Chill Out ",

      "type": "Chill",
      "image": "assets/images/coffee.png",
      "audio": "audio/coffee_chill.mp3",
    },
    {
      "title": "Sunset in Lagos ",

      "type": "Chill",
      "image": "assets/images/vibe.png",
      "audio": "audio/chill_afro.mp3",
    },
    {
      "title": "Ethereal Bounce ",

      "type": "Chill",
      "image": "assets/images/vibe2.png",
      "audio": "audio/evening_vibe.mp3",
    },
    {
      "title": "Dreams",

      "type": "Evening Vibes",
      "image": "assets/images/dreams.png",
      "audio": "audio/dreams.mp3",
    },
    {
      "title": "Flute Melody",

      "type": "Evening Vibes",
      "image": "assets/images/flute.png",
      "audio": "audio/flute.mp3",
    },
    {
      "title": "Heal Frequency",

      "type": "Meditation and Mindfullness",
      "image": "assets/images/heal.png",
      "audio": "audio/heal_freq.mp3",
    },
    {
      "title": "Tibetian Path",

      "type": "Meditation and Mindfullness",
      "image": "assets/images/tibetian.png",
      "audio": "audio/tibetian.mp3",
    },
    {
      "title": "Om Chant",

      "type": "Meditation and Mindfullness",
      "image": "assets/images/om.png",
      "audio": "audio/om.mp3",
    },
    {
      "title": "Mindfulness",

      "type": "Meditation and Mindfullness",
      "image": "assets/images/mindfulness.png",
      "audio": "audio/mindfulness.mp3",
    },
    {
      "title": "Moonlit Ambience",

      "type": "Nightfall Melodies",
      "image": "assets/images/nighttime.png",
      "audio": "audio/Sleep.mp3",
    },
    {
      "title": "Night Breeze",

      "type": "Nightfall Melodies",
      "image": "assets/images/night_breeze.png",
      "audio": "audio/night_breeze.mp3",
    },
    {
      "title": "Starry Night",

      "type": "Nightfall Melodies",
      "image": "assets/images/night_forest.png",
      "audio": "audio/night_forest.mp3",
    },
  ];

  @override
  Widget build(BuildContext context) {
    double spacing = Responsive.responsiveSpacing(context, 12, 16, 20);
    double padding = Responsive.responsivePadding(context, 16, 20, 24);
    double fontSizeMedium = Responsive.getResponsiveFontSize(
      context,
      14,
      16,
      18,
    );
    double fontSizeSmall = Responsive.getResponsiveFontSize(
      context,
      10,
      12,
      14,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Relaxing Music",
          style: TextStyle(fontFamily: 'Poppins', fontSize: fontSizeMedium),
        ),
        backgroundColor: Color.fromARGB(255, 175, 190, 209),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: ListView.builder(
          itemCount: musicList.length,
          itemBuilder: (context, index) {
            final music = musicList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MusicPlayerScreen(
                          imagePath: music["image"]!,
                          title: music["title"]!,
                          audioPath: music["audio"]!,
                        ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: spacing * 1.5),
                padding: EdgeInsets.all(spacing),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 228, 234, 238),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 🎵 Soft padded image container with rounded corners
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // 👈 Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(music["image"]!, fit: BoxFit.cover),
                      ),
                    ),

                    SizedBox(width: spacing),

                    // 🎧 Song text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            music["title"]!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: fontSizeMedium,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),

                          SizedBox(height: spacing / 3),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFE0F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              music["type"]!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: fontSizeSmall,
                                color: Colors.teal[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
