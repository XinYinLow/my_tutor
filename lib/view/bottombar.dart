import 'package:flutter/material.dart';
import 'package:my_tutor/view/mainscreen.dart';
import 'package:my_tutor/view/tutorscreen.dart';
import '../models/user.dart';

class BottomBar extends StatefulWidget {
  final User user;
  const BottomBar({Key? key, required this.user}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
   late List<Widget> tabchildren; 
      int _currentIndex = 0;
      String maintitle = "Product";

  @override
    void initState() {
      super.initState(); 
      tabchildren = [
        MainScreen(user: widget.user),  
        TutorScreen(user: widget.user),
      ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabchildren[_currentIndex],
      bottomNavigationBar: 
            BottomNavigationBar(
              onTap: onTabTapped, 
              currentIndex: _currentIndex, 
              items: const [
                BottomNavigationBarItem(
                icon: Icon(
                  Icons.subject, 
                  color: Colors.purple), 
                  label: "Subjects",
                  backgroundColor: Colors.white,
                  ),
                BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_pin_circle_rounded , 
                  color: Colors.purple), 
                  label: "Tutors"),
                  BottomNavigationBarItem(
                  icon: Icon(Icons.chat, 
                  color: Colors.purple),
                  label: 'Subscribe',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.call, 
                  color: Colors.purple),
                  label: 'Favourite',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, 
                  color: Colors.purple),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }

  void onTabTapped(int index) { 
    setState(() {
      _currentIndex = index; 
      
      if (_currentIndex == 0) {
      maintitle = "Subjects";
      }
      if (_currentIndex == 1) { 
        maintitle = "Tutors";
      }
      if (_currentIndex == 2) {
      maintitle = "Subscribe";
      }
      if (_currentIndex == 3) { 
        maintitle = "Favourite";
      }
      if (_currentIndex == 4) {
      maintitle = "Profile";
      }
    });
  }
}