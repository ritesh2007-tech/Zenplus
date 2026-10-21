import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmat/db_helper/db_manager.dart';
import 'package:mindmat/responsive.dart'; // Import the responsive utility
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DiaryEntryScreen extends StatefulWidget {
  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  var titleController = TextEditingController();
  var bodyController = TextEditingController();
  String date = DateFormat('dd MMM yyyy').format(DateTime.now());
  String selectedMood = 'Happy 😊';

  final List<String> moods = [
    'Happy 😊',
    'Excited 🎉',
    'Grateful ❤️',
    'Peaceful 🧘',
    'Neutral 😐',
    'Thoughtful 🤔',
    'Sad 😢',
    'Anxious 😰',
    'Stressed 😤',
    'Angry 😠',
  ];

  List<Map<String, String>> images = []; // Store image path + description
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Entry',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            fontSize: Responsive.getResponsiveFontSize(context, 20, 22, 24),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(
              right: Responsive.responsivePadding(context, 16, 20, 24),
            ),
            child: Chip(
              label: Text(
                date,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    12,
                    13,
                    14,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            String title = titleController.text.trim();
            String body = bodyController.text.trim();
            if (title.isNotEmpty || body.isNotEmpty) {
              await DBHandler().insertData(
                title,
                body,
                date,
                selectedMood,
                images,
              );
              Navigator.pop(context, true);
            }
          },
          backgroundColor: Colors.blue[600],
          elevation: 0,
          icon: Icon(Icons.save_rounded, color: Colors.white),
          label: Text(
            'Save Entry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: Responsive.getResponsiveFontSize(context, 14, 15, 16),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.responsivePadding(
            context,
            size.width * 0.06, // Mobile: 6% of screen width
            size.width * 0.08, // Tablet: 8% of screen width
            size.width * 0.12, // Desktop: 12% of screen width
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.responsiveSpacing(context, 16, 20, 24)),

            /// Mood Selector
            buildMoodSelector(context),

            SizedBox(height: Responsive.responsiveSpacing(context, 24, 28, 32)),

            /// Title Input
            buildCard(
              context: context,
              icon: Icons.title,
              title: 'Title',
              child: TextField(
                controller: titleController,
                style: TextStyle(
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    size.width * 0.055, // Mobile
                    size.width * 0.04, // Tablet
                    size.width * 0.03, // Desktop
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                decoration: InputDecoration(
                  hintText: "Give your entry a title...",
                  hintStyle: TextStyle(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      size.width * 0.045, // Mobile
                      size.width * 0.035, // Tablet
                      size.width * 0.025, // Desktop
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: Responsive.responsiveSpacing(context, 20, 24, 28)),

            /// Image Picker Row
            buildImagePicker(context),

            SizedBox(height: Responsive.responsiveSpacing(context, 20, 24, 28)),

            /// Body
            buildCard(
              context: context,
              icon: Icons.edit_note,
              title: 'Your thoughts',
              child: TextField(
                controller: bodyController,
                maxLines: null,
                minLines: isMobile ? 6 : (isTablet ? 8 : 10),
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    size.width * 0.04, // Mobile
                    size.width * 0.035, // Tablet
                    size.width * 0.03, // Desktop
                  ),
                  height: 1.5,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                decoration: InputDecoration(
                  hintText:
                      isMobile
                          ? "Express your thoughts and feelings here..."
                          : "Express your thoughts, feelings, and experiences here...\n\nWhat happened today?\nHow did it make you feel?\nWhat are you grateful for?",
                  hintStyle: TextStyle(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      size.width * 0.035, // Mobile
                      size.width * 0.03, // Tablet
                      size.width * 0.025, // Desktop
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(
              height: Responsive.responsiveSpacing(context, 80, 100, 120),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMoodSelector(BuildContext context) {
    return buildCard(
      context: context,
      icon: Icons.mood,
      title: 'How are you feeling?',
      child: Wrap(
        spacing: Responsive.responsiveSpacing(context, 8, 10, 12),
        runSpacing: Responsive.responsiveSpacing(context, 8, 10, 12),
        children:
            moods.map((mood) {
              bool isSelected = mood == selectedMood;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = mood;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.responsivePadding(
                      context,
                      12,
                      14,
                      16,
                    ),
                    vertical: Responsive.responsivePadding(context, 8, 10, 12),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border:
                        isSelected
                            ? Border.all(color: Colors.blue[300]!, width: 2)
                            : null,
                  ),
                  child: Text(
                    mood,
                    style: TextStyle(
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        13,
                        14,
                        15,
                      ),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.blue[700] : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildImagePicker(BuildContext context) {
    double imageSize =
        Responsive.isMobile(context)
            ? 100
            : (Responsive.isTablet(context) ? 120 : 140);

    return SizedBox(
      height: imageSize + 20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        separatorBuilder:
            (_, __) => SizedBox(
              width: Responsive.responsiveSpacing(context, 8, 10, 12),
            ),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return GestureDetector(
              onTap: pickImage,
              child: DottedAddContainer(size: imageSize),
            );
          }
          final img = images[index];
          return Stack(
            children: [
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(img['path']!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    img['description'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        10,
                        11,
                        12,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      images.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: Responsive.isMobile(context) ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        Responsive.responsivePadding(context, 16, 20, 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          Responsive.responsivePadding(context, 16, 18, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: Responsive.responsivePadding(context, 8, 10, 12),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: Responsive.getResponsiveFontSize(context, 18, 20, 22),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    14,
                    16,
                    18,
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.responsiveSpacing(context, 12, 14, 16)),
          child,
        ],
      ),
    );
  }

  // Fixed method to save images permanently
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      String? description = await showDialog<String>(
        context: context,
        builder: (context) {
          final descController = TextEditingController();
          return AlertDialog(
            title: Text(
              "Add Description",
              style: TextStyle(
                fontSize: Responsive.getResponsiveFontSize(context, 16, 18, 20),
              ),
            ),
            content: TextField(
              controller: descController,
              style: TextStyle(
                fontSize: Responsive.getResponsiveFontSize(context, 14, 15, 16),
              ),
              decoration: InputDecoration(
                hintText: "Enter image description...",
                hintStyle: TextStyle(
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    13,
                    14,
                    15,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      14,
                      15,
                      16,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, descController.text.trim()),
                child: Text(
                  "Add",
                  style: TextStyle(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      14,
                      15,
                      16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (description != null && description.isNotEmpty) {
        try {
          // Copy image to permanent storage
          String permanentPath = await _saveImagePermanently(picked.path);
          setState(() {
            images.add({'path': permanentPath, 'description': description});
          });
        } catch (e) {
          // Handle error - show snackbar or dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // New method to save images permanently
  Future<String> _saveImagePermanently(String tempPath) async {
    // Get the app's documents directory (permanent storage)
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    // Create a diary_images folder if it doesn't exist
    final Directory diaryImagesDir = Directory(
      path.join(appDocDir.path, 'diary_images'),
    );
    if (!await diaryImagesDir.exists()) {
      await diaryImagesDir.create(recursive: true);
    }

    // Create unique filename with timestamp
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(tempPath);
    final String fileName = 'diary_image_$timestamp$extension';
    final String permanentPath = path.join(diaryImagesDir.path, fileName);

    // Copy the file to permanent storage
    final File tempFile = File(tempPath);
    final File permanentFile = await tempFile.copy(permanentPath);

    return permanentFile.path;
  }
}

class DottedAddContainer extends StatelessWidget {
  final double size;

  const DottedAddContainer({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          width: 1.5,
          style: BorderStyle.solid,
        ),
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              color: Colors.grey[600],
              size: Responsive.getResponsiveFontSize(context, 24, 26, 28),
            ),
            SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: Responsive.getResponsiveFontSize(context, 10, 11, 12),
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
