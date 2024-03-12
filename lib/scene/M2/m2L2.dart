import 'package:flutter/material.dart';

class M2L2 extends StatefulWidget {
  @override
  _M2L2State createState() => _M2L2State();
}

class _M2L2State extends State<M2L2> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 Level 2'),
      ),
      body: Center(
        child: Text(
          'This is Module 2 Level 2',
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
    home: M2L2(),
  ));
}
