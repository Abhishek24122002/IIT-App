import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class M4L3 extends StatefulWidget {
  @override
  _M4L3State createState() => _M4L3State();
}

class _M4L3State extends State<M4L3> {
  int score = 0;
  List<bool> holesOccupied = List.filled(9, false); // Track if holes are filled
  List<int?> holePinIndex = List.filled(9, null); // Track which pin is in which hole
  List<bool> holeHovering = List.filled(9, false); // Track hover state for each hole

  final double holeRadius = 30.0; // Radius for snapping detection
  final double pinSize = 60.0; // Pin image size

  @override
  void initState() {
    super.initState();
    // Lock screen orientation to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset screen orientation when the screen is disposed
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
        title: Text('O\'Connor Finger Dexterity Test'),
      ),
      body: Row(
        children: [
          // Left Side: Constrained widget containing the Holes in 3x3 Matrix
          Expanded(
            flex: 2,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1, // Keep the grid square
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling inside the grid
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      crossAxisSpacing: 15.0, // Space between holes horizontally
                      mainAxisSpacing: 15.0, // Space between holes vertically
                    ),
                    itemCount: 9, // Total 9 holes in 3x3 grid
                    padding: EdgeInsets.all(20.0), // Padding inside the grid
                    itemBuilder: (context, index) {
                      return DragTarget<int>(
                        onWillAccept: (data) {
                          setState(() {
                            holeHovering[index] = true; // Highlight the hole when hovered
                          });
                          return true;
                        },
                        onLeave: (data) {
                          setState(() {
                            holeHovering[index] = false; // Stop highlighting when no longer hovering
                          });
                        },
                        onAccept: (data) {
                          setState(() {
                            holesOccupied[index] = true; // Mark the hole as occupied
                            holePinIndex[index] = data; // Save the pin's index
                            holeHovering[index] = false; // Stop hover effect
                            score++; // Increment score
                          });
                        },
                        builder: (context, accepted, rejected) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: holesOccupied[index]
                                  ? const Color.fromARGB(255, 109, 255, 114) // Occupied hole
                                  : holeHovering[index]
                                      ? Colors.blueAccent // Hover effect
                                      : Colors.black, // Default color for unoccupied hole
                            ),
                            child: Center(
                              child: holesOccupied[index] && holePinIndex[index] != null
                                  ? Image.asset('assets/pin.png', height: pinSize) // Pin inside the hole
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Right Side: Pins in One Small Box
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(color: Colors.black, width: 2),
              ),
              height: 200, // Small box for all pins
              width: 200,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3, // Display pins in a small grid inside the box
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: List.generate(9, (index) {
                  return Draggable<int>(
                    data: index,
                    feedback: Image.asset('assets/pin.png', height: pinSize),
                    childWhenDragging: Container(height: pinSize, width: pinSize), // Empty space while dragging
                    child: holePinIndex.contains(index)
                        ? Container(height: pinSize, width: pinSize) // Hide pin after it's placed in hole
                        : Image.asset('assets/pin.png', height: pinSize),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Score: $score',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
