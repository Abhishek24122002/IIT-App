import 'package:flutter/material.dart';

class M3L9 extends StatefulWidget {
  @override
  _M3L9State createState() => _M3L9State();
}

class _M3L9State extends State<M3L9> {
  List<String> fruits = ['Apple', 'Banana', 'Mango', 'Orange', 'Grapes'];
  List<String> vegetables = ['Carrot', 'Tomato', 'Potato', 'Onion', 'Cabbage'];
  List<String> selectedItems = [];
  List<String> requiredItems = ['Apple', 'Mango', 'Potato', 'Onion'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInstructionDialog();
    });
  }

  void showInstructionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions to Complete Level'),
          content: Text(
              '1. The character has been given a list of groceries that need to be taken home.\n\n'
              '2. If the character adds all the required items to the basket, they will be rewarded with a point.\n\n'
              '3. Click on Icon to add item to Basket\n\n'
              '4. Click on Icon to remove item from Basket\n\n'
              '5. To view list Show List button is at top Right'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                showItemList(
                    context); // Automatically show the list after instructions
              },
            ),
          ],
        );
      },
    );
  }

  void addItem(String item) {
    if (!selectedItems.contains(item)) {
      setState(() {
        selectedItems.add(item);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$item is already in the basket!')),
      );
    }
  }

  void removeItem(String item) {
    setState(() {
      selectedItems.remove(item);
    });
  }

  void showItemList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.4,
          heightFactor: 1.7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grocery List',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      children: requiredItems.map((item) {
                        return ListTile(
                          leading: Image.asset('assets/$item.png',
                              width: 40, height: 40),
                          title: Text(item,
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void checkItems() {
  if (selectedItems.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Basket is empty'),
          content: Text('Add items to the basket.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } else {
    selectedItems.sort();
    requiredItems.sort();
    if (selectedItems.length == requiredItems.length &&
        selectedItems.every((element) => requiredItems.contains(element))) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text('All items purchased! Task completed.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('List not matched'),
            content:
                Text('The items in the basket do not match the required list.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45.0,
        title: Text('Module 3 Level 3'),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: ElevatedButton(
              onPressed: () {
                showItemList(context);
              },
              child: Text('Show List'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // List 1: Fruits
                Expanded(
                  child: Container(
                    color: Colors.orangeAccent[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Fruits',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: fruits.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Image.asset(
                                      'assets/${fruits[index]}.png',
                                      width: 40,
                                      height: 40),
                                  title: Text(fruits[index]),
                                  onTap: () => addItem(fruits[index]),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List 2: Vegetables
                Expanded(
                  child: Container(
                    color: Colors.greenAccent[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Vegetables',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: vegetables.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Image.asset(
                                      'assets/${vegetables[index]}.png',
                                      width: 40,
                                      height: 40),
                                  title: Text(vegetables[index]),
                                  onTap: () => addItem(vegetables[index]),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List 3: Selected Items
                Expanded(
                  child: Container(
                    color: Colors.blueAccent[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Basket',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: selectedItems.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Image.asset(
                                      'assets/${selectedItems[index]}.png',
                                      width: 40,
                                      height: 40),
                                  title: Text(selectedItems[index]),
                                  onTap: () => removeItem(selectedItems[index]),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ElevatedButton(
              onPressed: checkItems,
              child: Text('Purchase'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: M3L9(),
  ));
}
