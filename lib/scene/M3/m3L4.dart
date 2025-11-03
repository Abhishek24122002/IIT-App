  import 'package:alzymer/scene/M3/m3L4_2.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  import 'm3L2_old.dart';

  class M3L4 extends StatefulWidget {
    @override
    _M3L4State createState() => _M3L4State();
  }

  class _M3L4State extends State<M3L4> {
    int milkCounter = 0;
    int cheeseCounter = 0;
    int yogurtCounter = 0;
    int fruitCounter = 0;

    List<bool> milkVisibility = List.generate(3, (index) => true);
    List<bool> cheeseVisibility = List.generate(3, (index) => true);
    List<bool> yogurtVisibility = List.generate(3, (index) => true);
    List<bool> fruitVisibility =
        List.generate(3, (index) => true); // 🍎 Distractor

    final int milkPrice = 30;
    final int cheesePrice = 20;
    final int yogurtPrice = 10;
    final int fruitPrice = 60; // 🍎 Distractor price
    int totalRs = 100;

    int M3L4Point = 0;
    bool showHintOverlay = false;
    int hintStep = 0;
    final int itemsToBuy = 3;

    @override
    void initState() {
      super.initState();
      Firebase.initializeApp();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructions();
      });
    }

    String getCurrentUserUid() {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      return user?.uid ?? '';
    }

    void updateFirebaseDataM3L4() async {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        String userUid = getCurrentUserUid();

        if (userUid.isNotEmpty) {
          DocumentReference userDocRef =
              firestore.collection('users').doc(userUid);
          DocumentReference scoreDocRef =
              userDocRef.collection('score').doc('M3');

          await scoreDocRef.update({
            'M3L4Point': M3L4Point,
          });
        }
      } catch (e) {
        print('Error updating data: $e');
      }
    }

    void _showInstructions() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;

          return AlertDialog(
            title: Text(
              'Instructions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.7,
                maxWidth: screenWidth * 0.9,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        Column(
                          children: [
                            Image.asset('assets/Milk.png', width: 40, height: 40),
                            Text('Milk: ₹30', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('assets/cheese.png',
                                width: 40, height: 40),
                            Text('Cheese: ₹20', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('assets/yougurt.png',
                                width: 40, height: 40),
                            Text('Yogurt: ₹10', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('assets/Grapes.png',
                                width: 40, height: 40),
                            Text('Grapes: ₹60', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You have ₹100 to buy milk, cheese, and yogurt.\n'
                      'You must buy at least 1 of each item.\n'
                      'Maximum amount you can spend is ₹100.',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Try Again'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
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
        fruitCounter = 0;
        milkVisibility = List.generate(3, (index) => true);
        cheeseVisibility = List.generate(3, (index) => true);
        yogurtVisibility = List.generate(3, (index) => true);
        fruitVisibility = List.generate(3, (index) => true);
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

    void _pickFruit(int index) {
      setState(() {
        if (totalRs - fruitPrice >= 0 && fruitVisibility[index]) {
          fruitVisibility[index] = false;
          fruitCounter++;
          totalRs -= fruitPrice;
        }
      });
    }

    bool _hasBoughtAllItems() {
      return milkCounter > 0 && cheeseCounter > 0 && yogurtCounter > 0;
    }

    @override
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final isSmallScreen = screenWidth < 700;

      return Scaffold(
        appBar: AppBar(
          title: Text('Mall Dairy Shelf'),
          toolbarHeight: isSmallScreen ? 35 : 45,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final itemSize =
                isSmallScreen ? screenWidth * 0.12 : screenWidth * 0.1;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 12),
                child: Flex(
                  direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🧾 Left side - Cart & Info
                    Container(
                      width: isSmallScreen
                          ? double.infinity
                          : screenWidth * 0.3, // 30% width for large screen
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collected Items:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text('Milk: $milkCounter'),
                          Text('Cheese: $cheeseCounter'),
                          Text('Yogurt: $yogurtCounter'),
                          Text('Grapes: $fruitCounter'),
                          SizedBox(height: isSmallScreen ? 8 : 16),
                          Text(
                            'Remaining Rs: ₹$totalRs',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        

                          // Buttons
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _resetCart,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 8 : 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Empty Cart',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_hasBoughtAllItems()) {
                                      if (fruitCounter > 0) {
                                        _showErrorDialog(
                                            "You bought fruit! You can’t buy the wrong item.");
                                        return;
                                      }
                                      int totalSpent = (milkCounter * milkPrice) +
                                          (cheeseCounter * cheesePrice) +
                                          (yogurtCounter * yogurtPrice) +
                                          (fruitCounter * fruitPrice);
                                      if (totalSpent > 100) {
                                        _showErrorDialog(
                                            "You spent more than ₹100! Try again.");
                                        return;
                                      }
                                      M3L4Point = 1;
                                      updateFirebaseDataM3L4();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => M3L4_2()),
                                      );
                                    } else {
                                      _showErrorDialog(
                                          "You must buy at least one milk, cheese, and yogurt!");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 8 : 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Buy Now',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 🛒 Right side - Shelves
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue, width: 4),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildColumn(milkVisibility, _pickMilk,
                                  'assets/Milk.png', itemSize),
                              _buildColumn(cheeseVisibility, _pickCheese,
                                  'assets/cheese.png', itemSize),
                              _buildColumn(yogurtVisibility, _pickYogurt,
                                  'assets/yougurt.png', itemSize),
                              _buildColumn(fruitVisibility, _pickFruit,
                                  'assets/Grapes.png', itemSize),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    Widget _buildColumn(List<bool> visibilityList, Function(int) onTap,
        String imagePath, double size,
        {bool isDistractor = false}) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return visibilityList[index]
              ? GestureDetector(
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(
                      imagePath,
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                      color: isDistractor ? Colors.redAccent : null,
                    ),
                  ),
                )
              : SizedBox(height: size + 10);
        }),
      );
    }
  }

  void main() {
    runApp(MaterialApp(home: M3L4()));
  }
