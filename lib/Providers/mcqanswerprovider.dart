import 'package:flutter/material.dart';

class Mcqanswerprovider extends ChangeNotifier {
  String mcqanswer;
  Mcqanswerprovider({
    this.mcqanswer = "No mcq",
  });

  void getmcqanswer({required String answer}) {
    mcqanswer = answer;
    notifyListeners();
  }
}
