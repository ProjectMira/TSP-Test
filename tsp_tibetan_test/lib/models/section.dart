import 'question.dart';

class Section {
  final String id;
  final String name;
  final List<Question> questions;

  Section({
    required this.id,
    required this.name,
    required this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List;
    List<Question> questionsList = list.map((i) => Question.fromJson(i)).toList();

    return Section(
      id: json['id'] as String,
      name: json['name'] as String,
      questions: questionsList,
    );
  }
}
