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
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  String _profilePic = "";
  bool _isLoading = false;
  List<String> _skills = [];

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
        _nameController.text = userDoc["name"] ?? "No Name";
        _bioController.text = userDoc["bio"] ?? "No Bio Available";
        _profilePic = userDoc["profilePic"] ?? "";
        _skills = List<String>.from(userDoc["skills"] ?? []);
      });
    }
  }

  void updateUserNameInLeaderBoard(String userId, String newName) async {
    try {
      // Update the user's document in Firestore
      await FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(userId) // Ensure you're using the correct document ID
          .update({"name": newName});

      print("Username updated successfully in leaderboard!");
    } catch (error) {
      print("Error updating username: $error");
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
        'bio': _bioController.text.trim(),
        'profilePic': _profilePic, // Update later with image upload
        'skills': _skills,
      });
      updateUserNameInLeaderBoard(user.uid, _nameController.text.trim());
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));

      Navigator.pop(context); // Go back to Profile Screen
    }
  }

  // ✅ Add Skill
  void _addSkill() {
    String newSkill = _skillsController.text.trim();
    if (newSkill.isNotEmpty && !_skills.contains(newSkill)) {
      setState(() {
        _skills.add(newSkill);
        _skillsController.clear();
      });
    }
  }

  // ✅ Remove Skill
  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
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
            SizedBox(height: 15),

            // ✅ Bio Input Field
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Skills Section
            TextField(
              controller: _skillsController,
              decoration: InputDecoration(
                labelText: "Add Skill",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addSkill,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children:
                  _skills
                      .map(
                        (skill) => Chip(
                          label: Text(skill),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () => _removeSkill(skill),
                        ),
                      )
                      .toList(),
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
