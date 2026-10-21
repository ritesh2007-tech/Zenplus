import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// void main() {
//   runApp(
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Poppins',
//         textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
//       ),
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.deepPurpleAccent,
//           title: Text('Horizontal Image Notes'),
//         ),
//         body: ImageNoteCard(),
//       ),
//     ),
//   );
// }

class ImageNoteCard extends StatefulWidget {
  @override
  _ImageNoteCardState createState() => _ImageNoteCardState();
}

class _ImageNoteCardState extends State<ImageNoteCard> {
  List<_ImageDescription> imageList = [];

  Future<void> _pickImageAndAddCard() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageList.add(_ImageDescription(imageFile: File(picked.path)));
      });
    }
  }

  void _showFullImage(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  child: Image.file(imageList[index].imageFile),
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(16),
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              final imageData = imageList[index];
              return Container(
                width: size.width * 0.8,
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showFullImage(index),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              imageData.imageFile,
                              height: size.height * 0.25,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  imageList.removeAt(index);
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Description Box
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: imageData.descController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: "Describe this image...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: size.width * 0.035),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Add Image Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _pickImageAndAddCard,
            icon: Icon(Icons.add),
            label: Text("Add Image"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageDescription {
  File imageFile;
  TextEditingController descController = TextEditingController();

  _ImageDescription({required this.imageFile});
}
