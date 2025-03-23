import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For timestamp formatting

class ChatScreen extends StatefulWidget {
  final String skillId;
  final String skillName;

  const ChatScreen({super.key, required this.skillId, required this.skillName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  User? _user;
  String _username = "User"; // Default name if not found

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserName();
  }

  // ✅ Fetch User's Name from Firestore
  void _fetchUserName() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(_user!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _username = userDoc["name"] ?? "User";
        });
      }
    }
  }

  //this is to increament messageCount
  Future<void> incrementMessageCount(String userId) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(userId);

      await userRef.update({"messageCount": FieldValue.increment(1)});
    } catch (e) {
      print("Error incrementing message count: $e");
    }
  }

  // ✅ Send Message to Firestore
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore
        .collection("chats")
        .doc(widget.skillId)
        .collection("messages")
        .add({
          "text": _messageController.text.trim(),
          "senderId": _user!.uid,
          "senderName": _username,
          "timestamp": FieldValue.serverTimestamp(),
        });
    incrementMessageCount(_user!.uid);
    _messageController.clear();
  }

  // ✅ Format Timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime); // Example: "2:45 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.skillName)),
      body: Column(
        children: [
          // 🔹 MESSAGE LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection("chats")
                      .doc(widget.skillId)
                      .collection("messages")
                      .orderBy("timestamp", descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    String senderName = message["senderName"];
                    String messageText = message["text"];
                    bool isMe = message["senderId"] == _user!.uid;
                    Timestamp? timestamp = message["timestamp"];

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width *
                              0.7, // Limits width
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft:
                                isMe ? Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isMe ? Radius.zero : Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Sender Name (small, bold, gray)
                            if (!isMe)
                              Text(
                                senderName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            SizedBox(height: 2),
                            // 🔹 Message Text
                            Text(messageText, style: TextStyle(fontSize: 16)),
                            SizedBox(height: 5),
                            // 🔹 Timestamp (small, right-aligned)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _formatTimestamp(timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // 🔹 MESSAGE INPUT BOX
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
