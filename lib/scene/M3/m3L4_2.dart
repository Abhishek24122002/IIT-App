import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alzymer/module_page.dart';

class M3L4_2 extends StatefulWidget {
  @override
  _M3L4_2State createState() => _M3L4_2State();
}

class _M3L4_2State extends State<M3L4_2> {
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
  int M3L4_2Score = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? errorMessage;

  int distractorCounter = 0;
  List<bool> distractorVisibility = List.generate(6, (index) => true);
  final int distractorPrice = 60;

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

  void updateFirebaseDataM3L4_2() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M3');

        await scoreDocRef.update({
          'M3L4_2Score': M3L4_2Score,
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
            'Instructions (Scroll to read complete instructions)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.7, // 70% of screen
              maxWidth: screenWidth * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Show images & prices first
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 15,
                    runSpacing: 10,
                    children: [
                      Column(
                        children: [
                          Image.asset('assets/Eggs.png', width: 40, height: 40),
                          Text('Eggs: ₹30', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset('assets/Bread.png',
                              width: 40, height: 40),
                          Text('Bread: ₹20', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset('assets/Flour.png',
                              width: 40, height: 40),
                          Text('Flour: ₹10', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // ✅ Instructions text below
                  Text(
                    'You have ₹100 to buy eggs, bread, and flour.\n'
                    'You must buy at least 1 of each item.\n'
                    'Maximum amount you can spend is ₹100.',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // center align button
          actions: [
            SizedBox(
              width: 80, // ✅ smaller width button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  textStyle: TextStyle(fontSize: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showAnnouncement(); // keep your announcement
                },
                child: Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }

  void onAudioComplete() {
    showConversationDialog();
  }

  void showConversationDialog() {
    List<Map<String, String>> conversation = [
      {'speaker': 'Friend', 'message': 'How are you'},
    ];

    String userResponse = "";
    String friendResponse = "";
    bool showItemSelection = false;
    List<String> selectedItems = [];
    List<String> items = [
      'Milk',
      'Cheese',
      'Yogurt',
      'Eggs',
      'Bread',
      'Flour',
      'Tea',
      'Coffee'
    ];

    ScrollController _scrollController = ScrollController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void scrollToBottom() {
              Future.delayed(Duration(milliseconds: 100), () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
            }

            void addConversation(String response, String friendReply) {
              setState(() {
                userResponse = response;
                friendResponse = friendReply;
                conversation.add({'speaker': 'User', 'message': response});
                conversation.add({'speaker': 'Friend', 'message': friendReply});

                if (friendReply == "Oh! What things are you getting?") {
                  showItemSelection = true;
                }
              });
              scrollToBottom();
            }

            void confirmItems() {
              setState(() {
                conversation.add({
                  'speaker': 'User',
                  'message': 'I am getting: ' + selectedItems.join(', ')
                });
                conversation.add({
                  'speaker': 'Friend',
                  'message':
                      "Oh wow, you remember everything! I forget sometimes what I’m supposed to buy."
                });
                conversation
                    .add({'speaker': 'User', 'message': 'Thank You, Goodbye!'});
                conversation.add({'speaker': 'Friend', 'message': 'Goodbye!'});
                showItemSelection = false;
              });
              scrollToBottom();
            }

            return AlertDialog(
              title: Text(
                'Conversation With Old Friend in Mall',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var message in conversation)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            if (message['speaker'] == 'Friend') ...[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(message['message']!),
                                ),
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                'assets/Friend_Basket.png',
                                width: 60,
                                height: 60,
                              ),
                            ] else ...[
                              Image.asset(
                                'assets/Grandpa_Basket.png',
                                width: 60,
                                height: 60,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(message['message']!),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                    // ✅ ChoiceChip section (item selection)
                    if (showItemSelection) ...[
                      SizedBox(height: 15),
                      Text(
                        'Select 6 correct grocery items:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 10,
                        children: items.map((item) {
                          return ChoiceChip(
                            label: Text(item),
                            selected: selectedItems.contains(item),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  if (selectedItems.length < 6) {
                                    selectedItems.add(item);
                                  }
                                } else {
                                  selectedItems.remove(item);
                                }
                                errorMessage =
                                    null; // clear error when user reselects
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // ✅ Buttons at bottom
              actions: [
                if (showItemSelection)
                  TextButton(
                    onPressed: (() {
                      final requiredItems = {
                        'Milk',
                        'Cheese',
                        'Yogurt',
                        'Eggs',
                        'Bread',
                        'Flour',
                      };
                      final selectedSet = selectedItems.toSet();
                      final isCorrect = selectedSet.length == 6 &&
                          selectedSet.containsAll(requiredItems);

                      if (isCorrect) {
                        confirmItems();
                      } else {
                        setState(() {
                          errorMessage =
                              'Please select only the correct 6 grocery items that you need to purchase in this and previous task.';
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      }
                    }),
                    child: Text("Confirm Selection"),
                  )
                else if (userResponse.isEmpty) ...[
                  TextButton(
                    onPressed: () {
                      addConversation("How are you?",
                          "I am also fine! What are you doing here?");
                    },
                    child: Text('Ask "How are you?"'),
                  ),
                  TextButton(
                    onPressed: () {
                      addConversation("Who are you?",
                          "I am your school friend, just came here for shopping. What are you doing here?");
                    },
                    child: Text('Ask "Who are you?"'),
                  ),
                ] else if (friendResponse ==
                        "I am also fine! What are you doing here?" ||
                    friendResponse ==
                        "I am your school friend, just came here for shopping. What are you doing here?") ...[
                  TextButton(
                    onPressed: () {
                      addConversation("I am here for shopping.",
                          "Oh! What things are you getting?");
                    },
                    child: Text('Reply "I am here for shopping."'),
                  ),
                  TextButton(
                    onPressed: () {
                      addConversation(
                          "Just passing time.", "Oh, okay. Well, take care!");
                    },
                    child: Text('Reply "Just passing time."'),
                  ),
                ] else
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
    onAudioComplete();
  }

  Widget _buildColumn(List<bool> visibilityList, Function(int) onTap,
    String imagePath, double size) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (index) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child: visibilityList[index]
            ? GestureDetector(
                onTap: () => onTap(index),
                child: Image.asset(
                  imagePath,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
              )
            : Opacity(
                opacity: 0, // invisible but occupies space
                child: Image.asset(
                  imagePath,
                  width: size,
                  height: size,
                ),
              ),
      );
    }),
  );
}

  void _resetCart() {
  setState(() {
    eggsCounter = 0;
    breadCounter = 0;
    flourCounter = 0;
    distractorCounter = 0;

    eggsVisibility = List.generate(6, (index) => true);
    breadVisibility = List.generate(6, (index) => true);
    flourVisibility = List.generate(6, (index) => true);
    distractorVisibility = List.generate(6, (index) => true);

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

  void _pickDistractor(int index) {
    setState(() {
      if (totalRs - distractorPrice >= 0 && distractorVisibility[index]) {
        distractorVisibility[index] = false;
        distractorCounter++;
        totalRs -= distractorPrice;
      }
    });
  }

  bool _hasBoughtAllItems() {
    bool hasAllRequired =
        eggsCounter > 0 && breadCounter > 0 && flourCounter > 0;
    bool boughtDistractor = distractorCounter > 0;

    // Fail if distractor bought
    if (boughtDistractor) return false;
    return hasAllRequired;
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
    if (distractorCounter > 0) uniqueItemCount++;

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
                _showHintOverlay(
                    'You need to buy $remainingItemsToBuy more items.');
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Eggs: $eggsCounter', style: TextStyle(fontSize: 16)),
                    Text('Bread: $breadCounter',
                        style: TextStyle(fontSize: 16)),
                    Text('Flour: $flourCounter',
                        style: TextStyle(fontSize: 16)),
                    Text('Fruit: $distractorCounter',
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _resetCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Empty Cart'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_hasBoughtAllItems()) {
                          // ✅ Success case
                          M3L4_2Score = 1;
                          updateFirebaseDataM3L4_2();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ModuleSelectionScreen()),
                          );
                        } else {
                          // ❌ Show message when requirements not met
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please buy all required items first!',
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
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
                    // Shelf Container with Blue Border
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 5),
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

                          Center(
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildColumn(eggsVisibility, _pickeggs,
                                    'assets/Eggs.png', 80),
                                _buildColumn(breadVisibility, _pickbread,
                                    'assets/Bread.png', 80),
                                _buildColumn(flourVisibility, _pickflour,
                                    'assets/Flour.png', 80),
                                _buildColumn(distractorVisibility,
                                    _pickDistractor, 'assets/Grapes.png', 80),
                              ],
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
