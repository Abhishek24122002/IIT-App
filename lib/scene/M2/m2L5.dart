import 'package:flutter/material.dart';

class M2L5 extends StatefulWidget {
  @override
  _M2L5State createState() => _M2L5State();
}

class _M2L5State extends State<M2L5> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 Level 5'),
      ),
      body: Center(
        child: Text(
          'This is Module 2 Level 5',
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
    home: M2L5(),
  ));
}
