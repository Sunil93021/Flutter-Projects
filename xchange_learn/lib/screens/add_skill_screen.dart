import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  _AddSkillScreenState createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addSkill() async {
    String skillName = _skillController.text.trim();
    String description = _descriptionController.text.trim();

    if (skillName.isEmpty || description.isEmpty) return;

    User? user = _auth.currentUser;

    // Get the user's name from Firestore
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user!.uid).get();

    String addedBy =
        userDoc.exists && userDoc.data().toString().contains("name")
            ? userDoc["name"]
            : user.email ?? "Unknown";

    await _firestore.collection("skills").add({
      "skillName": skillName,
      "description": description, // ✅ Save the skill description
      "addedBy": addedBy, // ✅ Save the user who added it
      "timestamp": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Skill"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _skillController,
              decoration: InputDecoration(labelText: "Skill Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Skill Description"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSkill,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text("Add Skill"),
            ),
          ],
        ),
      ),
    );
  }
}
