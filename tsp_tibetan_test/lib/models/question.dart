class Question {
  final String id;
  final String textEn;
  final String textBo;
  final List<String> optionsEn;
  final List<String> optionsBo;
  final int? correctOptionIndex;

  Question({
    required this.id,
    required this.textEn,
    required this.textBo,
    required this.optionsEn,
    required this.optionsBo,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final optionsEn = List<String>.from(json['optionsEn']);
    final optionsBoRaw = List<String>.from(json['optionsBo'] ?? const <String>[]);
    final optionsBo = optionsBoRaw.length == optionsEn.length
        ? optionsBoRaw
        : List<String>.filled(optionsEn.length, '');

    return Question(
      id: json['id'] as String,
      textEn: json['textEn'] as String,
      textBo: json['textBo'] as String? ?? '',
      optionsEn: optionsEn,
      optionsBo: optionsBo,
      correctOptionIndex: json['correctOptionIndex'] as int?,
    );
  }
}
