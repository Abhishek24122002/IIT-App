import 'package:flutter/material.dart';

class M1L5 extends StatefulWidget {
  @override
  _M1L5State createState() => _M1L5State();
}

class _M1L5State extends State<M1L5> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 1 Level 5'),
      ),
      body: Center(
        child: Text(
          'This is Module 1 Level 5',
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
    home: M1L5(),
  ));
}
