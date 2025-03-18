import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String skill;

  ChatScreen({required this.skill});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  List<String> messages = [];

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        messages.add(messageController.text);
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat about ${widget.skill}"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                messages.isEmpty
                    ? Center(
                      child: Text("No messages yet. Start a conversation!"),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              messages[index],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: sendMessage,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
