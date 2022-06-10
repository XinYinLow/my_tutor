import 'package:flutter/material.dart';
import 'package:my_tutor/view/mainscreen.dart';
import 'package:my_tutor/view/tutorscreen.dart';
import '../models/user.dart';

class ButtomBar extends StatefulWidget {
  final User user;
  const ButtomBar({Key? key, required this.user}) : super(key: key);

  @override
  State<ButtomBar> createState() => _ButtomBarState();
}

class _ButtomBarState extends State<ButtomBar> {
   late List<Widget> tabchildren; 
      int _currentIndex = 0;
      String maintitle = "Product";

  @override
    void initState() {
      super.initState(); 
      tabchildren = [
        MainScreen(user: widget.user,),  
        TutorScreen(user: widget.user,),
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
                  Icons.shopping_bag, 
                  color: Colors.purple), 
                  label: "Subjects",
                  backgroundColor: Colors.white,
                  ),
                BottomNavigationBarItem(
                icon: Icon(
                  Icons.person, 
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
                  icon: Icon(Icons.camera, 
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
      maintitle = "Product";
      }
      if (_currentIndex == 1) { 
        maintitle = "Profile";
      }
    });
  }
}