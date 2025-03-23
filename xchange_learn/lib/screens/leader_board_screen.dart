import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(LeaderboardApp());
}

class LeaderboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LeaderboardScreen(),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  void fetchLeaderboard() async {
    bool isLoading = true;
    String errorMessage = "";
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('leaderboard').get();

      List<Map<String, dynamic>> players = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        int messageCount =
            data.containsKey("messageCount") ? data["messageCount"] : 0;
        String name = data["name"] ?? "Unknown Player";

        players.add({"name": name, "messageCount": messageCount});
      }

      players.sort((a, b) => b["messageCount"].compareTo(a["messageCount"]));
      // Assign ranks to players based on index
      for (int i = 0; i < players.length; i++) {
        players[i]["rank"] = i + 1;
      }
      if (mounted) {
        setState(() {
          leaderboard = players;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          errorMessage = "Error fetching leaderboard: $error";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.deepPurpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 60),
              Text(
                "🏆 Leaderboard 🏆",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              leaderboard.length >= 3
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RankCard(leaderboard[1], Colors.grey), // 2nd place
                      SizedBox(width: 10),
                      RankCard(leaderboard[0], Colors.amber), // 1st place
                      SizedBox(width: 10),
                      RankCard(leaderboard[2], Colors.brown), // 3rd place
                    ],
                  )
                  : CircularProgressIndicator(),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child:
                      leaderboard.isNotEmpty
                          ? ListView.builder(
                            padding: EdgeInsets.all(20),
                            itemCount: leaderboard.length - 3,
                            itemBuilder: (context, index) {
                              final player = leaderboard[index + 3];
                              return PlayerTile(player);
                            },
                          )
                          : Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RankCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final Color medalColor;

  RankCard(this.player, this.medalColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: medalColor,
          child: Text(
            player["rank"].toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          player["name"],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "${player["messageCount"]} pts",
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}

class PlayerTile extends StatelessWidget {
  final Map<String, dynamic> player;

  PlayerTile(this.player);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            player["rank"].toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        title: Text(
          player["name"],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          "${player["messageCount"]} pts",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
