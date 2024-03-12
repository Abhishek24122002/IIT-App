import 'package:flutter/material.dart';

class M5L1 extends StatefulWidget {
  @override
  _M5L1State createState() => _M5L1State();
}

class _M5L1State extends State<M5L1> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 5 Level 1'),
      ),
      body: Center(
        child: Text(
          'This is Module 5 Level 1',
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
    home: M5L1(),
  ));
}
