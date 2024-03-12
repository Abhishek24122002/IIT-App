import 'package:flutter/material.dart';

class M4L1 extends StatefulWidget {
  @override
  _M4L1State createState() => _M4L1State();
}

class _M4L1State extends State<M4L1> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 4 Level 1'),
      ),
      body: Center(
        child: Text(
          'This is Module 4 Level 1',
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
    home: M4L1(),
  ));
}
