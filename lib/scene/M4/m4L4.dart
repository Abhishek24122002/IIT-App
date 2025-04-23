import 'package:flutter/material.dart';

class M4L4 extends StatefulWidget {
  @override
  _M4L4State createState() => _M4L4State();
}

class _M4L4State extends State<M4L4> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 4 Level 4'),
      ),
      body: Center(
        child: Text(
          'This is Module 4 Level 4',
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

