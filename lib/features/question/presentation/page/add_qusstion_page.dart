import 'package:flutter/material.dart';
import 'package:aner_astaner/features/question/presentation/controllers/question_controller.dart';
import 'package:get/get.dart';

import '../controllers/add_qusstion_page_controller.dart';

class addQusstionPage extends StatefulWidget {
  final String? ChurchID;
  final String? ChapterID;
  final String? AlngelID;
  final String? AlshahatID;

  const addQusstionPage({
    super.key,
    this.ChurchID,
    this.ChapterID,
    this.AlngelID,
    this.AlshahatID,
  });
  @override
  _addQusstionPageState createState() => _addQusstionPageState();
}

class _addQusstionPageState extends State<addQusstionPage> {
  final _formKey = GlobalKey<FormState>();

  late final pageController = AddQusstionPageController(
    questionController: Get.find<QuestionController>(),
    churchId: widget.ChurchID,
    chapterId: widget.ChapterID,
    categoryId: widget.AlngelID,
    sectionId: widget.AlshahatID,
  );

  void _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      await pageController.submitQuestion();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إضافة السؤال بنجاح')));

      setState(() {});
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة سؤال')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: pageController.quizController,
                decoration: InputDecoration(labelText: 'نص السؤال'),
                validator: (value) => value!.isEmpty ? 'أدخل نص السؤال' : null,
              ),
              SizedBox(height: 16),
              Text('الخيارات:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...pageController.optionControllers.asMap().entries.map((
                entry,
              ) {
                int index = entry.key;
                TextEditingController controller = entry.value;

                return Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: pageController.correctOptionIndex,
                      onChanged: (value) {
                        setState(() {
                          pageController.correctOptionIndex = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'الخيار ${index + 1}',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'أدخل الخيار' : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          pageController.removeOption(index);
                        });
                      },
                    ),
                  ],
                );
              }),
              SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    pageController.addOption();
                  });
                },
                icon: Icon(Icons.add),
                label: Text('إضافة خيار'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitQuestion,
                child: Text('حفظ السؤال'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}