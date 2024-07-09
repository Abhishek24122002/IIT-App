// import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_joystick/flutter_joystick.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;

// class M2L5 extends StatefulWidget {
//   @override
//   _M2L5State createState() => _M2L5State();
// }

// class _M2L5State extends State<M2L5> {
//   Offset characterPosition = Offset(50, 350);
//   final double speed = 4.0; // Speed factor to increase movement speed


//   void onJoystickUpdate(double x, double y) {
//     double distance = sqrt(x * x + y * y)*speed;
//     double angle = atan2(y, x);

//     Offset newPosition = Offset(
//       characterPosition.dx + distance * cos(angle),
//       characterPosition.dy + distance * sin(angle),
//     );

//     if (isOnPath(newPosition)) {
//       setState(() {
//         characterPosition = newPosition;
//       });
//     }
//   }

//   bool isOnPath(Offset position) {
//     // Define the curved path
//     Path path = Path();
//     path.moveTo(50, 350);
//     path.quadraticBezierTo(100, -100, 300, 300);

//     PathMetrics pathMetrics = path.computeMetrics();
//     for (PathMetric metric in pathMetrics) {
//       for (double i = 0; i < metric.length; i += 1.0) {
//         Tangent? tangent = metric.getTangentForOffset(i);
//         if (tangent != null) {
//           Offset point = tangent.position;
//           if ((position - point).distance <= 15) {
//             return true;
//           }
//         }
//       }
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         CustomPaint(
//           size: Size(double.infinity, double.infinity),
//           painter: PathPainter(),
//         ),
//         Positioned(
//           left: characterPosition.dx - 10,
//           top: characterPosition.dy - 10,
//           child: Icon(Icons.circle, color: Colors.red, size: 25),
//         ),
//         Align(
//           alignment: Alignment.bottomRight,
//           child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Joystick(
//               mode: JoystickMode.all,
//               listener: (details) {
//                 onJoystickUpdate(details.x, details.y);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class PathPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.orange
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 25.0;

//     Path path = Path();
//     path.moveTo(50, 350);
//     path.quadraticBezierTo(100, -100, 300, 300);

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
