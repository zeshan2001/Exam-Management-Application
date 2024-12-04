import 'package:flutter/material.dart';

class Numattempsprovider extends ChangeNotifier {
  int attempt;
  Numattempsprovider({
    this.attempt = 0,
  });

  void decreaseAttempts(int ex) {
    attempt = ex--;
    notifyListeners();
  }
}
