import 'package:flutter/material.dart';

class M4L2 extends StatefulWidget {
  @override
  _M4L2State createState() => _M4L2State();
}

class _M4L2State extends State<M4L2> {
  bool isPinOverHole = false;
  bool isPinDropped = false;
  int points = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drag and Drop Pin"),
      ),
      body: Stack(
        children: [
          // The Hole on the left side with the Pin inside when dropped
          Align(
            alignment: Alignment.centerLeft,
            child: DragTarget<String>(
              onAccept: (data) {
                setState(() {
                  isPinDropped = true;
                  points += 1;
                });
              },
              onWillAccept: (data) {
                setState(() {
                  isPinOverHole = true;
                });
                return true;
              },
              onLeave: (data) {
                setState(() {
                  isPinOverHole = false;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 80, // Hole size
                  height: 80, // Hole size
                  decoration: BoxDecoration(
                    color: isPinOverHole || isPinDropped
                        ? Colors.green
                        : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPinOverHole ? Colors.yellow : Colors.black,
                      width: 5,
                    ),
                  ),
                  child: isPinDropped
                      ? Center(
                          child: Image.asset(
                            'assets/pin.png',
                            width: 60,
                            height: 60,
                          ),
                        )
                      : Container(), // Empty when pin not dropped
                );
              },
            ),
          ),
          // Draggable Pin on the right side (only visible when not dropped)
          Align(
            alignment: Alignment.centerRight,
            child: !isPinDropped
                ? Draggable<String>(
                    data: "pin",
                    feedback: Image.asset(
                      'assets/pin.png',
                      width: 100,
                      height: 100,
                    ),
                    childWhenDragging: Container(), // Hide when dragging
                    child: Image.asset(
                      'assets/pin.png',
                      width: 100,
                      height: 100,
                    ),
                  )
                : Container(),
          ),
          // Display points
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Points: $points",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
