import 'package:flutter/material.dart';
import 'package:projetctv0/CreateExamPage.dart';
import 'package:projetctv0/displaybottomsheet.dart';
import 'package:projetctv0/firestoreservices.dart';

class Examlist extends StatefulWidget {
  const Examlist({super.key});

  @override
  State<Examlist> createState() => _ExamlistState();
}

class _ExamlistState extends State<Examlist> {
  final FirestoreService FirestoreServiceConstruct = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: CreateExamPage(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Exams"),
        ),
        body: Column(
          children: [
            const Text("Exam List"),
            const SizedBox(height: 50),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreServiceConstruct.getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No items available.'));
                    }

                    final examList = snapshot.data!;
                    return ListView.builder(
                      itemCount: examList.length,
                      itemBuilder: (context, index) {
                        final exam = examList[index];
                        final examTitle = exam['examTitle'];
                        final DateTime startDate =
                            DateTime.parse(exam['startDateTime']);
                        final DateTime dueDate =
                            DateTime.parse(exam['endDateTime']);
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Displaybottomsheet(
                                      exam: exam,
                                    );
                                  },
                                );
                              },
                              child: Card(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.quiz_sharp),
                                        title: Text(examTitle),
                                      ),
                                      //newDateFormat() and timeLimit() available in Exam class
                                      Text(
                                          "Due date: ${Exam().newDateFormat(dueDate)} | Time limit: ${Exam().timeLimit(dueDate, startDate)} minutes"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
