import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_tutor/view/loginscreen.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tutor App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        textTheme:GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        )
      ),
      home: const MySplashScreen(title: 'SlumShop Admin'),
    );
  }
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key, required String title}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  //late double screenHeight, screenWidth;
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3), 
      () => Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (content) => const LoginScreen())));
  }
  @override
  Widget build(BuildContext context) {
    //screenHeight = MediaQuery.of(context).size.height;
    //screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset('assets/images/mt.png'),
              ),
              const CircularProgressIndicator(),
              const Text(
                "Version 0.1",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple
                ),
              )
            ],
          )),
      ),
    );
  }
}