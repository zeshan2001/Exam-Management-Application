import 'package:flutter/material.dart';

class CounterNotifier extends ChangeNotifier {
  int counter;
  CounterNotifier({this.counter = 0});

  void increase() {
    counter = counter + 1;
    notifyListeners();
  }

  void decrease() {
    counter = counter - 1;
    notifyListeners();
  }
}
