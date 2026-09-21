import 'package:flutter/material.dart';

import 'question_controller.dart';

class AddQusstionPageController {
  AddQusstionPageController({
    required this.questionController,
    this.churchId,
    this.chapterId,
    this.categoryId,
    this.sectionId,
  }) {
    addOption();
    addOption();
  }

  final QuestionController questionController;
  final String? churchId;
  final String? chapterId;
  final String? categoryId;
  final String? sectionId;

  final TextEditingController quizController = TextEditingController();
  List<TextEditingController> optionControllers = [];
  int correctOptionIndex = 0;

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      if (correctOptionIndex == index) {
        correctOptionIndex = 0;
      } else if (correctOptionIndex > index) {
        correctOptionIndex--;
      }
      optionControllers.removeAt(index).dispose();
    }
  }

  Future<void> submitQuestion() async {
    final Map<String, bool> options = {};
    for (int i = 0; i < optionControllers.length; i++) {
      options[optionControllers[i].text.trim()] = (i == correctOptionIndex);
    }

    await questionController.addQuestion(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
      sectionId: sectionId,
      quiz: quizController.text.trim(),
      options: options,
    );

    quizController.clear();
    for (final controller in optionControllers) {
      controller.dispose();
    }
    optionControllers = [];
    correctOptionIndex = 0;
    addOption();
    addOption();
  }

  void dispose() {
    quizController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
  }
}