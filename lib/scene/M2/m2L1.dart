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
  List<Offset> points = [
    Offset(100, 100),
    Offset(200, 200),
    Offset(300, 100),
    Offset(400, 200),
    Offset(500, 100),
    Offset(600, 200),
    Offset(700, 100),
    Offset(800, 200),
    Offset(900, 100),
    Offset(1000, 200),
  ];

  List<String> icons = [
    'assets/house.png',
    'assets/shop.png',
    'assets/hospital.png',
    'assets/temple.png',
    'assets/school.png',
    'assets/pharmacy.png',
    'assets/vegetableshop.png',
    'assets/meatshop.png',
    'assets/dairyshop.png',
    'assets/barbershop.png',
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
    'Dairy Shop',
    'Barber Shop',
  ];

  List<Offset> selectedPoints = [
    Offset(100, 150)
  ]; // Start with the house selected
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
    for (int i = 0; i < points.length; i++) {
      Offset circleOffset = Offset(points[i].dx, points[i].dy + 50);
      if ((details.localPosition - circleOffset).distance < 20) {
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
    return Scaffold(
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: CustomPaint(
          painter: PathPainter(points, images, labels, selectedPoints),
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

  PathPainter(this.points, this.images, this.labels, this.selectedPoints);

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
        _drawImage(canvas, image, offset, 60.0);
        _drawLabel(canvas, labels[i], offset, 60.0);

        Offset circleOffset = Offset(offset.dx, offset.dy + 50);
        if (selectedPoints.contains(circleOffset)) {
          _drawSelectedCircle(canvas, circleOffset, 10.0, circlePaint);
        }
      }
    }

    if (selectedPoints.length > 1) {
      for (int i = 0; i < selectedPoints.length - 1; i++) {
        canvas.drawLine(selectedPoints[i], selectedPoints[i + 1], paint);
      }
    }
  }

  void _drawImage(Canvas canvas, ui.Image image, Offset offset, double size) {
    final src =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromCenter(center: offset, width: size, height: size);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  void _drawLabel(Canvas canvas, String label, Offset offset, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offsetLabel = Offset(
        offset.dx - (textPainter.width / 2), offset.dy + (size / 2) + 35);
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
