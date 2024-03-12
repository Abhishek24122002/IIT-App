import 'package:flutter/material.dart';

class M3L4 extends StatefulWidget {
  @override
  _M3L4State createState() => _M3L4State();
}

class _M3L4State extends State<M3L4> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 Level 4'),
      ),
      body: Center(
        child: Text(
          'This is Module 2 Level 4',
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
    home: M3L4(),
  ));
}
