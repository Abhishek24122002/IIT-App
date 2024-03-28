import 'package:flutter/material.dart';

class M1L5 extends StatefulWidget {
  @override
  _M1L5State createState() => _M1L5State();
}

class _M1L5State extends State<M1L5> {
  List<String> tasks = [
    'Fruit eated',
    'Helped Grandchild with Season',
    'Helped Grandchild with Date',
    'Picking Up Grandchild'
  ];
  String savedSequence = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Done Sequence'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: tasks
                .map(
                  (task) => Draggable<String>(
                    data: task,
                    childWhenDragging: Container(
                      width: 150,
                      height: 70,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          task,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    feedback: Material(
                      elevation: 4.0,
                      child: Container(
                        width: 150,
                        height: 70,
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            task,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    child: DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 150,
                          height: 70,
                          color: Colors.blue,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                task,
                                style: TextStyle(fontSize: 16, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                      onAccept: (data) {
                        setState(() {
                          int index = tasks.indexOf(data);
                          tasks[tasks.indexOf(task)] = data;
                          tasks[index] = task;
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            savedSequence = tasks.join(', ');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sequence saved: $savedSequence'),
            ),
          );
        },
        child:Text('Save'),
      ),
    );
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
