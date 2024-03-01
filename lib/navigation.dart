import 'package:alzymer/scene/three.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'level_selection.dart';
import 'registration_page.dart';
import 'scene/one.dart';
import 'scene/two.dart';

class Navigation {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) {
          return FirebaseAuth.instance.currentUser != null
              ? HomePage(user: FirebaseAuth.instance.currentUser!)
              : LoginPage();
        });
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage(user: FirebaseAuth.instance.currentUser!));
      case '/forget_password':
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      case '/level_selection':
        return MaterialPageRoute(builder: (_) => LevelSelectionScreen(userScore: 0)); // Change userScore as needed
      case '/registration':
        return MaterialPageRoute(builder: (_) => RegistrationPage());
      case '/one':
        return MaterialPageRoute(builder: (_) => One());
      case '/two':
        return MaterialPageRoute(builder: (_) => Two());
      case '/three':
      return MaterialPageRoute(builder: (_) => Three());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
