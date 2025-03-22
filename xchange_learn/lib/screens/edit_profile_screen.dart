import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  String _profilePic = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Load user details from Firestore
  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        _nameController.text =
            userDoc.data().toString().contains("name")
                ? userDoc["name"]
                : user.displayName ?? "No Name";
        _profilePic =
            userDoc.data().toString().contains("profilePic")
                ? userDoc["profilePic"]
                : "";
      });
    }
  }

  // ✅ Save Updated Profile
  void _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'profilePic':
            _profilePic, // You can update this later with image upload
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));

      Navigator.pop(context); // Go back to Profile Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  _profilePic.isNotEmpty ? NetworkImage(_profilePic) : null,
              child:
                  _profilePic.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
            ),
            SizedBox(height: 15),

            // ✅ Name Input Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Save Button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: Icon(Icons.save),
                  label: Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
