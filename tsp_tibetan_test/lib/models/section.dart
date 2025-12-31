import 'question.dart';

class Section {
  final String id;
  final String nameEn;
  final String nameBo;
  final List<Question> questions;

  // Fallback for backward compatibility if needed, or just a getter
  String get name => nameEn; 

  Section({
    required this.id,
    required this.nameEn,
    required this.nameBo,
    required this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List;
    List<Question> questionsList = list.map((i) => Question.fromJson(i)).toList();

    return Section(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String? ?? json['name'] as String, // Fallback to 'name' if 'nameEn' missing
      nameBo: json['nameBo'] as String? ?? '', // Default to empty if missing
      questions: questionsList,
    );
  }
}
