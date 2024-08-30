import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for controlling screen orientation
import 'package:alzymer/scene/M3/m3L3.dart';

class M3L2 extends StatefulWidget {
  @override
  _M3L2State createState() => _M3L2State();
}

class _M3L2State extends State<M3L2> {
  List<Map<String, String>> stores = [
    {'image': 'assets/Cloth_Store.png', 'name': 'Cloth Store'},
    {'image': 'assets/Fruit_Store.png', 'name': 'Fruit & Vegetable Store'},
    {'image': 'assets/Toy_Store.png', 'name': 'Toy Store'},
    {'image': 'assets/Food_Store.png', 'name': 'Food Store'},
  ];

  int fruitStoreIndex = 0;
  bool showNames = false;
  bool showHintButton = false;

  @override
  void initState() {
    super.initState();
    stores.shuffle();
    fruitStoreIndex = stores.indexWhere((store) => store['image'] == 'assets/Fruit_Store.png');

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Show instruction dialog when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });

    // Display the "Show Hint" button after 10 seconds
    Timer(Duration(seconds: 10), () {
      setState(() {
        showHintButton = true;
      });
    });
  }

  @override
  void dispose() {
    // Reset preferred orientations when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions to complete level'),
          content: Text(
              'You are asked to bring Fruits and Vegetables. \n\nSelect the correct vendor to buy the items. \n\nFor correct selection, you will be rewarded with a point.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _revealNames() {
    setState(() {
      showNames = true;
      showHintButton = false; // Hide hint button once the names are revealed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 3 Level 2'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shop Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return GestureDetector(
                onTap: () {
                  if (index == fruitStoreIndex) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => M3L3()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wrong answer!')),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Card(
                        child: Image.asset(
                          stores[index]['image']!,
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Conditionally show the shop names based on showNames flag
                    Text(
                      showNames ? stores[index]['name']! : '',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          // Show hint button after 10 seconds, but keep alignment constant
          Visibility(
            visible: showHintButton && !showNames,
            child: ElevatedButton(
              onPressed: _revealNames,
              child: Text('Show Hint'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: M3L2(),
  ));
}
