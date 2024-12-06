import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projetctv0/CreateExamPage.dart';
import 'package:projetctv0/examlist.dart';
import 'package:projetctv0/firestoreservices.dart';
import 'package:projetctv0/homepage.dart';
import 'package:projetctv0/login.dart';

class AuthService {
  Future<void> signup(
      {required String email,
      required String password,
      required String role,
      required BuildContext context}) async {
    String userRole = role;
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .whenComplete(() {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        String? email = FirebaseAuth.instance.currentUser!.email;

        FirestoreService()
            .addUserEmailanduid(email ?? "No email", uid, userRole);
      });

      await Future.delayed(const Duration(seconds: 1));
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String role = await FirestoreService().getUserRole(uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              role == 'student' ? const Examlist() : CreateExamPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      // Handle specific FirebaseAuth error codes
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak. ';
          break;
        case 'email-already-in-use':
          message = 'This email address is already in use. ';
          break;
        case 'invalid-email':
          message =
              'The email address is not valid. Please enter a valid email.';
          break;
        case 'too-many-requests':
          message = 'Too many sign-up attempts. Please try again later.';
          break;
        default:
          message = 'An unexpected error occurred. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));

      String uid = FirebaseAuth.instance.currentUser!.uid;
      String role = '';

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      querySnapshot.docs.forEach((doc) {
        if (doc['uid'] == uid) {
          role = doc['role'];
        }
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              role == 'student' ? const Examlist() : CreateExamPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email' || e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }
}
