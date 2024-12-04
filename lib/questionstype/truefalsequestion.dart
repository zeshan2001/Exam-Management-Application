import 'package:flutter/material.dart';
import 'package:projetctv0/Providers/truefalseprovider.dart';
import 'package:provider/provider.dart';

class Truefalsequestion extends StatefulWidget {
  final Map<String, dynamic> truefalseQuestion;
  final int indexOfQuestion;
  const Truefalsequestion({
    super.key,
    required this.indexOfQuestion,
    required this.truefalseQuestion,
  });

  @override
  State<Truefalsequestion> createState() => _TruefalsequestionState();
}

class _TruefalsequestionState extends State<Truefalsequestion> {
  bool? isanswerTrue;
  final List<bool> isanswerTrueList = [true, false];

  @override
  Widget build(BuildContext context) {
    if (isanswerTrue != null) {
      context
          .read<Truefalseprovider>()
          .gettruefalseanswer(answer: isanswerTrue!);
    }
    //print(isanswerTrue);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: const TextStyle(fontSize: 15),
          '${widget.indexOfQuestion + 1}. ${widget.truefalseQuestion['questionText']}',
        ),
        ListTile(
          leading: Radio(
            activeColor: Colors.green,
            value: isanswerTrueList[0],
            groupValue: isanswerTrue,
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  isanswerTrue = value;
                  //context.read<Truefalseprovider>().gettruefalseanswer(answer: value);
                }
              });
              // if (value != null) {
              //   context
              //       .read<Truefalseprovider>()
              //       .gettruefalseanswer(answer: value);
              // }
            },
          ),
          title: const Text('True'),
        ),
        ListTile(
          leading: Radio(
            activeColor: Colors.green,
            value: isanswerTrueList[1],
            groupValue: isanswerTrue,
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  isanswerTrue = value;
                }
              });
            },
          ),
          title: const Text('False'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
