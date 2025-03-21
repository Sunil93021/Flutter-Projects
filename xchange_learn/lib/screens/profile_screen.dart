import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _name = "";
  String _bio = "";
  String _profilePic = "";
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserProfile();
  }

  // Fetch User Profile from Firestore
  void _fetchUserProfile() async {
    if (_user != null) {
      DocumentSnapshot userProfile =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (userProfile.exists) {
        setState(() {
          _name = userProfile['name'];
          _bio = userProfile['bio'];
          _profilePic = userProfile['profilePic'];
          _nameController.text = _name;
          _bioController.text = _bio;
        });
      }
    }
  }

  // Pick Image from Gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _uploadProfileImage(File(image.path));
    }
  }

  // Upload Profile Image to Firebase Storage
  Future<void> _uploadProfileImage(File image) async {
    setState(() => _isLoading = true);
    try {
      String filePath = 'profile_pics/${_user!.uid}.jpg';
      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref(filePath)
          .putFile(image);
      String imageUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _profilePic = imageUrl;
        _isLoading = false;
      });

      _saveProfile();
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error uploading image: $e");
    }
  }

  // Save Profile to Firestore
  void _saveProfile() async {
    await _firestore.collection('users').doc(_user!.uid).set({
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'profilePic': _profilePic,
    });

    setState(() {
      _name = _nameController.text.trim();
      _bio = _bioController.text.trim();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), backgroundColor: Colors.blue),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _profilePic.isNotEmpty
                                ? NetworkImage(_profilePic)
                                : null,
                        child:
                            _profilePic.isEmpty
                                ? Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: _bioController,
                      decoration: InputDecoration(labelText: "Bio"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
