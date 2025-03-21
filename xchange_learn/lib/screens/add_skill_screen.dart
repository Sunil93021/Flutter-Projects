import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddSkillScreen extends StatefulWidget {
  @override
  _AddSkillScreenState createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final TextEditingController _skillController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _addSkill() async {
    String skillName = _skillController.text.trim();
    if (skillName.isEmpty) return;

    try {
      await _firestore.collection('skills').add({
        'skillName': skillName,
        'userId': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Skill added successfully!")));

      Navigator.pop(context); // Go back to Home Screen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Skill")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _skillController,
              decoration: InputDecoration(labelText: "Enter Skill Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addSkill, child: Text("Add Skill")),
          ],
        ),
      ),
    );
  }
}
