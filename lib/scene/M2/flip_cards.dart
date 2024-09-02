import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: cards(),
  ));
}

class cards extends StatefulWidget {
  @override
  _cardsState createState() => _cardsState();
}

class _cardsState extends State<cards> {
  List<String> _objects = ['🍎', '🍄', '🍇', '🍉', '🍎', '🍄', '🍇', '🍉'];
  List<bool> _flipped = List.filled(8, false);
  int _firstIndex = -1;
  int _secondIndex = -1;
  int _matchedPairs = 0;
  int _timeElapsed = 0;
  int _moveCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _objects.shuffle();
    startTimer();
    _forceOrientation();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeElapsed++;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void _flipCard(int index) {
    setState(() {
      _moveCount++;
      if (_firstIndex == -1) {
        _firstIndex = index;
        _flipped[index] = true;
      } else if (_secondIndex == -1 && _firstIndex != index) {
        _secondIndex = index;
        _flipped[index] = true;
        if (_objects[_firstIndex] == _objects[_secondIndex]) {
          _matchedPairs++;
          _firstIndex = -1;
          _secondIndex = -1;
          if (_matchedPairs == _objects.length ~/ 2) {
            _submitScore();
          }
        } else {
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _flipped[_firstIndex] = false;
              _flipped[_secondIndex] = false;
              _firstIndex = -1;
              _secondIndex = -1;
            });
          });
        }
      }
    });
  }

  void _submitScore() async {
    stopTimer();
    // Implement score submission logic here
    print('Game completed! Score submitted.');
  }

  void _forceOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Matching Game'),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Time: $_timeElapsed seconds',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Display cards in 2 rows with 4 cards per row
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    childAspectRatio: 1.6, // Adjust aspect ratio to fit cards better
                  ),
                  itemCount: _objects.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: GestureDetector(
                        onTap: () => _flipCard(index),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return RotationY(
                              child: child,
                              animation: animation,
                              flipped: _flipped[index],
                            );
                          },
                          child: _flipped[index]
                              ? Container(
                                  key: ValueKey<int>(1),
                                  width: 150, // Adjust the width of the card
                                  height: 100, // Adjust the height of the card
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _objects[index],
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                )
                              : Container(
                                  key: ValueKey<int>(0),
                                  width: 150, // Adjust the width of the card
                                  height: 100, // Adjust the height of the card
                                  margin: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 26, 16),
  
              child: Text(
                'Moves: $_moveCount',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopTimer();
    // Reset preferred orientations to allow any orientation
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }
}

class RotationY extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final bool flipped;

  RotationY({required this.child, required this.animation, required this.flipped});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 3.14;
        final transform = Matrix4.identity()..rotateY(flipped ? angle : -angle);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
