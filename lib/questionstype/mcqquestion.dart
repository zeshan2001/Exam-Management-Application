import 'package:flutter/material.dart';
import 'package:projetctv0/Providers/mcqanswerprovider.dart';
import 'package:provider/provider.dart';

class MCQQuestion extends StatefulWidget {
  final Map<String, dynamic> mcqQuestion;
  final int indexOfQuestion;
  const MCQQuestion({
    super.key,
    required this.indexOfQuestion,
    required this.mcqQuestion,
  });

  @override
  State<MCQQuestion> createState() => _MCQQuestionState();
}

class _MCQQuestionState extends State<MCQQuestion> {
  List optionList() {
    return widget.mcqQuestion['options'];
  }

  String? mcqAnswer;
  //final mcqList = ['', '', ''];

  @override
  Widget build(BuildContext context) {
    if (mcqAnswer != null) {
      context.read<Mcqanswerprovider>().getmcqanswer(answer: mcqAnswer!);
    }
    //print(widget.mcqQuestion);
    //print(optionList());
    //print(widget.indexOfQuestion);
    //print(mcqAnswer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: const TextStyle(fontSize: 15),
          '${widget.indexOfQuestion + 1}. ${widget.mcqQuestion['questionText']}',
        ),
        ...optionList().map(
          (option) {
            return ListTile(
              leading: Radio(
                activeColor: Colors.green,
                value: option,
                groupValue: mcqAnswer,
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      mcqAnswer = value;
                    }
                  });
                },
              ),
              title: Text(option.toString()),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
