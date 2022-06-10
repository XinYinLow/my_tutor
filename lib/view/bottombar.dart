import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:my_tutor/view/tutorscreen.dart';

import '../models/user.dart';
import 'mainScreen.dart';

class BottomBar extends StatefulWidget {
  final User user;
  const BottomBar({Key? key, required this.user}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  late List<Widget> screenSelect;

  @override
  void initState() {
    super.initState();
    screenSelect = [
      MainScreen(user: widget.user),
      TutorScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenSelect[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.purple,
        color: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.subject, color: Colors.purple),
          Icon(Icons.person_pin_circle_rounded, color: Colors.purple),
          Icon(Icons.notifications, color: Colors.purple),
          Icon(Icons.favorite, color: Colors.purple),
          Icon(Icons.person, color: Colors.purple),
        ],
      ),
    );
  }
}
