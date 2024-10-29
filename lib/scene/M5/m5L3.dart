import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class M5L3 extends StatefulWidget {
  @override
  _M5L3State createState() => _M5L3State();
}

class _M5L3State extends State<M5L3> {
  int eggsCounter = 0;
  int breadCounter = 0;
  int flourCounter = 0;
  List<bool> eggsVisibility = List.generate(6, (index) => true);
  List<bool> breadVisibility = List.generate(6, (index) => true);
  List<bool> flourVisibility = List.generate(6, (index) => true);
  final int eggsPrice = 30;
  final int breadPrice = 20;
  final int flourPrice = 10;
  int totalRs = 100;
  bool showHintOverlay = false;
  int hintStep = 0;
  final int itemsToBuy = 3;
  int M5L3Point = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  void updateFirebaseDataM5L3() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference userDocRef = firestore.collection('users').doc(userUid);
        DocumentReference scoreDocRef = userDocRef.collection('score').doc('M5');

        await scoreDocRef.update({
          'M5L3Point': M5L3Point,
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
        return AlertDialog(
          title: Text('Instructions'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'You have ₹100 to buy eggs, bread, and flour.\n'
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
                        Image.asset('assets/Eggs.png', width: 50, height: 50),
                        Text('eggs: ₹30'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset('assets/Bread.png', width: 50, height: 50),
                        Text('bread: ₹20'),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset('assets/Flour.png', width: 50, height: 50),
                        Text('flour: ₹10'),
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
                _showAnnouncement();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAnnouncement() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, size: 80, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              'Attention please! Today we have 10% off on branded clothes and footwear.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    },
  );
  // Function to show hint overlay

  await _audioPlayer.setSource(AssetSource('announcement.mp3'));
  _audioPlayer.setReleaseMode(ReleaseMode.stop);

  // First playback
  await _audioPlayer.play(AssetSource('announcement.mp3'));
  await Future.delayed(Duration(seconds: 5));

  // Stop and replay
  await _audioPlayer.stop();
  await _audioPlayer.play(AssetSource('announcement.mp3'));
  await Future.delayed(Duration(seconds: 5));

  _audioPlayer.stop();
  Navigator.of(context).pop();
}


  void _resetCart() {
    setState(() {
      eggsCounter = 0;
      breadCounter = 0;
      flourCounter = 0;
      eggsVisibility = List.generate(6, (index) => true);
      breadVisibility = List.generate(6, (index) => true);
      flourVisibility = List.generate(6, (index) => true);
      totalRs = 100;
    });
  }

  void _pickeggs(int index) {
    setState(() {
      if (totalRs - eggsPrice >= 0 && eggsVisibility[index]) {
        eggsVisibility[index] = false;
        eggsCounter++;
        totalRs -= eggsPrice;
      }
    });
  }

  void _pickbread(int index) {
    setState(() {
      if (totalRs - breadPrice >= 0 && breadVisibility[index]) {
        breadVisibility[index] = false;
        breadCounter++;
        totalRs -= breadPrice;
      }
    });
  }

  void _pickflour(int index) {
    setState(() {
      if (totalRs - flourPrice >= 0 && flourVisibility[index]) {
        flourVisibility[index] = false;
        flourCounter++;
        totalRs -= flourPrice;
      }
    });
  }

  bool _hasBoughtAllItems() {
    return eggsCounter > 0 && breadCounter > 0 && flourCounter > 0;
  }
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
 int totalUniqueItemsInCart() {
  int uniqueItemCount = 0;
  
  // Count unique items in cart
  if (eggsCounter > 0) uniqueItemCount++;
  if (breadCounter > 0) uniqueItemCount++;
  if (flourCounter > 0) uniqueItemCount++;

  // Add logic here if there is a fourth unique item to track
  // e.g., `if (anotherCounter > 0) uniqueItemCount++;`
  
  return uniqueItemCount;
}

// To show the remaining unique items in the hint
int remainingUniqueItemsToBuy() {
  return 3 - totalUniqueItemsInCart();
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mall Dairy Shelf'),
        toolbarHeight: 40,
        actions: [
          TextButton(
            onPressed: () {
              if (hintStep == 0) {
                // First hint: Show remaining balance
                _showHintOverlay('Remaining balance: $totalRs Rupees.');
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
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.lightGreen[0],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collected Items:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Eggs: $eggsCounter', style: TextStyle(fontSize: 16)),
                    Text('Bread: $breadCounter', style: TextStyle(fontSize: 16)),
                    Text('Flour: $flourCounter', style: TextStyle(fontSize: 16)),
                    
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
                      ElevatedButton(
                        onPressed: () {
                          M5L3Point = 1;
                          updateFirebaseDataM5L3();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => M3L2()),
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
                          // Row for eggs
                          Container(
                            width: screenWidth * 0.5,
                            height: 70,
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: 6,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return eggsVisibility[index]
                                    ? GestureDetector(
                                        onTap: () => _pickeggs(index),
                                        child: Image.asset(
                                          'assets/Eggs.png',
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
                          // Row for bread
                          Container(
                            width: screenWidth * 0.5,
                            height: 70,
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: 6,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return breadVisibility[index]
                                    ? GestureDetector(
                                        onTap: () => _pickbread(index),
                                        child: Image.asset(
                                          'assets/Bread.png',
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
                          // Row for flour
                          Container(
                            width: screenWidth * 0.5,
                            height: 70,
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 0,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: 6,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return flourVisibility[index]
                                    ? GestureDetector(
                                        onTap: () => _pickflour(index),
                                        child: Image.asset(
                                          'assets/Flour.png',
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
