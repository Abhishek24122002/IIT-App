import 'package:flutter/material.dart';

class M2L1 extends StatefulWidget {
  @override
  _M2L1State createState() => _M2L1State();
}

class _M2L1State extends State<M2L1> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 Level 1'),
      ),
      body: Center(
        child: Text(
          'This is Module 2 Level 1',
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
    home: M2L1(),
  ));
}
