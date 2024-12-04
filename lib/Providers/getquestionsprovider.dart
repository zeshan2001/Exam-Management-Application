import 'package:flutter/material.dart';
import 'package:projetctv0/CreateExamPage.dart';

class Getquestionsprovider extends ChangeNotifier {
  List? qts;
  Getquestionsprovider({
    this.qts,
  });

  void getQuestionshuf(myExam) {
    qts = Exam().getShuffledQuestions(myExam);
    notifyListeners();
  }
}
