import 'dart:math';
import 'package:alzymer/scene/M3/m3L4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M3L3 extends StatefulWidget {
  @override
  _M3L3State createState() => _M3L3State();
}

class _M3L3State extends State<M3L3> {
  int collectedPotatoes = 0;
  bool showPopup = true;

  List<List<String>> baskets = [
    ['Cabbage', 'Cabbage','Cabbage', 'Cabbage', 'Carrot', 'Carrot', 'Onion', 'Onion', 'Cabbage', 'Carrot','Potato', 'Potato', 'Potato'],
    ['Carrot','Carrot','Carrot', 'Cabbage', 'Onion','Onion', 'Onion', 'Cabbage', 'Carrot', 'Carrot','Potato', 'Potato', 'Potato'],
    ['Onion', 'Onion','Cabbage', 'Cabbage', 'Cabbage', 'Cabbage', 'Carrot', 'Onion','Onion',  'Potato', 'Potato', 'Potato', 'Potato'],
  ];

  List<List<Offset>> vegetablePositions = [[], [], []];

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Generate random positions only once when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateVegetablePositions();
      showInstructionDialog();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Generate random positions for the vegetables in each basket
  void _generateVegetablePositions() {
    Random random = Random();
    double basketSize = 200.0; // Increased basket size
    double vegetableSize = 70.0; // Increased vegetable size

    for (int basketIndex = 0; basketIndex < baskets.length; basketIndex++) {
      List<Offset> usedPositions = []; // Track used positions to avoid overlap

      for (int i = 0; i < baskets[basketIndex].length; i++) {
        Offset position = Offset.zero; // Initialize with a default value
        bool positionFound = false;

        // Attempt to place the vegetable without overlap
        for (int attempt = 0; attempt < 10; attempt++) {
          double randomTop = random.nextDouble() * (basketSize - vegetableSize);
          double randomLeft = random.nextDouble() * (basketSize - vegetableSize);
          position = Offset(randomLeft, randomTop);

          // Check for overlap
          bool overlaps = usedPositions.any((usedPosition) {
            return (position - usedPosition).distance < vegetableSize;
          });

          if (!overlaps) {
            positionFound = true;
            usedPositions.add(position);
            break;
          }
        }

        // If a position without overlap wasn't found, allow overlap
        if (!positionFound) {
          double randomTop = random.nextDouble() * (basketSize - vegetableSize);
          double randomLeft = random.nextDouble() * (basketSize - vegetableSize);
          position = Offset(randomLeft, randomTop);
        }

        vegetablePositions[basketIndex].add(position);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find the Potatoes - Level 3'),
      ),
      body: Stack(
        children: [
          if (!showPopup) _buildGameScreen(),
          if (showPopup) _buildPopupMessage(),
          Positioned(
            top: 20,
            right: 20,
            child: _buildCollectedPotatoesCounter(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find and collect all the potatoes!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildBasketRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasketRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBasket(0),
        _buildBasket(1),
        _buildBasket(2),
      ],
    );
  }

  Widget _buildBasket(int basketIndex) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/basket.png',
          width: 270,
          height: 270,
          fit: BoxFit.cover,
        ),
        Container(
          width: 200,
          height: 200,
          child: _buildVegetableStack(basketIndex),
        ),
      ],
    );
  }

  Widget _buildVegetableStack(int basketIndex) {
    List<Widget> vegetableWidgets = [];

    for (int i = 0; i < baskets[basketIndex].length; i++) {
      String vegetable = baskets[basketIndex][i];
      Offset position = vegetablePositions[basketIndex][i];

      if (vegetable.isNotEmpty) {
        vegetableWidgets.add(
          Positioned(
            top: position.dy,
            left: position.dx,
            child: GestureDetector(
              onTap: () {
                if (vegetable == 'Potato') {
                  setState(() {
                    collectedPotatoes++;
                    baskets[basketIndex][i] = ''; // Remove the potato
                    if (collectedPotatoes == 10) { // 10 potatoes in total
                      showLevelCompleteDialog();
                    }
                  });
                }
              },
              child: Image.asset(
                'assets/$vegetable.png',
                height: 60, // Increased size
                width: 60,
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: vegetableWidgets,
    );
  }

  Widget _buildCollectedPotatoesCounter() {
    return Row(
      children: [
        Image.asset('assets/Potato.png', height: 60), // Larger potato icon
        SizedBox(width: 10),
        Text(
          '$collectedPotatoes',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPopupMessage() {
    return Center(
      child: AlertDialog(
        title: Text('Collect All Potatoes To Complete Level'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Potato.png', height: 80),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              setState(() {
                showPopup = false;
              });
            },
          ),
        ],
      ),
    );
  }

  void showInstructionDialog() {
    setState(() {
      showPopup = true;
    });
  }

  void showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Level Complete!'),
          content: Text('Congratulations! You collected all the potatoes.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Next Level'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(context, MaterialPageRoute(builder: (context) => M3L4()));
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: M3L3(),
  ));
}
