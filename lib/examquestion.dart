import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projetctv0/Providers/easyanswerprovider.dart';
import 'package:projetctv0/Providers/mcqanswerprovider.dart';
import 'package:projetctv0/Providers/shortanswerprovider.dart';
import 'package:projetctv0/Providers/truefalseprovider.dart';

import 'package:projetctv0/questionstype/mcqquestion.dart';
import 'package:projetctv0/questionstype/truefalsequestion.dart';
import 'package:projetctv0/questionstype/shortanswerquestion.dart';
import 'package:projetctv0/questionstype/easyquestion.dart';
import 'package:provider/provider.dart';

class Examquestion extends StatefulWidget {
  final List questionsList;
  final String examdocid;
  final int maxattempts;
  //final bool isRandomQuestions;
  const Examquestion({
    super.key,
    //required this.isRandomQuestions,
    required this.examdocid,
    required this.maxattempts,
    required this.questionsList,
  });

  @override
  State<Examquestion> createState() => _ExamquestionState();
}

class _ExamquestionState extends State<Examquestion> {
  // List questionIndex = [];
  List<Map<String, dynamic>> questionIndex = [];
  Widget getQuestionBasedOnType(
      Map<String, dynamic> individualQuestion, int index) {
    switch (individualQuestion['type']) {
      case 'Multiple Choice':
        return MCQQuestion(
            mcqQuestion: individualQuestion, indexOfQuestion: index);
      case 'True/False':
        return Truefalsequestion(
          truefalseQuestion: individualQuestion,
          indexOfQuestion: index,
        );
      case 'Short Answer':
        return ShortAnswerQuestion(
          shortanswerQuestion: individualQuestion,
          indexOfQuestion: index,
        );
      case 'Essay':
        return EasyQuestion(
          easyQuestion: individualQuestion,
          indexOfQuestion: index,
        );
    }
    return const Text('No question');
  }

  late Timer timeer;
  int _totalSeconds = 1232; // Example: 1232 seconds (0:20:32)

  // @override
  // void initState() {
  //   super.initState();
  //   startTimer();
  // }

  void startTimer() {
    timeer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> getSummaryData() {
    final List<Map<String, Object>> summary = [];
    String easy = context.read<Easyanswerprovider>().easyanswer;
    String short = context.read<Shortanswerprovider>().shortanswer;
    bool truefale = context.read<Truefalseprovider>().truefalseanswer;
    String mcq = context.read<Mcqanswerprovider>().mcqanswer;
    for (var i = 0; i < questionIndex.length; i++) {
      summary.add(
        {
          'questionText': questionIndex[i]['questionText'],
          'questionType': questionIndex[i]['questionType'],
          'userAnswer': questionIndex[i]['questionType'] == 'Essay'
              ? easy
              : questionIndex[i]['questionType'] == 'Short Answer'
                  ? short
                  : questionIndex[i]['questionType'] == 'Multiple Choice'
                      ? mcq
                      : truefale,
        },
      );
    }

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Exams"),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                style: const TextStyle(
                  fontSize: 15,
                ),
                "Timer: " + formatTime(_totalSeconds),
                // "Timer: ${context.watch<TimerProvider>().totalSeconds}",
                // "Timer: ${TimerProvider().formattedTime}",
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView.builder(
                  itemCount: widget.questionsList.length,
                  itemBuilder: (context, index) {
                    questionIndex.add({
                      'questionText': widget.questionsList[index]
                          ['questionText'],
                      'questionType': widget.questionsList[index]['type'],
                    });
                    return getQuestionBasedOnType(
                      widget.questionsList[index],
                      index,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 122, 147, 147),
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 100),
                  ),
                  onPressed: () async {
                    // Collect all data into a single array
                    List<Map<String, dynamic>> allAnswers =
                        getSummaryData().map((val) {
                      return {
                        'questionText': val['questionText'],
                        'user_Answers': val['userAnswer'],
                        'questionType': val['questionType'],
                      };
                    }).toList();

                    final ans = answers(
                        examdocID: widget.examdocid,
                        uid: FirebaseAuth.instance.currentUser!.uid,
                        user_answers: allAnswers);
                    ans.printsum();
                    try {
                      // Save the exam to Firestore
                      final answersCollection =
                          FirebaseFirestore.instance.collection('answers');
                      await answersCollection.add({
                        'examdocID': ans.examdocID.toString(),
                        'uid': ans.uid.toString(),
                        'user_Answers': ans.user_answers,
                      }).whenComplete(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('answers added successfully!')),
                        );
                      });

                      print(
                          'All user answers are added to the database successfully!');
                    } catch (e) {
                      print('Error while submitting answers: $e');
                    }
                  },
                  child: const Text(
                    "Submit Exam",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class answers {
  final String? uid;
  final String? examdocID;
  final List<Map<String, dynamic>>? user_answers;

  answers({
    this.uid,
    this.examdocID,
    this.user_answers,
  });

  void printsum() {
    print('uid: $uid');
    print('examdocID: $examdocID');
    //print('questions: $questions');
    for (var answer in user_answers!) {
      print('..');
      print('questionType: ${answer['questionType']}');
      print('questionText: ${answer['questionText']}');
      print('user_answer: ${answer['user_Answers']}');
      print('..');
    }
  }
}
