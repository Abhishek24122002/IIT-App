import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: M2L1(),
  ));
}

class M2L1 extends StatefulWidget {
  @override
  _M2L1State createState() => _M2L1State();
}

class _M2L1State extends State<M2L1> {
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

  List<Offset> selectedPoints = [Offset(0, 0)]; // Start with the house selected
  List<ui.Image> images = [];

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

  void _onTapDown(TapDownDetails details) {
    Size screenSize = MediaQuery.of(context).size;

    double boxWidth = screenSize.width / 6;
    double boxHeight = screenSize.height / 4;

    for (int i = 0; i < points.length; i++) {
      Rect boxRect = Rect.fromCenter(
          center: points[i], width: boxWidth, height: boxHeight);
      if (boxRect.contains(details.localPosition)) {
        Offset circleOffset =
            Offset(points[i].dx, points[i].dy + boxHeight / 2 + 20);
        setState(() {
          if (!selectedPoints.contains(circleOffset)) {
            selectedPoints.add(circleOffset);
          } else {
            selectedPoints.remove(circleOffset);
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // Adjust box size based on screen size
    double boxWidth = screenSize.width / 6;
    double boxHeight = screenSize.height / 4;

    points = [
      Offset(screenSize.width / 8, screenSize.height / 4),
      Offset(screenSize.width * 3 / 8, screenSize.height / 4),
      Offset(screenSize.width * 5 / 8, screenSize.height / 4),
      Offset(screenSize.width * 7 / 8, screenSize.height / 4),
      Offset(screenSize.width / 8, screenSize.height * 3 / 4),
      Offset(screenSize.width * 3 / 8, screenSize.height * 3 / 4),
      Offset(screenSize.width * 5 / 8, screenSize.height * 3 / 4),
      Offset(screenSize.width * 7 / 8, screenSize.height * 3 / 4),
    ];

    if (selectedPoints.length == 1) {
      selectedPoints[0] = Offset(
          screenSize.width / 8, screenSize.height / 4 + boxHeight / 2 + 20);
    }

    return Scaffold(
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: CustomPaint(
          painter: PathPainter(points, images, labels, selectedPoints, boxWidth,
              boxHeight, screenSize),
          child: Container(),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final List<ui.Image> images;
  final List<String> labels;
  final List<Offset> selectedPoints;
  final double boxWidth;
  final double boxHeight;
  final Size screenSize;

  PathPainter(this.points, this.images, this.labels, this.selectedPoints,
      this.boxWidth, this.boxHeight, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    Paint circlePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length; i++) {
      if (i < images.length) {
        final ui.Image image = images[i];
        final offset = points[i];
        _drawBoxWithShadow(canvas, offset, boxWidth, boxHeight);
        _drawImage(canvas, image, offset, boxWidth / 2);
        _drawLabel(canvas, labels[i], offset, boxWidth / 2, screenSize);

        Offset circleOffset = Offset(offset.dx, offset.dy + boxHeight / 2 + 20);
        if (selectedPoints.contains(circleOffset)) {
          _drawSelectedCircle(canvas, circleOffset, 10.0, circlePaint);
        }
      }
    }

    // Draw path starting from the house (first box)
    if (selectedPoints.length > 1) {
      for (int i = 0; i < selectedPoints.length - 1; i++) {
        canvas.drawLine(selectedPoints[i], selectedPoints[i + 1], paint);
      }
    }
  }

  void _drawBoxWithShadow(
      Canvas canvas, Offset offset, double width, double height) {
    final rect = Rect.fromCenter(center: offset, width: width, height: height);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    final boxPaint = Paint()..color = Colors.white.withOpacity(0.7);

    canvas.drawRect(rect.shift(Offset(0, 10)), shadowPaint);
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

  void _drawSelectedCircle(
      Canvas canvas, Offset offset, double size, Paint circlePaint) {
    canvas.drawCircle(offset, size, circlePaint);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) {
    return true;
  }
}
