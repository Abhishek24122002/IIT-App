import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'character_selection.dart';
import 'registration_page.dart';
import 'forgot_password_page.dart'; // Import your forgot_password_page.dart file here
import 'package:get/get.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 94, 114, 228),
              Color.fromARGB(255, 158, 124, 193)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(), // Enable bouncing effect
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo centered at the top
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
                  child: Image.asset(
                    'assets/logo.png', // Replace with your logo image path
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
                // Email field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                          34, 255, 255, 255), // White with lower opacity
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                // Password field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                          34, 255, 255, 255), // White with lower opacity
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                // Login button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        _navigateToCharacterSelection(
                            context); // Navigate on successful login
                      } catch (e) {
                        // Handle login errors
                        print('Login Error: $e');
                        // Show error dialog or snackbar
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(
                          0, 10, 0, 10), // Adjust the padding as needed
                    ),
                    child: Text('Login'),
                  ),
                ),

                // Forgot password text
                GestureDetector(
                  onTap: () {
                    // Navigate to the ForgotPasswordPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20.0),
                // Container with padding for the Create new account button
                Container(
                  padding: EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle create new account button press
                      _navigateToRegistration(
                          context); // Call the function to navigate
                    },
                    child: Text('Create New Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to navigate to the CharacterSelection screen
  void _navigateToCharacterSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CharacterSelection()),
    );
  }

  // Function to navigate to the Registration screen
  void _navigateToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }
}

