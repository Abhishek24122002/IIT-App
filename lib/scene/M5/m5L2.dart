import 'package:flutter/material.dart';

import 'm5L3.dart';

class M5L2 extends StatefulWidget {
  @override
  _M5L2State createState() => _M5L2State();
}

class _M5L2State extends State<M5L2> {
  int milkCounter = 0;
  int cheeseCounter = 0;
  int yogurtCounter = 0;
  List<bool> milkVisibility = List.generate(8, (index) => true);
  List<bool> cheeseVisibility = List.generate(8, (index) => true);
  List<bool> yogurtVisibility = List.generate(8, (index) => true);

  final int milkPrice = 30;
  final int cheesePrice = 20;
  final int yogurtPrice = 10;
  int totalRs = 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'You have ₹100 to buy milk, cheese, and yogurt.\n'
                  'You must buy at least 1 of each item. Maximum amount you can spend is ₹100.\n'
                  'Prices are as follows:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Image.asset('assets/Milk.png', width: 50, height: 50),
                        Text('Milk: ₹30'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset('assets/cheese.png', width: 50, height: 50),
                        Text('Cheese: ₹20'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset('assets/yougurt.png', width: 50, height: 50),
                        Text('Yogurt: ₹10'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  void _resetCart() {
    setState(() {
      milkCounter = 0;
      cheeseCounter = 0;
      yogurtCounter = 0;
      milkVisibility = List.generate(8, (index) => true);
      cheeseVisibility = List.generate(8, (index) => true);
      yogurtVisibility = List.generate(8, (index) => true);
      totalRs = 100;
    });
  }

  void _pickMilk(int index) {
    setState(() {
      if (totalRs - milkPrice >= 0 && milkVisibility[index]) {
        milkVisibility[index] = false;
        milkCounter++;
        totalRs -= milkPrice;
      }
    });
  }

  void _pickCheese(int index) {
    setState(() {
      if (totalRs - cheesePrice >= 0 && cheeseVisibility[index]) {
        cheeseVisibility[index] = false;
        cheeseCounter++;
        totalRs -= cheesePrice;
      }
    });
  }

  void _pickYogurt(int index) {
    setState(() {
      if (totalRs - yogurtPrice >= 0 && yogurtVisibility[index]) {
        yogurtVisibility[index] = false;
        yogurtCounter++;
        totalRs -= yogurtPrice;
      }
    });
  }

  bool _hasBoughtAllItems() {
    return milkCounter > 0 && cheeseCounter > 0 && yogurtCounter > 0;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mall Dairy Shelf'),
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Collected items and total Rs
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collected Items:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Milk: $milkCounter', style: TextStyle(fontSize: 16)),
                    Text('Cheese: $cheeseCounter', style: TextStyle(fontSize: 16)),
                    Text('Yogurt: $yogurtCounter', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text(
                      'Remaining Rs: ₹$totalRs',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Empty Cart'),
                    ),
                    if (_hasBoughtAllItems())
                      SizedBox(height: 20),
                    if (_hasBoughtAllItems())
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to M5L3 or perform the required action
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => M5L3()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Buy Now'),
                      ),
                  ],
                ),
              ),
            ),
            // Right side: Shelf with Divider between rows
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Shelf Container with Blue Border
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.blue,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Row for Milk
                          Container(
                            width: screenWidth * 0.5,
                            height: 70,
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: 8,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return milkVisibility[index]
                                    ? GestureDetector(
                                        onTap: () => _pickMilk(index),
                                        child: Image.asset(
                                          'assets/Milk.png',
                                          fit: BoxFit.contain,
                                          height: 40,
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                          // Divider
                          Divider(
                            color: Colors.grey,
                            thickness: 3,
                            height: 30,
                          ),
                          // Row for Cheese
                          Container(
                            width: screenWidth * 0.5,
                            height: 70,
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: 8,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return cheeseVisibility[index]
                                    ? GestureDetector(
                                        onTap: () => _pickCheese(index),
                                        child: Image.asset(
                                          'assets/cheese.png',
                                          fit: BoxFit.contain,
                                          height: 30,
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                          // Divider
                          Divider(
                            color: Colors.grey,
                            thickness: 3,
                            height: 30,
                          ),
                          // Row for Yogurt
                          Container(
                            width: screenWidth * 0.5,
                            height: 70,
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: 8,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return yogurtVisibility[index]
                                    ? GestureDetector(
                                        onTap: () => _pickYogurt(index),
                                        child: Image.asset(
                                          'assets/yougurt.png',
                                          fit: BoxFit.contain,
                                          height: 40,
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: M5L2(),
  ));
}
