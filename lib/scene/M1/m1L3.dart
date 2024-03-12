import 'package:flutter/material.dart';

class M1L3 extends StatefulWidget {
  @override
  _M1L3State createState() => _M1L3State();
}

class _M1L3State extends State<M1L3> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 1 Level 3'),
      ),
      body: Center(
        child: Text(
          'This is Module 1 Level 3',
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
    home: M1L3(),
  ));
}
