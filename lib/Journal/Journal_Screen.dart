import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mindmat/db_helper/db_manager.dart';
import 'package:mindmat/Journal/Model_Note.dart';
import 'package:mindmat/Journal/edit_entry.dart';
import 'package:mindmat/Journal/diary_entry.dart';
import '../responsive.dart';

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<ModelNote> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    final fetched = await DBHandler().readData();
    setState(() => notes = fetched);
  }

  void deleteNote(int id) async {
    await DBHandler().deleteData(id);
    loadNotes();
  }

  // Widget to create overlapping image stack
  Widget buildImageStack(List<Map<String, String>> images, Size size) {
    if (images.isEmpty) return SizedBox.shrink();

    // Limit to show maximum 3 images for better UI
    final displayImages = images.take(3).toList();

    return Container(
      width: Responsive.responsivePadding(
        context,
        size.width * 0.15, // Mobile
        size.width * 0.12, // Tablet
        size.width * 0.10, // Desktop
      ),
      height: Responsive.responsivePadding(
        context,
        size.width * 0.12, // Mobile
        size.width * 0.10, // Tablet
        size.width * 0.08, // Desktop
      ),
      child: Stack(
        children: [
          // Create overlapping images
          for (int i = 0; i < displayImages.length; i++)
            Positioned(
              right:
                  i *
                  Responsive.responsivePadding(
                    context,
                    size.width * 0.025, // Mobile
                    size.width * 0.020, // Tablet
                    size.width * 0.015, // Desktop
                  ),
              top:
                  i *
                  Responsive.responsivePadding(
                    context,
                    size.width * 0.015, // Mobile
                    size.width * 0.012, // Tablet
                    size.width * 0.010, // Desktop
                  ),
              child: Container(
                width: Responsive.responsivePadding(
                  context,
                  size.width * 0.11, // Mobile
                  size.width * 0.09, // Tablet
                  size.width * 0.07, // Desktop
                ),
                height: Responsive.responsivePadding(
                  context,
                  size.width * 0.11, // Mobile
                  size.width * 0.09, // Tablet
                  size.width * 0.07, // Desktop
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(displayImages[i]['path']!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: Responsive.getResponsiveFontSize(
                            context,
                            size.width * 0.04, // Mobile
                            size.width * 0.035, // Tablet
                            size.width * 0.025, // Desktop
                          ),
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          // Show count if more than 3 images
          if (images.length > 3)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: Responsive.responsivePadding(
                  context,
                  size.width * 0.06, // Mobile
                  size.width * 0.05, // Tablet
                  size.width * 0.04, // Desktop
                ),
                height: Responsive.responsivePadding(
                  context,
                  size.width * 0.06, // Mobile
                  size.width * 0.05, // Tablet
                  size.width * 0.04, // Desktop
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '+${images.length - 3}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        size.width * 0.025, // Mobile
                        size.width * 0.020, // Tablet
                        size.width * 0.015, // Desktop
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF3F4F8),
        title: Text(
          "My Journal📕",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: Responsive.getResponsiveFontSize(
              context,
              size.width * 0.05, // Mobile
              size.width * 0.035, // Tablet
              size.width * 0.035, // Desktop
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF3F4F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEntryScreen()),
          );
          if (result == true) loadNotes();
        },
        child: Icon(Icons.add),
      ),
      body:
          notes.isEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.responsivePadding(
                      context,
                      size.width * 0.1, // Mobile
                      size.width * 0.15, // Tablet
                      size.width * 0.2, // Desktop
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "🌿 Start Your Journey 🌿",
                        style: TextStyle(
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            size.width * 0.055, // Mobile
                            size.width * 0.04, // Tablet
                            size.width * 0.035, // Desktop
                          ),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        "No journal entries yet.\nTap the ➕ button below to begin writing your thoughts, feelings, or reflections. Each word is a step towards peace. ✨",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            size.width * 0.038, // Mobile
                            size.width * 0.025, // Tablet
                            size.width * 0.025, // Desktop
                          ),
                          fontFamily: 'Poppins',
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Responsive.isDesktop(context)
              ? _buildDesktopGrid(size)
              : _buildMobileTabletList(size),
    );
  }

  // Desktop grid layout
  Widget _buildDesktopGrid(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.02,
        horizontal: size.width * 0.06,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: size.width * 0.02,
          mainAxisSpacing: size.height * 0.02,
          childAspectRatio: 1.8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return _buildNoteCard(notes[index], size, isGrid: true);
        },
      ),
    );
  }

  // Mobile and tablet list layout
  Widget _buildMobileTabletList(Size size) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.02,
        horizontal: Responsive.responsivePadding(
          context,
          size.width * 0.04, // Mobile
          size.width * 0.04, // Tablet
          size.width * 0.08, // Desktop
        ),
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index], size);
      },
    );
  }

  // Shared note card widget
  Widget _buildNoteCard(ModelNote note, Size size, {bool isGrid = false}) {
    String displayText =
        note.body.length > (isGrid ? 100 : 150)
            ? '${note.body.substring(0, isGrid ? 100 : 150)}...'
            : note.body;

    return GestureDetector(
      onTap: () async {
        bool? updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditEntryScreen(note: note)),
        );
        if (updated == true) loadNotes();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isGrid ? 0 : size.height * 0.02),
        padding: EdgeInsets.all(
          Responsive.responsivePadding(
            context,
            size.width * 0.045, // Mobile
            size.width * 0.040, // Tablet
            size.width * 0.030, // Desktop
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Responsive.getResponsiveFontSize(
                            context,
                            size.width * 0.05, // Mobile
                            size.width * 0.042, // Tablet
                            size.width * 0.028, // Desktop
                          ),
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                        maxLines: isGrid ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Leave space for image stack
                    SizedBox(
                      width: Responsive.responsivePadding(
                        context,
                        size.width * 0.2, // Mobile
                        size.width * 0.15, // Tablet
                        size.width * 0.12, // Desktop
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),

                // Mood Tag
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.responsivePadding(
                      context,
                      size.width * 0.03, // Mobile
                      size.width * 0.025, // Tablet
                      size.width * 0.02, // Desktop
                    ),
                    vertical: size.height * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 229, 232, 245),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Mood: ${note.mood ?? 'Not Selected'}",
                    style: TextStyle(
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        size.width * 0.035, // Mobile
                        size.width * 0.025, // Tablet
                        size.width * 0.020, // Desktop
                      ),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.015),

                // Body
                Padding(
                  padding: EdgeInsets.only(
                    right: Responsive.responsivePadding(
                      context,
                      size.width * 0.18, // Mobile
                      size.width * 0.15, // Tablet
                      size.width * 0.12, // Desktop
                    ),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: Responsive.getResponsiveFontSize(
                        context,
                        size.width * 0.038, // Mobile
                        size.width * 0.030, // Tablet
                        size.width * 0.022, // Desktop
                      ),
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    maxLines: isGrid ? 3 : null,
                    overflow: isGrid ? TextOverflow.ellipsis : null,
                  ),
                ),
                SizedBox(height: size.height * 0.03),

                // Date
                Text(
                  "Date: ${note.date}",
                  style: TextStyle(
                    fontSize: Responsive.getResponsiveFontSize(
                      context,
                      size.width * 0.038, // Mobile
                      size.width * 0.030, // Tablet
                      size.width * 0.020, // Desktop
                    ),
                    fontFamily: 'Poppins',
                    color: const Color.fromARGB(66, 0, 0, 0),
                    height: 1.4,
                  ),
                ),
              ],
            ),

            // Overlapping image stack in bottom right
            Positioned(
              bottom: 0,
              right: 0,
              child: buildImageStack(note.images, size),
            ),
          ],
        ),
      ),
    );
  }
}
