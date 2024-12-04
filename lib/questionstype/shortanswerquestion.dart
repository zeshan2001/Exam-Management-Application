import 'package:flutter/material.dart';
import 'package:projetctv0/Providers/shortanswerprovider.dart';
import 'package:provider/provider.dart';

class ShortAnswerQuestion extends StatefulWidget {
  final Map<String, dynamic> shortanswerQuestion;
  final int indexOfQuestion;
  // final List addShortAnswerResult;
  //String? addShortAnswerResult;
  //final void Function() addShortAnswerResult;
  ShortAnswerQuestion({
    super.key,
    required this.indexOfQuestion,
    required this.shortanswerQuestion,
    //required this.addShortAnswerResult,
  });

  @override
  State<ShortAnswerQuestion> createState() => _ShortAnswerQuestionState();
}

class _ShortAnswerQuestionState extends State<ShortAnswerQuestion> {
  final _formKey = GlobalKey<FormState>();
  //TextEditingController shortAnswer = TextEditingController();

  //TextEditingController easyAnswer = TextEditingController();
  //String? shortAnswer;
  void submit() {
    if (_formKey.currentState!.validate()) {
      //  .....
      // widget.addShortAnswerResult.add({
      //   'index' : widget.indexOfQuestion,
      //   'shortanswer' : shortAnswer.text,
      // });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill in all required fields before submitting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: const TextStyle(fontSize: 15),
          '${widget.indexOfQuestion + 1}. ${widget.shortanswerQuestion['questionText']}',
        ),
        const SizedBox(height: 10),
        TextFormField(
          //controller: shortAnswer,

          onChanged: (value) {
            //shortAnswer.text = value;
            //widget.addShortAnswerResult = value;
            context.read<Shortanswerprovider>().getShortAnswer(answer: value);
          },
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter your title.';
            }
            return null;
          },
          // onSaved: (value) {
          //   title.text = (value!);
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
