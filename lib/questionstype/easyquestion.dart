import 'package:flutter/material.dart';
import 'package:projetctv0/Providers/easyanswerprovider.dart';
import 'package:provider/provider.dart';

class EasyQuestion extends StatefulWidget {
  final Map<String, dynamic> easyQuestion;
  final int indexOfQuestion;
  const EasyQuestion({
    super.key,
    required this.indexOfQuestion,
    required this.easyQuestion,
  });

  @override
  State<EasyQuestion> createState() => _EasyQuestionState();
}

class _EasyQuestionState extends State<EasyQuestion> {
  final _formKey = GlobalKey<FormState>();
  //TextEditingController easyAnswer = TextEditingController();
  //String? easyAnswer;
  void submit() {
    if (_formKey.currentState!.validate()) {
      //  .....
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
    //print(easyAnswer);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: const TextStyle(fontSize: 15),
          '${widget.indexOfQuestion + 1}. ${widget.easyQuestion['questionText']}',
        ),
        const SizedBox(height: 10),
        TextFormField(
          //controller: easyAnswer,
          onChanged: (value) {
            //shortAnswer.text = value;
            //widget.addShortAnswerResult = value;
            context.read<Easyanswerprovider>().getEasyanswer(answer: value);
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
          maxLines: 5,
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