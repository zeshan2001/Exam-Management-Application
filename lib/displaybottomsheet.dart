import 'package:flutter/material.dart';
import 'package:projetctv0/CreateExamPage.dart';
import 'package:projetctv0/Providers/getquestionsprovider.dart';
import 'package:projetctv0/examquestion.dart';
import 'package:projetctv0/firestoreservices.dart';

import 'package:provider/provider.dart';

class Displaybottomsheet extends StatefulWidget {
  const Displaybottomsheet({
    super.key,
    required this.exam,
  });
  final Map<String, dynamic> exam;

  @override
  State<Displaybottomsheet> createState() => _DisplaybottomsheetState();
}

class _DisplaybottomsheetState extends State<Displaybottomsheet> {
  // return randomized questions or same
  List getRandomOrFixedQuestionsList() {
    final myExam = widget.exam;
    if (myExam['randomizeQuestions'] == true) {
      context.read<Getquestionsprovider>().getQuestionshuf(myExam['questions']);
      return context.read<Getquestionsprovider>().qts!;
    } else {
      return myExam['questions'];
    }
  }

  String getExamDocID() {
    final myExam = widget.exam;
    return myExam['id'];
  }

  DateTime getstartDate() {
    final myExam = widget.exam;
    return DateTime.parse(myExam['startDateTime']);
  }

  DateTime getendtDate() {
    final myExam = widget.exam;
    return DateTime.parse(myExam['endDateTime']);
  }

  int getAttempts() {
    final myExam = widget.exam;
    return myExam['maxAttempts'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      height: 350,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: TextStyle(fontSize: 25),
                widget.exam['examTitle'],
              ),
              const SizedBox(height: 30),
              Text(
                "Due date: ${Exam().newDateFormat(getendtDate())}",
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 14),
              Text(
                "Time limit: ${Exam().timeLimit(getendtDate(), getstartDate())} minutes",
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 15),
              Text(
                "${getAttempts()} attempts lift",
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),

          //SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 122, 147, 147),
            ),
            onPressed: () {
              //context.read<Numattempsprovider>().getAttempts((getAttempts()));
              FirestoreService()
                  .deleteuseranswers(getExamDocID())
                  .whenComplete(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Examquestion(
                      examdocid: getExamDocID(),
                      maxattempts: getAttempts(),
                      questionsList: getRandomOrFixedQuestionsList(),
                    ),
                  ),
                );
              });
            },
            child: const Text(
              "Start Exam",
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
