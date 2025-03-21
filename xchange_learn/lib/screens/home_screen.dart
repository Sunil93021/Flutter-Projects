import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _skillController = TextEditingController();

  void _addSkill() async {
    String skill = _skillController.text.trim();
    if (skill.isNotEmpty) {
      // Check if skill already exists
      var existingSkills =
          await _firestore
              .collection('skills')
              .where('skill', isEqualTo: skill)
              .get();

      if (existingSkills.docs.isEmpty) {
        await _firestore.collection('skills').add({'skill': skill});
      }
      _skillController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XChange Learn'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Skill Input Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      hintText: 'Enter a skill to add',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSkill,
                  child: Text('Add'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          Divider(),
          // Skill List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('skills').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var skills = snapshot.data!.docs;
                if (skills.isEmpty) {
                  return Center(
                    child: Text(
                      'No skills available. Add a skill to start!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    var skillData = skills[index];
                    String skillName = skillData['skill'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(skillName, style: TextStyle(fontSize: 18)),
                        subtitle: Text("Tap to join chat"),
                        trailing: Icon(Icons.chat, color: Colors.blue),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(skillName: skillName),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
