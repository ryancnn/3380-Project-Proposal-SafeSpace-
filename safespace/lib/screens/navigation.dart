import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:safespace/screens/explore.dart';
import 'package:safespace/screens/home.dart';
import 'package:safespace/screens/profile.dart';
import 'package:safespace/variables.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  List pageOptions = [
    Home(),
    Explore(),
    Profile(auth.currentUser!.uid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageOptions[page],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            if (lastpage != page) {
              lastpage = page;
            }
            page = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: page,
        items: [
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.messageText), label: ("Chats")),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.compassRose), label: ("Explore")),
          BottomNavigationBarItem(
              icon: Icon(MdiIcons.account), label: ("Profile")),
        ],
      ),
    );
  }
}
