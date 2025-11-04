import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _passwordValidated = true;
  String _errorMessage = '';
  bool _isLoading = false;

  bool _isPasswordValid(String password) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$])[A-Za-z\d@$]{8,15}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // 🧩 Initialize Firebase Score Documents for M1–M4
  Future<void> _initializeUserScores(String uid) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    // List of all module IDs
    final modules = ['M1', 'M2', 'M3'];

    // For each module, create a "score" document with default values
    for (var module in modules) {
      await userDoc.collection('score').doc(module).set({
        '${module}Trophy': 0,
        '${module}L1Point': 0,
        '${module}L2Point': 0,
        '${module}L3Point': 0,
        '${module}L4Point': 0,
        // Add more fields if your module has more levels
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 94, 114, 228),
              Color.fromARGB(255, 158, 124, 193),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/logo.png',
                    width: screenWidth * 0.16,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "IdeaTool",
                    style: TextStyle(
                      fontSize: screenWidth * 0.09,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(2, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        TextField(
                          controller: nameController,
                          decoration: _inputDecoration(
                              "Full Name", Icons.person_outline),
                        ),
                        const SizedBox(height: 10),

                        // Date of Birth
                        //
                        // Age
                        TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration:
                              _inputDecoration("Age", Icons.calendar_today),
                        ),
                        const SizedBox(height: 10),

                        const SizedBox(height: 10),

                        // Gender
                        InputDecorator(
                          decoration:
                              _inputDecoration("Gender", Icons.people_outline),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              isExpanded: true,
                              hint: const Text("Select Gender"),
                              items: ['Male', 'Female']
                                  .map((value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Email
                        TextField(
                          controller: emailController,
                          decoration: _inputDecoration(
                              "Email Address", Icons.email_outlined),
                        ),
                        const SizedBox(height: 10),

                        // Password
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration:
                              _inputDecoration("Password", Icons.lock_outline)
                                  .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        if (!_passwordValidated)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Password must be 8–15 chars with upper, number & special char (@ or \$)',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 11),
                            ),
                          ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 11),
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Register Button
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     String password = passwordController.text.trim();
                        //     if (!_isPasswordValid(password)) {
                        //       setState(() {
                        //         _passwordValidated = false;
                        //       });
                        //       return;
                        //     }

                        //     try {
                        //       UserCredential userCredential = await FirebaseAuth
                        //           .instance
                        //           .createUserWithEmailAndPassword(
                        //         email: emailController.text.trim(),
                        //         password: password,
                        //       );

                        //       String uid = userCredential.user!.uid;

                        //       // Create user profile document
                        //       await FirebaseFirestore.instance
                        //           .collection('users')
                        //           .doc(uid)
                        //           .set({
                        //         'name': nameController.text.trim(),
                        //         'age': int.tryParse(ageController.text.trim()) ?? 0,
                        //         'email': emailController.text.trim(),
                        //         'gender': _selectedGender,

                        //         // 'dob': _selectedDate != null
                        //         //     ? Timestamp.fromDate(_selectedDate!)
                        //         //     : null,
                        //       });

                        //       // Initialize scores for M1–M4
                        //       await _initializeUserScores(uid);

                        //       // Navigate to Home
                        //       Navigator.pushReplacement(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) =>
                        //               HomePage(user: userCredential.user),
                        //         ),
                        //       );
                        //     } catch (e) {
                        //       print('Registration error: $e');
                        //       setState(() {
                        //         _errorMessage =
                        //             'Registration failed. Try again later.';
                        //       });
                        //     }
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(vertical: 10),
                        //     backgroundColor:
                        //         const Color.fromARGB(255, 255, 140, 0),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //     elevation: 2,
                        //   ),
                        //   child: const Text(
                        //     "Register",
                        //     style: TextStyle(
                        //         fontSize: 14,
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  String password =
                                      passwordController.text.trim();
                                  if (!_isPasswordValid(password)) {
                                    setState(() {
                                      _passwordValidated = false;
                                    });
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = '';
                                  });

                                  try {
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: password,
                                    );

                                    String uid = userCredential.user!.uid;

                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .set({
                                      'name': nameController.text.trim(),
                                      'age': int.tryParse(
                                              ageController.text.trim()) ??
                                          0,
                                      'email': emailController.text.trim(),
                                      'gender': _selectedGender,
                                    });

                                    await _initializeUserScores(uid);

                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(
                                                user: userCredential.user)),
                                      );
                                    }
                                  } catch (e) {
                                    print('Registration error: $e');
                                    setState(() {
                                      _errorMessage =
                                          'Registration failed. Try again later.';
                                    });
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor:
                                const Color.fromARGB(255, 255, 140, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Creating account…",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              : const Text(
                                  "Register",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),

                        const SizedBox(height: 8),

                        // Back to Login
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Back to Login",
                            style: TextStyle(
                                color: Color.fromARGB(255, 77, 2, 169),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
