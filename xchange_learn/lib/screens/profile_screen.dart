import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _name = "Loading...";
  String _bio = "Loading...";
  String _profilePic = "";
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (_user != null) {
      DocumentReference userRef = _firestore
          .collection('users')
          .doc(_user!.uid);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        // Get data safely, setting defaults if fields are missing
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _name = userData["name"] ?? "No Name";
          _bio = userData["bio"] ?? "No Bio Available";
          _profilePic = userData["profilePic"] ?? "";
          _skills =
              userData["skills"] != null
                  ? List<String>.from(userData["skills"])
                  : [];
        });

        // ✅ Check for missing fields and update Firestore
        Map<String, dynamic> missingFields = {};
        if (!userData.containsKey("name")) missingFields["name"] = "No Name";
        if (!userData.containsKey("bio"))
          missingFields["bio"] = "No Bio Available";
        if (!userData.containsKey("profilePic"))
          missingFields["profilePic"] = "";
        if (!userData.containsKey("skills")) missingFields["skills"] = [];

        if (missingFields.isNotEmpty) {
          await userRef.update(missingFields);
        }
      } else {
        // ✅ If document does not exist, create it with default values
        Map<String, dynamic> defaultData = {
          "name": "No Name",
          "bio": "No Bio Available",
          "profilePic": "",
          "skills": [],
        };
        await userRef.set(defaultData);
        setState(() {
          _name = defaultData["name"];
          _bio = defaultData["bio"];
          _profilePic = defaultData["profilePic"];
          _skills = defaultData["skills"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ✅ Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // ✅ Profile Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              // ✅ Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage:
                    _profilePic.isNotEmpty ? NetworkImage(_profilePic) : null,
                child:
                    _profilePic.isEmpty
                        ? Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
              ),
              SizedBox(height: 15),
              // ✅ Name
              Text(
                _name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // ✅ Bio
              Text(_bio, style: TextStyle(fontSize: 16, color: Colors.white70)),
              SizedBox(height: 20),
              // ✅ Skills Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Skills",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children:
                              _skills.isNotEmpty
                                  ? _skills
                                      .map((skill) => SkillChip(skill))
                                      .toList()
                                  : [Text("No skills added")],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // ✅ Edit Profile Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  ).then((_) => _loadUserData()); // Reload profile after edit
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Widget for skill chips
class SkillChip extends StatelessWidget {
  final String skill;
  SkillChip(this.skill);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(skill, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}
