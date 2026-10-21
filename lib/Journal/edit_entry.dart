import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:mindmat/Journal/Model_Note.dart';
import 'package:mindmat/db_helper/db_manager.dart';
import 'package:mindmat/responsive.dart'; // Import the responsive utility

class EditEntryScreen extends StatefulWidget {
  final ModelNote note;

  EditEntryScreen({required this.note});

  @override
  _EditEntryScreenState createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController titleController;
  late TextEditingController bodyController;
  List<TextEditingController> imageDescriptions = [];
  String? selectedMood;
  List<XFile> _pickedImages = [];
  List<Map<String, String>> existingImages = []; // For existing images from DB
  bool _isPicking = false;

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

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    bodyController = TextEditingController(text: widget.note.body);
    selectedMood = widget.note.mood ?? moods.first;

    // Initialize existing images
    existingImages = List.from(widget.note.images);

    // Initialize controllers for existing image descriptions
    imageDescriptions =
        existingImages
            .map((img) => TextEditingController(text: img['description'] ?? ''))
            .toList();
  }

  // Get the permanent directory for storing images
  Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'journal_images'));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  // Copy image to permanent storage
  Future<String> _saveImagePermanently(String sourcePath) async {
    final imagesDir = await _getImagesDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
    final permanentPath = path.join(imagesDir.path, fileName);

    final sourceFile = File(sourcePath);
    final permanentFile = await sourceFile.copy(permanentPath);

    return permanentFile.path;
  }

  // Delete image from permanent storage
  Future<void> _deleteImagePermanently(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  void _pickImages() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final ImagePicker _picker = ImagePicker();
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _pickedImages.addAll(images);
          // Add controllers for new images
          imageDescriptions.addAll(
            List.generate(images.length, (_) => TextEditingController()),
          );
        });
      }
    } catch (e) {
      print("Image picking failed: $e");
    } finally {
      _isPicking = false;
    }
  }

  void _openImageFullScreen(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              body: PhotoView(
                imageProvider: FileImage(File(imagePath)),
                backgroundDecoration: BoxDecoration(color: Colors.black),
              ),
            ),
      ),
    );
  }

  void showSaveDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Responsive.responsivePadding(context, 12, 14, 16),
              ),
            ),
            backgroundColor: Colors.deepPurple[50],
            contentPadding: EdgeInsets.all(
              Responsive.responsivePadding(context, 20, 24, 28),
            ),
            title: Text(
              'Save Changes',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: Responsive.getResponsiveFontSize(context, 18, 20, 22),
              ),
            ),
            content: Text(
              'Do you want to save the changes to your journal entry?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.getResponsiveFontSize(context, 14, 16, 18),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                onPressed: () {
                  Navigator.of(context).pop();
                  saveNote();
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
          ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                Responsive.responsivePadding(context, 12, 14, 16),
              ),
            ),
            backgroundColor: Colors.red[50],
            contentPadding: EdgeInsets.all(
              Responsive.responsivePadding(context, 20, 24, 28),
            ),
            title: Text(
              'Delete Entry',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
                fontSize: Responsive.getResponsiveFontSize(context, 18, 20, 22),
              ),
            ),
            content: Text(
              'Are you sure you want to delete this journal entry?',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red[600],
                fontSize: Responsive.getResponsiveFontSize(context, 14, 16, 18),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
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
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteNote();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
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
          ),
    );
  }

  void saveNote() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Saving images..."),
              ],
            ),
          ),
    );

    try {
      // Combine existing images with new images
      List<Map<String, String>> allImages = [];

      // Add existing images with updated descriptions
      for (int i = 0; i < existingImages.length; i++) {
        allImages.add({
          'path': existingImages[i]['path']!,
          'description':
              i < imageDescriptions.length
                  ? imageDescriptions[i].text
                  : existingImages[i]['description'] ?? '',
        });
      }

      // Add new images with descriptions - save them permanently first
      int existingCount = existingImages.length;
      for (int i = 0; i < _pickedImages.length; i++) {
        // Save the image permanently
        String permanentPath = await _saveImagePermanently(
          _pickedImages[i].path,
        );

        allImages.add({
          'path': permanentPath,
          'description':
              (existingCount + i) < imageDescriptions.length
                  ? imageDescriptions[existingCount + i].text
                  : '',
        });
      }

      ModelNote updatedNote = ModelNote(
        id: widget.note.id,
        title: titleController.text,
        body: bodyController.text,
        date: widget.note.date,
        mood: selectedMood,
        images: allImages,
      );

      await DBHandler().updateData(updatedNote);

      // Close loading dialog
      Navigator.pop(context);

      // Close edit screen
      Navigator.pop(context, true);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Error"),
              content: Text("Failed to save images. Please try again."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  void deleteNote() async {
    try {
      // Delete associated images from storage
      for (var imageData in existingImages) {
        await _deleteImagePermanently(imageData['path']!);
      }

      // Delete the note from database
      await DBHandler().deleteData(widget.note.id);
      Navigator.pop(context, true);
    } catch (e) {
      print("Error deleting note: $e");
      // Still try to delete from database even if image deletion fails
      await DBHandler().deleteData(widget.note.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);

    // Combine existing and new images for display
    List<dynamic> allDisplayImages = [
      ...existingImages.map((img) => {'type': 'existing', 'data': img}),
      ..._pickedImages.map((img) => {'type': 'new', 'data': img}),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Journal",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: Responsive.getResponsiveFontSize(context, 18, 20, 22),
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.green,
              size: Responsive.getResponsiveFontSize(context, 24, 26, 28),
            ),
            tooltip: 'Save',
            onPressed: showSaveDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.add_photo_alternate_rounded,
              color: Colors.blue,
              size: Responsive.getResponsiveFontSize(context, 24, 26, 28),
            ),
            tooltip: 'Add Photo',
            onPressed: _pickImages,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: Responsive.getResponsiveFontSize(context, 24, 26, 28),
            ),
            tooltip: 'Delete',
            onPressed: showDeleteDialog,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 86, 85, 87),
              Color.fromARGB(255, 53, 52, 55),
              Color.fromARGB(255, 20, 18, 22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.only(
          top: Responsive.responsivePadding(
            context,
            size.height * 0.12, // Mobile
            size.height * 0.11, // Tablet
            size.height * 0.10, // Desktop
          ),
          left: Responsive.responsivePadding(
            context,
            size.width * 0.06, // Mobile
            size.width * 0.08, // Tablet
            size.width * 0.12, // Desktop
          ),
          right: Responsive.responsivePadding(
            context,
            size.width * 0.06, // Mobile
            size.width * 0.08, // Tablet
            size.width * 0.12, // Desktop
          ),
          bottom: Responsive.responsivePadding(context, 16, 20, 24),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mood Selector
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.responsivePadding(context, 8, 10, 12),
                  horizontal: Responsive.responsivePadding(context, 12, 16, 20),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    Responsive.responsivePadding(context, 8, 10, 12),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.deepPurple[100],
                    iconEnabledColor: Colors.white,
                    value: selectedMood,
                    items:
                        moods.map((String mood) {
                          return DropdownMenuItem<String>(
                            value: mood,
                            child: Text(
                              mood,
                              style: TextStyle(
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                                fontSize: Responsive.getResponsiveFontSize(
                                  context,
                                  14,
                                  15,
                                  16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMood = value!;
                      });
                    },
                    hint: Text(
                      "Select Mood",
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          14,
                          15,
                          16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: Responsive.responsiveSpacing(context, 16, 20, 24),
              ),

              // Title Field
              TextField(
                controller: titleController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    size.width * 0.07, // Mobile - slightly smaller
                    size.width * 0.055, // Tablet
                    size.width * 0.04, // Desktop
                  ),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Title...",
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      size.width * 0.045, // Mobile
                      size.width * 0.04, // Tablet
                      size.width * 0.035, // Desktop
                    ),
                    color: Colors.white70,
                  ),
                  border: InputBorder.none,
                ),
              ),

              SizedBox(
                height: Responsive.responsiveSpacing(context, 12, 16, 20),
              ),

              // Images Section
              if (allDisplayImages.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.responsivePadding(context, 30, 35, 40),
                  ),
                  margin: EdgeInsets.only(
                    bottom: Responsive.responsiveSpacing(context, 16, 20, 24),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Responsive.responsivePadding(context, 10, 12, 14),
                    ),
                    border: Border.all(
                      color: Colors.white54,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Center(
                    child: Text(
                      isMobile
                          ? "Tap '+' to add images"
                          : "Tap '+' to add images with description",
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        fontSize: Responsive.getResponsiveFontSize(
                          context,
                          12,
                          13,
                          14,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SizedBox(
                  height:
                      isMobile
                          ? size.height * 0.22
                          : (isTablet
                              ? size.height * 0.25
                              : size.height * 0.28),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: allDisplayImages.length,
                    itemBuilder: (context, index) {
                      final imageItem = allDisplayImages[index];
                      final isExisting = imageItem['type'] == 'existing';
                      final imagePath =
                          isExisting
                              ? imageItem['data']['path']
                              : imageItem['data'].path;

                      return Container(
                        width:
                            isMobile
                                ? size.width * 0.65
                                : (isTablet
                                    ? size.width * 0.55
                                    : size.width * 0.45),
                        margin: EdgeInsets.only(
                          right: Responsive.responsiveSpacing(
                            context,
                            12,
                            16,
                            20,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            Responsive.responsivePadding(context, 12, 14, 16),
                          ),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap:
                                        () => _openImageFullScreen(imagePath),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          Responsive.responsivePadding(
                                            context,
                                            12,
                                            14,
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Image.file(
                                        File(imagePath),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey[600],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isExisting) {
                                            // Remove from existing images
                                            int existingIndex = index;
                                            existingImages.removeAt(
                                              existingIndex,
                                            );
                                            if (existingIndex <
                                                imageDescriptions.length) {
                                              imageDescriptions.removeAt(
                                                existingIndex,
                                              );
                                            }
                                          } else {
                                            // Remove from new images
                                            int newIndex =
                                                index - existingImages.length;
                                            _pickedImages.removeAt(newIndex);
                                            int descIndex =
                                                existingImages.length +
                                                newIndex;
                                            if (descIndex <
                                                imageDescriptions.length) {
                                              imageDescriptions.removeAt(
                                                descIndex,
                                              );
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(
                                          Responsive.responsivePadding(
                                            context,
                                            3,
                                            4,
                                            5,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size:
                                              Responsive.getResponsiveFontSize(
                                                context,
                                                14,
                                                16,
                                                18,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                Responsive.responsivePadding(context, 6, 8, 10),
                              ),
                              child: TextField(
                                controller:
                                    index < imageDescriptions.length
                                        ? imageDescriptions[index]
                                        : TextEditingController(),
                                decoration: InputDecoration(
                                  hintText:
                                      isMobile
                                          ? "Describe image..."
                                          : "Describe this image...",
                                  hintStyle: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'Poppins',
                                    fontSize: Responsive.getResponsiveFontSize(
                                      context,
                                      10,
                                      11,
                                      12,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: Responsive.getResponsiveFontSize(
                                    context,
                                    10,
                                    11,
                                    12,
                                  ),
                                ),
                                maxLines: isMobile ? 1 : 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(
                height: Responsive.responsiveSpacing(context, 16, 20, 24),
              ),

              // Body Text Field
              TextField(
                controller: bodyController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.getResponsiveFontSize(
                    context,
                    size.width * 0.04, // Mobile
                    size.width * 0.035, // Tablet
                    size.width * 0.03, // Desktop
                  ),
                  color: Colors.white,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText:
                      isMobile
                          ? "Write your thoughts..."
                          : "Write your thoughts here...",
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      size.width * 0.035, // Mobile
                      size.width * 0.03, // Tablet
                      size.width * 0.025, // Desktop
                    ),
                    color: Colors.white60,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    for (var controller in imageDescriptions) {
      controller.dispose();
    }
    super.dispose();
  }
}
