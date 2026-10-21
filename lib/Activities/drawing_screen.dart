import 'package:flutter/material.dart';
import '../responsive.dart'; // make sure this file is imported

class ScribbleScreen extends StatefulWidget {
  @override
  _ScribbleScreenState createState() => _ScribbleScreenState();
}

class _ScribbleScreenState extends State<ScribbleScreen> {
  final GlobalKey _canvasKey = GlobalKey();

  List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  bool isEraser = false;

  @override
  Widget build(BuildContext context) {
    final double titleFontSize = Responsive.getResponsiveFontSize(
      context,
      18,
      22,
      26,
    );
    final double iconSize = Responsive.getResponsiveFontSize(
      context,
      22,
      26,
      30,
    );
    final double canvasPadding = Responsive.responsivePadding(
      context,
      12,
      20,
      32,
    );
    final double canvasBorderRadius = Responsive.getResponsiveFontSize(
      context,
      10,
      14,
      18,
    );
    final double canvasHeight =
        Responsive.isTablet(context)
            ? MediaQuery.of(context).size.height * 0.95
            : MediaQuery.of(context).size.height * 0.90;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Scribble Pad', style: TextStyle(fontSize: titleFontSize)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.cleaning_services, size: iconSize),
            tooltip: 'Clear',
            onPressed: () {
              setState(() {
                lines.clear();
                currentLine = null;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.auto_fix_high,
              color: isEraser ? Colors.blue : Colors.grey,
              size: iconSize,
            ),
            tooltip: 'Eraser',
            onPressed: () {
              setState(() {
                isEraser = !isEraser;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          height: canvasHeight,
          margin: EdgeInsets.all(canvasPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(canvasBorderRadius),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(canvasBorderRadius),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: RepaintBoundary(
                key: _canvasKey,
                child: CustomPaint(
                  painter: DrawingPainter(lines, currentLine),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.globalToLocal(details.globalPosition);

    setState(() {
      currentLine = DrawnLine(
        path: [pos],
        color: isEraser ? Colors.white : Colors.black,
        width: 4.0,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || currentLine == null) return;
    final pos = box.globalToLocal(details.globalPosition);

    setState(() {
      currentLine = DrawnLine(
        path: List.from(currentLine!.path)..add(pos),
        color: currentLine!.color,
        width: currentLine!.width,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (currentLine != null) {
        lines.add(currentLine!);
        currentLine = null;
      }
    });
  }
}

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  DrawnLine({required this.path, required this.color, required this.width});
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  DrawingPainter(this.lines, this.currentLine);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    for (final line in [...lines, if (currentLine != null) currentLine!]) {
      paint.color = line.color;
      paint.strokeWidth = line.width;
      for (int i = 0; i < line.path.length - 1; i++) {
        canvas.drawLine(line.path[i], line.path[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
