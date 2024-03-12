import 'package:flutter/material.dart';

class M3L2 extends StatefulWidget {
  @override
  _M3L2State createState() => _M3L2State();
}

class _M3L2State extends State<M3L2> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 3 Level 2'),
      ),
      body: Center(
        child: Text(
          'This is Module 3 Level 2',
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
    home: M3L2(),
  ));
}
