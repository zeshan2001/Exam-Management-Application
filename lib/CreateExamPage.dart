import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateExamPage extends StatefulWidget {
  @override
  _CreateExamPageState createState() => _CreateExamPageState();
}

class _CreateExamPageState extends State<CreateExamPage> {
  final _formKey = GlobalKey<FormState>();

  // Exam details
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _examTitle;
  int _maxAttempts = 1;
  bool _randomizeQuestions = false;

  // Unified list of questions
  final List<Map<String, dynamic>> _questions = [];

  // Methods to pick DateTime
  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startDateTime = selectedDateTime;
          } else if (_startDateTime != null &&
              selectedDateTime.isBefore(_startDateTime!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('End DateTime cannot be before Start DateTime.'),
              ),
            );
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _addQuestion(String type) {
    setState(() {
      switch (type) {
        case 'MCQ':
          _questions.add({
            'type': 'Multiple Choice',
            'questionText': '',
            'totalMark': 1,
            'options': ['', '', '', ''],
            'correctOptionIndex': 0,
          });
          break;
        case 'TF':
          _questions.add({
            'type': 'True/False',
            'questionText': '',
            'totalMark': 1,
            'correctAnswer': true,
          });
          break;
        case 'SA':
          _questions.add({
            'type': 'Short Answer',
            'questionText': '',
            'totalMark': 1,
          });
          break;
        case 'Essay':
          _questions.add({
            'type': 'Essay',
            'questionText': '',
            'totalMark': 1,
          });
          break;
      }
    });
  }

  Future<void> _pickFile(int questionIndex) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        final file = result.files.first;

        // Store the file name
        _questions[questionIndex]['attachmentName'] = file.name;

        if (file.bytes != null) {
          // Store the file as bytes for web
          _questions[questionIndex]['attachment'] = file.bytes;
        } else if (file.path != null) {
          // Store the file path for non-web platforms
          _questions[questionIndex]['attachment'] = file.path;
        }
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _submitExam() async {
    if (_formKey.currentState!.validate()) {
      if (_startDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a start date and time.')),
        );
        return;
      }

      if (_endDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an end date and time.')),
        );
        return;
      }

      if (_endDateTime!.isBefore(_startDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('End DateTime cannot be before Start DateTime.')),
        );
        return;
      }

      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one question.')),
        );
        return;
      }

      // Create the Exam instance
      final exam = Exam(
        startDateTime: _startDateTime!,
        endDateTime: _endDateTime!,
        examTitle: _examTitle,
        maxAttempts: _maxAttempts,
        randomizeQuestions: _randomizeQuestions,
        questions: List<Map<String, dynamic>>.from(_questions),
      );

      exam.printSummary();

      try {
        // Save the exam to Firestore
        final examCollection = FirebaseFirestore.instance.collection('exams');
        await examCollection.add({
          'startDateTime': exam.startDateTime!.toIso8601String(),
          'endDateTime': exam.endDateTime!.toIso8601String(),
          'examTitle': exam.examTitle.toString(),
          'maxAttempts': exam.maxAttempts,
          'randomizeQuestions': exam.randomizeQuestions,
          'questions': exam.questions,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam created successfully!')),
        );

        // Optionally, clear the form
        setState(() {
          _startDateTime = null;
          _endDateTime = null;
          _examTitle = '';
          _maxAttempts = 1;
          _randomizeQuestions = false;
          _questions.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create exam: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please fill in all required fields before submitting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Exam')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exam details
                ListTile(
                  title: Text('Start DateTime'),
                  subtitle: Text(_startDateTime?.toString() ?? 'Not selected'),
                  onTap: () => _pickDateTime(context, true),
                ),
                ListTile(
                  title: Text('End DateTime'),
                  subtitle: Text(_endDateTime?.toString() ?? 'Not selected'),
                  onTap: () => _pickDateTime(context, false),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Exam Title'),
                  //keyboardType: TextInputType.number,
                  //initialValue: _examTitle.toString(),
                  onChanged: (value) {
                    _examTitle = value;
                  },
                  validator: (value) =>
                      value == null ? 'Enter a exam title' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Max Attempts'),
                  keyboardType: TextInputType.number,
                  initialValue: _maxAttempts.toString(),
                  onChanged: (value) {
                    _maxAttempts = int.tryParse(value) ?? 1;
                  },
                  validator: (value) =>
                      value == null || int.tryParse(value) == null
                          ? 'Enter a valid number'
                          : null,
                ),
                SwitchListTile(
                  title: Text('Randomize Questions'),
                  value: _randomizeQuestions,
                  onChanged: (value) {
                    setState(() {
                      _randomizeQuestions = value;
                    });
                  },
                ),
                Divider(),

                // Grouped Add Buttons as ListView
                Text(
                  'Add Questions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      dense: true,
                      title: Text('Multiple Choice Question'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addQuestion('MCQ'),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('True/False Question'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addQuestion('TF'),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('Short Answer Question'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addQuestion('SA'),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: Text('Essay Question'),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addQuestion('Essay'),
                      ),
                    ),
                  ],
                ),
                Divider(),

                // Display Questions
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${question['type']} Question',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeQuestion(index),
                                ),
                              ],
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Question Text'),
                              onChanged: (value) {
                                question['questionText'] = value;
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Question text is required'
                                      : null,
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Total Mark'),
                              keyboardType: TextInputType.number,
                              initialValue: question['totalMark'].toString(),
                              onChanged: (value) {
                                question['totalMark'] =
                                    int.tryParse(value) ?? 1;
                              },
                              validator: (value) =>
                                  value == null || int.tryParse(value) == null
                                      ? 'Enter a valid number'
                                      : null,
                            ),
                            if (question['type'] == 'Multiple Choice') ...[
                              ...List.generate(4, (optionIndex) {
                                return TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Option ${optionIndex + 1}',
                                  ),
                                  onChanged: (value) {
                                    question['options'][optionIndex] = value;
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Option text is required'
                                          : null,
                                );
                              }),
                              DropdownButton<int>(
                                value: question['correctOptionIndex'],
                                items: List.generate(
                                  4,
                                  (index) => DropdownMenuItem(
                                    child: Text('Option ${index + 1}'),
                                    value: index,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    question['correctOptionIndex'] = value!;
                                  });
                                },
                              ),
                            ],
                            if (question['type'] == 'True/False') ...[
                              DropdownButton<bool>(
                                value: question['correctAnswer'],
                                items: [
                                  DropdownMenuItem(
                                      child: Text('True'), value: true),
                                  DropdownMenuItem(
                                      child: Text('False'), value: false),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    question['correctAnswer'] = value!;
                                  });
                                },
                              ),
                            ],
                            //Attachement for all
                            if (question['attachmentName'] != null) ...[
                              Text('Attachment: ${question['attachmentName']}'),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Remove the attachment
                                    question['attachment'] = null;
                                    question['attachmentName'] = null;
                                  });
                                },
                                child: Text('Remove Attachment'),
                              ),
                            ] else
                              ElevatedButton(
                                onPressed: () => _pickFile(index),
                                child: Text('Add Attachment'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: _submitExam,
                  child: Text('Submit Exam'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Exam {
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? examTitle;
  final int? maxAttempts;
  final bool? randomizeQuestions;
  final List<Map<String, dynamic>>? questions;

  Exam({
    this.startDateTime,
    this.endDateTime,
    this.examTitle,
    this.maxAttempts,
    this.randomizeQuestions,
    this.questions,
  });

  // return duration between start and end DateTime
  int timeLimit(DateTime end, DateTime start) {
    Duration duration = end.difference(start);
    return duration.inMinutes;
  }

  // return duration between start and end DateTime
  int timerSeconds(DateTime end, DateTime start) {
    Duration duration = end.difference(start);
    return duration.inSeconds;
  }

  // return dateTime in 21/6/24, 12:45 PM format
  String newDateFormat(DateTime dateTime) {
    return DateFormat('d/M/yy, h:mm a').format(dateTime);
  }

  // randomize questions
  List getShuffledQuestions(List questionList) {
    final shuffledList = List.of(questionList);
    shuffledList.shuffle();
    return shuffledList;
  }

  // timer  00:19:55  hours:minuts:seconds
  String formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // Function to print the exam summary (for debugging or verification)
  void printSummary() {
    print('Exam Details:');
    print('Start DateTime: $startDateTime');
    print('End DateTime: $endDateTime');
    print('Exam Title: $examTitle');
    print('Max Attempts: $maxAttempts');
    print('Randomize Questions: $randomizeQuestions');
    print('Total Questions: ${questions!.length}');
    for (var question in questions!) {
      print('Question: ${question['questionText']}');
      print('Type: ${question['type']}');
      print('Total Marks: ${question['totalMark']}');
      if (question['type'] == 'Multiple Choice') {
        print('Options: ${question['options']}');
        print('Correct Option Index: ${question['correctOptionIndex']}');
      }
      if (question['type'] == 'True/False') {
        print('Correct Answer: ${question['correctAnswer']}');
      }
      print('Attachment: ${question['attachmentName']}');
    }
  }
}
