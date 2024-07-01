import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: M2L2(),
  ));
}

class M2L2 extends StatefulWidget {
  @override
  _M2L2State createState() => _M2L2State();
}

class _M2L2State extends State<M2L2> {
  List<Offset> points = [];
  List<String> icons = [
    'assets/house.png',
    'assets/shop.png',
    'assets/hospital.png',
    'assets/temple.png',
    'assets/school.png',
    'assets/pharmacy.png',
    'assets/vegetableshop.png',
    'assets/meatshop.png',
  ];

  List<String> labels = [
    'House',
    'Shop',
    'Hospital',
    'Temple',
    'School',
    'Pharmacy',
    'Vegetable Shop',
    'Meat Shop',
  ];

  List<Offset> selectedPoints = [];
  List<Offset> drawnPath = [];
  List<ui.Image> images = [];
  int hoveredIndex = -1;

  // Define the correct path from house to school
  List<int> correctPathIndices = [0, 1, 2, 3];
  List<Offset> correctPath = [];
  int wrongAttempts = 0;
  bool showHint = false;
  bool showCorrectPath = false;
  bool levelCompleted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _loadAllImages();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadAllImages() async {
    for (String icon in icons) {
      final ByteData data = await rootBundle.load(icon);
      final ui.Codec codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final ui.FrameInfo fi = await codec.getNextFrame();
      images.add(fi.image);
    }
    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    _addPoint(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _addPoint(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_checkIfPathIsCorrect()) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You found the correct path!'),
        backgroundColor: Colors.green,
      ));
      wrongAttempts = 0; // Reset wrong attempts on success
      setState(() {
        levelCompleted = true;
      });
    } else {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wrong path. Try again.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        drawnPath.clear();
      });
      wrongAttempts++;
      if (wrongAttempts > 1) {
        setState(() {
          showHint = true;
        });
      }
    }
  }

  void _addPoint(Offset point) {
    setState(() {
      drawnPath.add(point);
    });
  }

  bool _checkIfPathIsCorrect() {
    correctPath.clear();
    for (int i = 0; i < correctPathIndices.length - 1; i++) {
      Offset start = points[correctPathIndices[i]];
      Offset end = points[correctPathIndices[i + 1]];
      correctPath.add(start);
      correctPath.add(end);
      bool segmentCorrect = drawnPath.any((p) =>
          (p.dx - start.dx) * (end.dy - start.dy) ==
          (p.dy - start.dy) * (end.dx - start.dx));
      if (!segmentCorrect) {
        return false;
      }
    }
    return true;
  }

  void _showHint() {
    setState(() {
      correctPath.clear();
      for (int i = 0; i < correctPathIndices.length - 1; i++) {
        Offset start = points[correctPathIndices[i]];
        Offset end = points[correctPathIndices[i + 1]];
        correctPath.add(start);
        correctPath.add(end);
      }
      showHint = false;
      showCorrectPath = true;
    });
  }

  void _reset() {
    setState(() {
      drawnPath.clear();
      wrongAttempts = 0;
      showHint = false;
      showCorrectPath = false;
      levelCompleted = false;
      correctPath.clear(); // Clear the correct path hints
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // Adjust box size based on screen size
    double boxWidth = screenSize.width / 6;
    double boxHeight = screenSize.height / 4;

    points = [
      Offset(screenSize.width / 8, screenSize.height / 4), // House
      Offset(screenSize.width * 3 / 8, screenSize.height / 4), // Shop
      Offset(screenSize.width * 5 / 8, screenSize.height / 4), // Hospital
      Offset(screenSize.width * 7 / 8, screenSize.height / 4), // Temple
      Offset(screenSize.width / 8, screenSize.height * 3 / 4), // School
      Offset(screenSize.width * 3 / 8, screenSize.height * 3 / 4), // Pharmacy
      Offset(screenSize.width * 5 / 8, screenSize.height * 3 / 4), // Vegetable Shop
      Offset(screenSize.width * 7 / 8, screenSize.height * 3 / 4), // Meat Shop
    ];

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              painter: PathPainter(
                points,
                images,
                labels,
                selectedPoints,
                drawnPath,
                showCorrectPath ? correctPath : [],
                boxWidth,
                boxHeight,
                screenSize,
                hoveredIndex,
              ),
              child: Container(),
            ),
          ),
          if (showHint)
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _showHint,
                child: Text('Show Hint'),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: _reset,
              child: Text('Reset'),
            ),
          ),
          if (levelCompleted)
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  // Proceed to next level
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Next Level Coming Soon!'),
                  ));
                },
                child: Text('Next Level'),
              ),
            ),
        ],
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final List<ui.Image> images;
  final List<String> labels;
  final List<Offset> selectedPoints;
  final List<Offset> drawnPath;
  final List<Offset> correctPath;
  final double boxWidth;
  final double boxHeight;
  final Size screenSize;
  final int hoveredIndex;

  PathPainter(this.points, this.images, this.labels, this.selectedPoints,
      this.drawnPath, this.correctPath, this.boxWidth, this.boxHeight,
      this.screenSize, this.hoveredIndex);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Paint pathPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Paint correctPathPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      if (i < images.length) {
        final ui.Image image = images[i];
        final offset = points[i];
        _drawBoxWithShadow(canvas, offset, boxWidth, boxHeight);
        _drawImage(canvas, image, offset, boxWidth / 2);
        _drawLabel(canvas, '${i + 1}. ${labels[i]}', offset, boxWidth / 2, screenSize);
      }
    }

    if (drawnPath.isNotEmpty) {
      canvas.drawPoints(ui.PointMode.polygon, drawnPath, pathPaint);
    }

    if (correctPath.isNotEmpty) {
      for (int i = 0; i < correctPath.length - 1; i += 2) {
        canvas.drawLine(correctPath[i], correctPath[i + 1], correctPathPaint);
      }
    }
  }

  void _drawBoxWithShadow(
      Canvas canvas, Offset offset, double width, double height) {
    final rect = Rect.fromCenter(center: offset, width: width, height: height);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3) // Adjusted shadow opacity
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // Adjusted blur radius

    final boxPaint = Paint()..color = Colors.white.withOpacity(0.7);

    canvas.drawRect(rect.shift(Offset(5, 5)), shadowPaint); // Adjusted shadow offset
    canvas.drawRect(rect, boxPaint);
  }

  void _drawImage(Canvas canvas, ui.Image image, Offset offset, double size) {
    final src =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromCenter(center: offset, width: size, height: size)
        .translate(0, -boxHeight / 4);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  void _drawLabel(Canvas canvas, String label, Offset offset, double size,
      Size screenSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Center the text within the box
    final offsetLabel = Offset(offset.dx - (textPainter.width / 2),
        offset.dy + (size / 2) - (textPainter.height / 2));
    textPainter.paint(canvas, offsetLabel);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) {
    return true;
  }
}