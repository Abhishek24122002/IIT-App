import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'module_page.dart';
import 'registration_page.dart';


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
      case '/module_selection':
  return MaterialPageRoute(builder: (_) => ModuleSelectionScreen());
      case '/registration':
        return MaterialPageRoute(builder: (_) => RegistrationPage());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
