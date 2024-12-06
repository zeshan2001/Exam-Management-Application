import 'package:flutter/material.dart';
import 'package:projetctv0/Providers/easyanswerprovider.dart';
import 'package:projetctv0/Providers/getquestionsprovider.dart';
import 'package:projetctv0/Providers/mcqanswerprovider.dart';
import 'package:projetctv0/Providers/numattempsprovider.dart';
import 'package:projetctv0/Providers/roleprovider.dart';
import 'package:projetctv0/Providers/shortanswerprovider.dart';
import 'package:projetctv0/Providers/truefalseprovider.dart';
import 'package:projetctv0/examlist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projetctv0/login.dart';
import 'package:provider/provider.dart';

void main() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBkcL03PUvYIUGbhZKGsrfEL1WdJDd1zX8",
        authDomain: "projectcheck-37393.firebaseapp.com",
        projectId: "projectcheck-37393",
        storageBucket: "projectcheck-37393.firebasestorage.app",
        messagingSenderId: "269795202201",
        appId: "1:269795202201:web:4adc0aff4431d499555408"),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Shortanswerprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Easyanswerprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Truefalseprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Mcqanswerprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Getquestionsprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Numattempsprovider(),
        ),
        ChangeNotifierProvider(
          create: (context) => Roleprovider(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );

    //return Examlist();
  }
}
