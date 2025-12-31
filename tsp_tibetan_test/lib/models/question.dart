class Question {
  final String id;
  final String textEn;
  final String textBo;
  final List<String> optionsEn;
  final List<String> optionsBo;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.textEn,
    required this.textBo,
    required this.optionsEn,
    required this.optionsBo,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      textEn: json['textEn'] as String,
      textBo: json['textBo'] as String,
      optionsEn: List<String>.from(json['optionsEn']),
      optionsBo: List<String>.from(json['optionsBo']),
      correctOptionIndex: json['correctOptionIndex'] as int,
    );
  }
}
