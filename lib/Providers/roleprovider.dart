import 'package:flutter/foundation.dart';

class Roleprovider extends ChangeNotifier {
  String role;
  Roleprovider({this.role = ''});

  void getrole(String ro) {
    role = ro;
    notifyListeners();
  }
}
