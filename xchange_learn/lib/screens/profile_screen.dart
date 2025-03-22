import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _name = "";
  String _email = "";
  String _profilePic = "";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserData();
  }

  // ✅ Load User Data from Firestore
  void _loadUserData() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();

      setState(() {
        _name =
            userDoc.data().toString().contains("name")
                ? userDoc["name"]
                : "No Name";
        _email =
            userDoc.data().toString().contains("email")
                ? userDoc["email"]
                : _user!.email ?? "No Email";
        _profilePic =
            userDoc.data().toString().contains("profilePic")
                ? userDoc["profilePic"]
                : "";
      });
    }
  }

  // ✅ Logout Function not needed now for future purposes
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreens()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _profilePic.isNotEmpty ? NetworkImage(_profilePic) : null,
                child:
                    _profilePic.isEmpty
                        ? Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
              ),
              SizedBox(height: 15),

              // ✅ User Name
              Text(
                _name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),

              // ✅ User Email
              Text(
                _email,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              SizedBox(height: 20),

              // ✅ Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  ).then((_) => _loadUserData()); // Reload profile after edit
                },
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
