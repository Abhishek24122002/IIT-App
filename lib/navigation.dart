import 'package:alzymer/login_page.dart';
import 'package:alzymer/scene/scene1.dart';
import 'package:flutter/material.dart';
// import other pages as needed

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NavigationPage(),
    );
  }
}

class NavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/': (context) => Scene1(),
        // Add routes for other pages here
        '/login': (context) => LoginPage(), // Dummy login page route
      },
    );
  }
}
