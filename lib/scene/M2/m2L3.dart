import 'package:flutter/material.dart';

class M2L3 extends StatefulWidget {
  @override
  _M2L3State createState() => _M2L3State();
}

class _M2L3State extends State<M2L3> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 Level 3'),
      ),
      body: Center(
        child: Text(
          'This is Module 2 Level 3',
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
    home: M2L3(),
  ));
}
