import 'package:flutter/material.dart';

class Easyanswerprovider extends ChangeNotifier {
  String easyanswer;

  Easyanswerprovider({
    this.easyanswer = 'No easy',
  });

  void getEasyanswer({required String answer}) {
    easyanswer = answer;
    notifyListeners();
  }
}
