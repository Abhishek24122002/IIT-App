import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M3L4 extends StatefulWidget {
  @override
  _M3L4State createState() => _M3L4State();
}

class _M3L4State extends State<M3L4> {
  int collectedApples = 0;
  bool showPopup = true;
  List<List<String>> baskets = [
    ['Orange', 'Orange', 'Orange', 'Orange', 'Orange', 'Orange', 'Apple', 'Apple', 'Apple'],
    ['Mango', 'Mango', 'Mango', 'Apple', 'Apple', 'Apple', 'Apple', 'Apple', 'Apple'],
    ['Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato'],
  ];

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show instruction dialog when the screen loads
      showInstructionDialog();
    });
  }

  @override
  void dispose() {
    // Reset orientation to normal when exiting this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find the Apples - Level 4'),
      ),
      body: Stack(
        children: [
          if (!showPopup) _buildGameScreen(), // Show game content only if popup is not displayed
          Positioned(
            top: 20,
            right: 20,
            child: _buildCollectedApplesCounter(),
          ),
          if (showPopup) _buildPopupMessage(), // Show popup message if needed
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Find and collect all apples!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildBasketRow(),
        ],
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
    return Container(
      width: 200,
      height: 200,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        shrinkWrap: true,
        children: List.generate(baskets[basketIndex].length, (fruitIndex) {
          String fruit = baskets[basketIndex][fruitIndex];
          return fruit.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    if (fruit == 'Apple') {
                      setState(() {
                        collectedApples++;
                        baskets[basketIndex][fruitIndex] = ''; // Remove the apple
                        if (collectedApples == 9) { // Example: 9 apples in total
                          showLevelCompleteDialog();
                        }
                      });
                    }
                  },
                  child: Image.asset(
                    'assets/$fruit.png',
                    height: 50, // Larger fruit size
                    width: 50,
                  ),
                )
              : SizedBox.shrink(); // Empty space if the fruit is removed
        }),
      ),
    );
  }

  Widget _buildCollectedApplesCounter() {
    return Row(
      children: [
        Image.asset('assets/Apple.png', height: 50), // Larger apple icon
        SizedBox(width: 10),
        Text(
          '$collectedApples',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), // Larger font size
        ),
      ],
    );
  }

  Widget _buildPopupMessage() {
  return Center(
    child: AlertDialog(
      title: Text('Collect All Apples To Complete Level'),
      content: SingleChildScrollView( // Add SingleChildScrollView here
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            
            Image.asset('assets/Apple.png', height: 80),
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
          content: Text('Congratulations! You collected all the apples.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Next Level'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the next level or reset the game
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
    home: M3L4(),
  ));
}
