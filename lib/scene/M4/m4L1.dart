import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart'; // Import the vibration package

class M4L1 extends StatefulWidget {
  @override
  _M4L1State createState() => _M4L1State();
}

class _M4L1State extends State<M4L1> with SingleTickerProviderStateMixin {
  int points = 0;
  List<bool> appleDropped = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ]; // Track each apple drop
  double progress = 0.0;
  late AnimationController _glowController;
  final GlobalKey boyKey = GlobalKey(); // Key to locate the boy image

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void handleAppleDrop() {
    setState(() {
      progress = points / appleDropped.length;
      if (progress == 1.0) {
        _glowController.forward().then((_) {
          _glowController.stop();
          _showCongratsDialog();
          // Long vibration for level completion
          Vibration.vibrate(duration: 1000);
        });
      }
    });
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have completed the game!'),
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

  bool _isAppleInMouth(DragTargetDetails<String> details) {
    // Get the position of the boy image
    final RenderBox box = boyKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    
    // Boy's image size and mouth position
    final boyWidth = box.size.width;
    final boyHeight = box.size.height;
    
    // Define mouth area (a small rectangle in the center of the boy image)
    final double mouthCenterX = position.dx + boyWidth / 2;
    final double mouthCenterY = position.dy + boyHeight * 0.55; // Adjust mouth position
    
    // Define acceptable range around mouth
    final double mouthRadius = 30.0;

    // Get the drop position
    final dropPosition = details.offset;

    // Check if drop position is within mouth region
    return (dropPosition.dx - mouthCenterX).abs() < mouthRadius &&
        (dropPosition.dy - mouthCenterY).abs() < mouthRadius;
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions to complete level'),
          content: Text(
              'Grandchild is Hungry, Feed The Fruits to the Child. \n\nFruit Need To Be Picked From Right and Dropped in Mouth of Child. For Every Correct Fruit Drop, you will be rewarded with a point.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 4 Task 1'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Points: $points',
                style: TextStyle(fontSize: 24),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (progress == 1.0)
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 30,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amberAccent.withOpacity(0.7),
                                      blurRadius: 30.0 * _glowController.value,
                                      spreadRadius: 10.0 * _glowController.value,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Container(
                          width: 40,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 2),
                            color: Colors.black12,
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              FractionallySizedBox(
                                heightFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.green,
                                        Colors.lightGreenAccent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: DragTarget<String>(
                      key: boyKey, // Assign the key to the boy's image
                      builder: (BuildContext context, List<String?> candidateData,
                          List<dynamic> rejectedData) {
                        return Image.asset(
                          'assets/boy.png',
                          width: 180,
                          height: 180,
                        );
                      },
                      onAcceptWithDetails: (details) {
                        if (_isAppleInMouth(details)) {
                          setState(() {
                            String data = details.data;
                            if (data.startsWith('apple')) {
                              points += 1;
                              int index = int.parse(data.replaceAll('apple', ''));
                              appleDropped[index] = true;
                              handleAppleDrop();
                              
                              // Short vibration for correct apple drop
                              Vibration.vibrate(duration: 100);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return appleWidget(index);
                          }),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return appleWidget(index + 4);
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    appleDropped = [
                      false,
                      false,
                      false,
                      false,
                      false,
                      false,
                      false,
                      false
                    ];
                    points = 0;
                    progress = 0.0;
                    _glowController.reset();
                  });
                },
                child: Text('Reset'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appleWidget(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: appleDropped[index]
          ? Container(
              height: 40,
              width: 40,
              color: Colors.transparent,
            )
          : Draggable<String>(
              data: 'apple$index',
              feedback: Image.asset(
                'assets/Apple.png',
                width: 40,
                height: 40,
              ),
              childWhenDragging: Container(),
              child: Image.asset(
                'assets/Apple.png',
                width: 40,
                height: 40,
              ),
            ),
    );
  }
}
