// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// void main() => runApp(TreasureMapApp());

// class TreasureMapApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Treasure Map',
//       home: M2L4(),
//     );
//   }
// }

// class M2L4 extends StatefulWidget {
//   @override
//   _M2L4State createState() => _M2L4State();
// }

// class _M2L4State extends State<M2L4> {
//   late GoogleMapController mapController;

//   final LatLng _startingPoint = LatLng(37.7749, -122.4194); // Example starting point
//   final LatLng _treasurePoint = LatLng(37.7849, -122.4094); // Example treasure point

//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};

//   @override
//   void initState() {
//     super.initState();
//     _markers.add(Marker(
//       markerId: MarkerId('start'),
//       position: _startingPoint,
//       infoWindow: InfoWindow(title: 'Start'),
//     ));
//     _markers.add(Marker(
//       markerId: MarkerId('treasure'),
//       position: _treasurePoint,
//       infoWindow: InfoWindow(title: 'Treasure'),
//     ));

//     _polylines.add(Polyline(
//       polylineId: PolylineId('route'),
//       points: [_startingPoint, _treasurePoint],
//       color: Colors.red,
//       width: 5,
//     ));
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Treasure Map'),
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _startingPoint,
//           zoom: 14.0,
//         ),
//         markers: _markers,
//         polylines: _polylines,
//       ),
//     );
//   }
// }
