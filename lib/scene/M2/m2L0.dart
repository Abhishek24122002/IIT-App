import 'package:flutter/material.dart';

class M2L0 extends StatefulWidget {
  @override
  _M2L0State createState() => _M2L0State();
}

class _M2L0State extends State<M2L0> {
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
    home: M2L0(),
  ));
}
