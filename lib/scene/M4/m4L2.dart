import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: M4L2(),
  ));
}

class M4L2 extends StatefulWidget {
  @override
  _M4L2State createState() => _M4L2State();
}

class _M4L2State extends State<M4L2> {
  String _acquaintanceResponse = '';
  String _grandparentAction = '';
  bool _showRecallTask = false;

  // List of items for recall task
  List<String> itemsToRecall = ["Milk", "Bread", "Eggs"];
  List<String> recalledItems = [];

  void _startConversation() {
    // Start conversation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Old Acquaintance:'),
        content: Text('Hello! How are you? It’s been too long since we met.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showGrandparentOptions();
            },
            child: Text('Respond'),
          ),
        ],
      ),
    );
  }

  void _showGrandparentOptions() {
    // Show options dialog for the grandparent character
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose a response'),
        content: Text('How would you like to respond?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _grandparentAction = 'Ask How are you?';
              });
              _continueConversation();
            },
            child: Text('Ask How are you?'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _grandparentAction = 'Ask who are you?';
              });
              _continueConversation();
            },
            child: Text('Ask who are you?'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _grandparentAction = 'Ignore and walk away';
              });
              _endConversation();
            },
            child: Text('Ignore and walk away'),
          ),
        ],
      ),
    );
  }

  void _continueConversation() {
    if (_grandparentAction == 'Ignore and walk away') {
      return;
    }

    setState(() {
      _acquaintanceResponse = 'What brings you here today?';
    });

    // After response, choose a reason for grandparent's visit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Old Acquaintance:'),
        content: Text(_acquaintanceResponse),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _grandparentAction = 'Came for some shopping';
              });
              _askRecallTask();
            },
            child: Text('Shopping'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _grandparentAction = 'Picking up grandchild from school';
              });
              _askRecallTask();
            },
            child: Text('Picking up grandchild'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _grandparentAction = 'Came to rest';
              });
              _askRecallTask();
            },
            child: Text('To rest'),
          ),
        ],
      ),
    );
  }

  void _askRecallTask() {
    setState(() {
      _showRecallTask = true;
    });
  }

  void _submitRecalledItems() {
    if (recalledItems.toSet().containsAll(itemsToRecall)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recall successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recall incomplete, try again.')),
      );
    }

    // End the conversation
    _endConversation();
  }

  void _endConversation() {
    setState(() {
      _acquaintanceResponse = 'Goodbye! See you next time.';
      _showRecallTask = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversation with Acquaintance')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _startConversation,
              child: Text('Start Conversation'),
            ),
            if (_acquaintanceResponse.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('Old Acquaintance: $_acquaintanceResponse'),
            ],
            if (_grandparentAction.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('Grandparent: $_grandparentAction'),
            ],
            if (_showRecallTask)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Recall Task: Enter the items you were asked to remember.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    onSubmitted: (item) {
                      setState(() {
                        recalledItems.add(item);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter item',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitRecalledItems,
                    child: Text('Submit Recall Items'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
