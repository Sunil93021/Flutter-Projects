import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'skills_screen.dart';
import 'auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'leader_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Widget> myWidget = [
    // HomeScreen(),
    const SkillsScreen(),
    LeaderboardScreen(),
    // Center(child: Text("Sorry , This page is on Working ")),
    const ProfileScreen(),
  ];

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreens()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700, // Dark blue AppBar
        title: Text(
          "XChange Learn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // 🔹 Logout Button
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),

      body: IndexedStack(children: myWidget, index: myIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: [
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Skills"),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "LeaderBoard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
