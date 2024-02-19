import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'character_selection.dart';

class RegistrationPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
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
            colors: [Color.fromARGB(255, 94, 114, 228), Color.fromARGB(255, 158, 124, 193)],
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
                // Name field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                // Email field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                // Password field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                SizedBox(height: 10.0),
                // Register button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Create user with email and password
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                        // Once user is created successfully, navigate to character selection screen
                        _navigateToCharacterSelection(context);
                      } catch (e) {
                        // Handle registration errors
                        print('Registration Error: $e');
                        // Show error dialog or snackbar
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10), // Adjust the padding as needed
                    ),
                    child: Text('Register'),
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
}
