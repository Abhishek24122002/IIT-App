import 'package:flutter/material.dart';

class Three extends StatefulWidget {
  @override
  _ThreeState createState() => _ThreeState();
}

class _ThreeState extends State<Three> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Three'),
      ),
      body: Center(
        child: Text(
          'This is Page Three',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
