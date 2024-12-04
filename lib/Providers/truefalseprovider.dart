import 'package:flutter/material.dart';

class Truefalseprovider extends ChangeNotifier {
  bool truefalseanswer;
  Truefalseprovider({
    this.truefalseanswer = false,
  });

  void gettruefalseanswer({required bool answer}) {
    truefalseanswer = answer;
    notifyListeners();
  }
}
