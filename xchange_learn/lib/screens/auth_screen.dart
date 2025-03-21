import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // For generating random numbers

import 'home_screen.dart';

class AuthScreens extends StatefulWidget {
  const AuthScreens({super.key});

  @override
  _AuthScreensState createState() => _AuthScreensState();
}

class _AuthScreensState extends State<AuthScreens> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  // Function to generate a random username
  String generateRandomUsername() {
    Random random = Random();
    int randomNumber =
        random.nextInt(9000) + 1000; // Generates a 4-digit number
    return "User$randomNumber";
  }

  void _submitAuthForm() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    try {
      UserCredential userCredential;
      bool isNewUser = false;

      if (_isLogin) {
        // Login existing user
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check if the user has a "name" field in Firestore
        DocumentSnapshot userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists || !userDoc.data().toString().contains("name")) {
          // Assign a default name if missing
          String randomName = generateRandomUsername();
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(
                {'name': randomName, 'email': email},
                SetOptions(
                  merge: true,
                ), // Merge to avoid overwriting existing fields
              );
        }
      } else {
        // Register a new user
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        isNewUser = true;

        String randomName = generateRandomUsername(); // Generate default name

        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': randomName,
          'email': email,
        });
      }

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Login" : "Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitAuthForm,
              child: Text(_isLogin ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin
                    ? "Create an account"
                    : "Already have an account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
