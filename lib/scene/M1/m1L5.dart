import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M1L5 extends StatefulWidget {
  @override
  _M1L5State createState() => _M1L5State();
}

class _M1L5State extends State<M1L5> {
  List<String> selectedTasks = [];
  List<String> allTasks = [
    'Fruit eated',
    'Helped Grandchild with Season',
    'Helped Grandchild with Date',
    'Picking Up Grandchild'
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialPopup(); // Call the initialPopup function after the frame has been built
    });
  }

  void initialPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' Task 5 ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Color.fromARGB(255, 94, 114, 228), // Title color
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromARGB(
                      255, 158, 124, 193), // Instruction title color
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'For this task, your objective is to choose the tasks you have completed in the previous level in the accurate order .',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87, // Content color
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Got it!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromARGB(255, 94, 114, 228), // Button color
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10.0,
          backgroundColor: Colors.white, // Background color
        );
      },
    );
  }

  void onSavePressed() {
    setState(() {
      // Compare selectedTasks with correct sequence
      if (_checkSequence()) {
        _showCorrectDialog();
      } else {
        _showIncorrectDialog();
      }
    });
  }

  bool _checkSequence() {
    List<String> correctSequence = [
      'Helped Grandchild with Date',
      'Helped Grandchild with Season',
      
      'Fruit eated',
      'Picking Up Grandchild'
    ];
    return selectedTasks.length == correctSequence.length &&
        List.generate(selectedTasks.length,
            (index) => selectedTasks[index] == correctSequence[index])
            .every((element) => element);
  }

  void _showCorrectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('🎉🎉🎉 Your Answer is Correct. 🏆'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showIncorrectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: Text('Your answer is incorrect. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void moveToAllTasks(String task) {
    setState(() {
      selectedTasks.remove(task);
      allTasks.add(task);
    });
  }

  void moveToSelectedTasks(String task) {
    setState(() {
      selectedTasks.add(task);
      allTasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Done Sequence'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Tasks:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 10.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: selectedTasks
                    .map(
                      (task) => GestureDetector(
                        onTap: () => moveToAllTasks(task),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          margin: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            task,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                'All Tasks:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 10.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: allTasks
                    .map(
                      (task) => GestureDetector(
                        onTap: () => moveToSelectedTasks(task),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          margin: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            task,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: onSavePressed,
        child: Text('Save'),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: M1L5(),
    theme: ThemeData(
      primaryColor: Color.fromARGB(255, 94, 114, 228),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.indigo,
      ),
    ),
  ));
}
