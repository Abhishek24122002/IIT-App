import 'package:flutter/material.dart';

class M1L4 extends StatefulWidget {
  @override
  _M1L4State createState() => _M1L4State();
}

class _M1L4State extends State<M1L4> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 1 Level 4'),
      ),
      body: Center(
        child: Text(
          'This is Module 1 Level 4',
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
    home: M1L4(),
  ));
}
