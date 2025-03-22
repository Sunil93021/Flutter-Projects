import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .orderBy('messageCount', descending: true) // Sort by messages
              .limit(10) // Only top 10 users
              .get();

      return snapshot.docs
          .asMap()
          .entries
          .map(
            (entry) => {
              "name": entry.value["name"],
              "score": entry.value["messageCount"],
              "rank": entry.key + 1,
            },
          )
          .toList();
    } catch (e) {
      print("Error fetching leaderboard: $e");
      return [];
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
              // Fetch leaderboard data asynchronously
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchLeaderboard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No leaderboard data available",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  List<Map<String, dynamic>> players = snapshot.data!;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (players.length > 1)
                            RankCard(players[1], Colors.grey), // 2nd place
                          SizedBox(width: 10),
                          RankCard(players[0], Colors.amber), // 1st place
                          SizedBox(width: 10),
                          if (players.length > 2)
                            RankCard(players[2], Colors.brown), // 3rd place
                        ],
                      ),
                      SizedBox(height: 20),
                      // Other Players List
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.all(20),
                            itemCount: players.length - 3,
                            itemBuilder: (context, index) {
                              final player = players[index + 3];
                              return PlayerTile(player);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Rank Card for Top 3 Players
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
          "${player["score"]} pts",
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}

// Player List Tile
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
          "${player["score"]} pts",
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
