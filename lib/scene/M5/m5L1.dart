import 'dart:async';
import 'package:alzymer/scene/M5/m5L2.dart';
import 'package:flutter/material.dart';

class M5L1 extends StatefulWidget {
  @override
  _M5L1State createState() => _M5L1State();
}

class _M5L1State extends State<M5L1> {
  int tokenPoints = 10; // Initial balance
  bool showHintOverlay = false; // To control the visibility of hint overlay
  final int itemsToBuy = 4; // Target number of unique items to buy
  int hintStep = 0; // To track which hint to show
  List<Map<String, dynamic>> items = [
    {'name': 'Eggs', 'price': 3, 'quantity': 0, 'image': 'assets/Eggs.png'},
    {'name': 'Bread', 'price': 2, 'quantity': 0, 'image': 'assets/Bread.png'},
    {'name': 'Milk', 'price': 1, 'quantity': 0, 'image': 'assets/Milk.png'},
    {'name': 'Flour', 'price': 4, 'quantity': 0, 'image': 'assets/Flour.png'}
  ];

  @override
  void initState() {
    super.initState();
    // Show instructions when the level opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsDialog();
    });
  }

  // Function to display instructions when the level starts
  void _showInstructionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'You start with 10 token points. Your goal is to buy 4 different items using these points. Each item has a different price, so plan wisely.',
            style: TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Products:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Image.asset('assets/Eggs.png', height: 60, width: 60), // Small image
                    SizedBox(width: 10),
                    Text('Eggs - 3 token points'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset('assets/Bread.png', height: 60, width: 60), // Small image
                    SizedBox(width: 10),
                    Text('Bread - 2 token points'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset('assets/Milk.png', height: 60, width: 60), // Small image
                    SizedBox(width: 10),
                    Text('Milk - 1 token point'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset('assets/Flour.png', height: 60, width: 60), // Small image
                    SizedBox(width: 10),
                    Text('Flour - 4 token points'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Start Shopping'),
            ),
          ],
        );
      },
    );
  }

  // Function to calculate total unique items in the cart
  int totalUniqueItemsInCart() {
    return items.where((item) => item['quantity'] > 0).length;
  }

  // Function to update quantity and adjust token points
  void updateQuantity(int index, int change) {
    setState(() {
      final item = items[index];
      final int price = item['price'] as int; // Cast to int

      if (change == 1 && tokenPoints >= price) {
        // Add item, reduce token points
        items[index]['quantity'] =
            (items[index]['quantity'] + 1).clamp(0, 10).toInt();
        tokenPoints -= price;
      } else if (change == -1 && items[index]['quantity'] > 0) {
        // Remove item, increase token points
        items[index]['quantity'] =
            (items[index]['quantity'] - 1).clamp(0, 10).toInt();
        tokenPoints += price;
      }
    });
  }

  // Function to show remaining unique items in a popup if the user tries to check out with fewer than 4 unique items
  void _showRemainingItemsPopup(int remainingItems) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Incomplete Cart'),
          content: Text(
              'You need to add $remainingItems more item(s) to complete the purchase.'),
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

  // Function to handle the "Buy Now" button press
  void _onBuyNowPressed() {
    final int remainingItems = itemsToBuy - totalUniqueItemsInCart();
    if (remainingItems > 0) {
      _showRemainingItemsPopup(remainingItems); // Show popup for remaining unique items
    } else {
      // Navigate to the next level when 4 unique items are selected
      _navigateToNextLevel();
    }
  }

  // Function to navigate to the next level
  void _navigateToNextLevel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => M5L2()), // Replace with your next level screen
    );
  }

  // Function to show hint overlay
  void _showHintOverlay(String hintText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hint'),
          content: Text(hintText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the hint dialog
              },
              child: Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int remainingItems = itemsToBuy - totalUniqueItemsInCart();

    return Scaffold(
      appBar: AppBar(
        title: Text('Module 5 Level 1'),
        toolbarHeight: 40,
        actions: [
          TextButton(
            onPressed: () {
              if (hintStep == 0) {
                // First hint: Show remaining balance
                _showHintOverlay('Remaining balance: $tokenPoints token points.');
              } else if (hintStep == 1) {
                // Second hint: Show how many items are left to buy
                int remainingItemsToBuy = itemsToBuy - totalUniqueItemsInCart();
                _showHintOverlay('You need to buy $remainingItemsToBuy more items.');
              }
              hintStep = (hintStep + 1) % 2; // Cycle between two hints
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber, // Golden color
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              'Show Hint',
              style: TextStyle(color: Colors.black), // Text color black
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Cart items with fixed width
          Container(
            width: 130, // Fixed width for the cart section
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items in Cart:',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item['quantity'] > 0) {
                        return ListTile(
                          title: Text('${item['name']}'),
                          subtitle: Text('Quantity: ${item['quantity']}'),
                        );
                      }
                      return Container();
                    },
                  ),
                ),
                TextButton(
                  onPressed: _onBuyNowPressed,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green, // Buy button color
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    'Buy Now',
                    style: TextStyle(color: Colors.white), // Button text color
                  ),
                ),
              ],
            ),
          ),

         // Right side - Product grid
          Expanded(
            flex: 3, // Product grid gets the remaining space
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Horizontal scroll
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        color: Colors.lightGreen[100],
                        margin: EdgeInsets.all(8),
                        child: Container(
                          width: 150, // Width for each card
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Wrap the image in a Container with a fixed height
                              Container(
                                height: 80, // Fixed height for the image
                                child: Image.asset(
                                  item['image'],
                                  fit: BoxFit.contain, // Maintain aspect ratio
                                ),
                              ),
                              Text(
                                item['name'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () => updateQuantity(index, -1),
                                  ),
                                  Text(
                                    '${item['quantity']}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    onPressed: () => updateQuantity(index, 1),
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
