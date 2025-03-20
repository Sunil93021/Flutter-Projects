import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'profile_screen.dart'; // Import ProfileApp screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController skillController = TextEditingController();
  List<String> skills = [
    "Python",
    "Graphic Design",
    "Guitar",
    "Public Speaking",
  ];

  void addSkill() {
    if (skillController.text.isNotEmpty) {
      setState(() {
        skills.insert(0, skillController.text);
        skillController.clear();
      });
    }
  }

  void openChat(String skill) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(skill: skill)),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ), // Open profile screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("XChange Learn"),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.person), // Profile icon
            onPressed: openProfile,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What skill can you teach?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skillController,
                    decoration: InputDecoration(
                      hintText: "E.g., Python, Guitar, Design...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text("Add"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Available Skills",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child:
                  skills.isEmpty
                      ? Center(
                        child: Text(
                          "No skills added yet!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: skills.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => openChat(skills[index]),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: ListTile(
                                leading: Icon(
                                  Icons.school,
                                  color: Colors.blueAccent,
                                ),
                                title: Text(
                                  skills[index],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: Icon(
                                  Icons.chat,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
