import 'package:alzymer/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  File? _image;
  String? _imageURL;
  String? _selectedGender;
  DateTime? _selectedDate; // New field for Date of Birth
  bool _obscurePassword = true;
  bool _passwordValidated = true; // Track password validation

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> _uploadImage(String userId) async {
    if (_image == null) return '';

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Upload Image Error: $e');
      return '';
    }
  }

  // Password validation function
  bool _isPasswordValid(String password) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$])[A-Za-z\d@$]{8,15}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 94, 114, 228),
                    Color.fromARGB(255, 158, 124, 193),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 150),
                      GestureDetector(
                        onTap: _getImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child:
                              _image == null ? Icon(Icons.add_a_photo) : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(34, 255, 255, 255),
                                Color.fromARGB(34, 255, 255, 255),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: nameController,
                              style:
                                  TextStyle(color: Colors.white), // Text color
                              decoration: InputDecoration(
                                hintText: 'Name',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(34, 255, 255, 255),
                                Color.fromARGB(34, 255, 255, 255),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null &&
                                    pickedDate != _selectedDate) {
                                  setState(() {
                                    _selectedDate = pickedDate;
                                  });
                                }
                              },
                              style:
                                  TextStyle(color: Colors.white), // Text color
                              decoration: InputDecoration(
                                hintText: 'Date of Birth',
                                hintStyle: TextStyle(color: Colors.white54),
                                suffixIcon: Icon(Icons.calendar_today),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(34, 255, 255, 255),
                                Color.fromARGB(34, 255, 255, 255),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: emailController,
                              style:
                                  TextStyle(color: Colors.white), // Text color
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(34, 255, 255, 255),
                                Color.fromARGB(34, 255, 255, 255),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              style:
                                  TextStyle(color: Colors.white), // Text color
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.white54),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Red-bordered box for error message
                      if (!_passwordValidated)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red), // Red border
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.only(bottom: 20), // Added margin
                          child: Text(
                            'Password must be 8-15 characters long and contain at least 1 uppercase letter, 1 number, and 1 special character (@ or \$).',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Text(
                              'Gender: ',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: _selectedGender,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                              hint: Text(
                                  'Select'), // Added hint to show "Select" as default label
                              items: <String>[
                                'Male',
                                'Female'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(fontSize: 16,),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          String password = passwordController.text.trim();
                          // Check password validation
                          if (!_isPasswordValid(password)) {
                            setState(() {
                              _passwordValidated = false;
                            });
                            return; // Stop registration process if password is invalid
                          }

                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: password,
                            );

                            String photoURL =
                                await _uploadImage(userCredential.user!.uid);
                            _imageURL = photoURL; // Store Firebase Storage URL

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'photoURL': _imageURL,
                              'gender': _selectedGender,
                              'dob': _selectedDate != null
                                  ? Timestamp.fromDate(_selectedDate!)
                                  : null, // Store DOB in Firestore as Timestamp
                            });

                            // Initialize user score data
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .collection('score')
                                .doc('M1')
                                .set({
                              'M1L1Point': 0,
                              'M1L2Point': 0,
                              'M1L3Point': 0,
                              'M1L4Point': 0,
                              'M1L5Point': 0,
                            });

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(user: userCredential.user)),
                            );
                          } catch (e) {
                            print('Registration Error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Registration failed. Please try again later.')),
                            );
                          }
                        },
                        child: Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
