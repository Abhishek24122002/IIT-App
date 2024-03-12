import 'package:flutter/material.dart';

class M3L1 extends StatefulWidget {
  @override
  _M3L1State createState() => _M3L1State();
}

class _M3L1State extends State<M3L1> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 3 Level 1'),
      ),
      body: Center(
        child: Text(
          'This is Module 3 Level 1',
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
    home: M3L1(),
  ));
}
