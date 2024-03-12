import 'package:flutter/material.dart';

class M5L3 extends StatefulWidget {
  @override
  _M5L3State createState() => _M5L3State();
}

class _M5L3State extends State<M5L3> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 5 Level 3'),
      ),
      body: Center(
        child: Text(
          'This is Module 5 Level 3',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup code here
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: M5L3(),
  ));
}
