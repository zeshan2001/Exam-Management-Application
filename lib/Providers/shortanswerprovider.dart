import 'package:flutter/material.dart';

class Shortanswerprovider extends ChangeNotifier {
  String shortanswer;
  Shortanswerprovider({
    this.shortanswer = 'No value',
  });

  void getShortAnswer({required String answer}) async {
    shortanswer = answer;
    notifyListeners();
  }
}
