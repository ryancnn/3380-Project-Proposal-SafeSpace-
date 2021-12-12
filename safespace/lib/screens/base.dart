import 'package:flutter/material.dart';
import 'package:safespace/screens/login.dart';
import 'package:safespace/screens/navigation.dart';
import 'package:safespace/variables.dart';

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool isLoggedIn = false;
  initState() {
    super.initState();
    auth.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          isLoggedIn = true;
        });
      } else {
        setState(() {
          isLoggedIn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: isLoggedIn == true ? NavigationPage() : LoginPage());
  }
}
