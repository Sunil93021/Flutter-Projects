import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xchange_learn/screens/splash_screen.dart';
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

  //intitalize a varible message Count in firebase for ranking purpose
  Future<void> registerUser(String userId, String name) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(userId);

      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({"name": name, "messageCount": 0});
      }
    } catch (e) {
      print("Error registering user: $e");
    }
  }

  void _submitAuthForm() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (!context.mounted) return;
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
                {'name': randomName, 'email': email, 'messageCount': 0},
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
        registerUser(userCredential.user!.uid, randomName);
      }

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
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
      backgroundColor: Colors.blue.shade50, // Light blue background
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700, // Dark blue AppBar
        title: Text(
          _isLogin ? "Login" : "Register",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 App Logo Placeholder
                Icon(Icons.person, size: 80, color: Colors.blue.shade700),

                SizedBox(height: 16),

                // 🔹 Email Input Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 12),

                // 🔹 Password Input Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20),

                // 🔹 Login / Register Button
                ElevatedButton(
                  onPressed: _submitAuthForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: Text(
                    _isLogin ? "Login" : "Register",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 12),

                // 🔹 Toggle Between Login and Register
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
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
