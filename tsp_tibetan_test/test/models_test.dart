import 'package:flutter_test/flutter_test.dart';
import 'package:tsp_tibetan_test/models/question.dart';
import 'package:tsp_tibetan_test/models/section.dart';
import 'package:tsp_tibetan_test/models/paper.dart';

void main() {
  group('Model Tests', () {
    test('Question.fromJson parses correctly', () {
      final json = {
        "id": "q1",
        "textEn": "Question?",
        "textBo": "དྲི་བ།",
        "optionsEn": ["A", "B"],
        "optionsBo": ["ཀ", "ཁ"],
        "correctOptionIndex": 0
      };
      final question = Question.fromJson(json);
      expect(question.id, "q1");
      expect(question.textEn, "Question?");
      expect(question.optionsBo.length, 2);
    });

    test('Section.fromJson parses correctly', () {
      final json = {
        "id": "s1",
        "name": "Section A",
        "questions": [
          {
            "id": "q1",
            "textEn": "Q1",
            "textBo": "Q1Bo",
            "optionsEn": ["A"],
            "optionsBo": ["A"],
            "correctOptionIndex": 0
          }
        ]
      };
      final section = Section.fromJson(json);
      expect(section.name, "Section A");
      expect(section.questions.length, 1);
    });

    test('Paper.fromJson parses correctly', () {
      final json = {
        "id": "p1",
        "year": "2024",
        "sections": []
      };
      final paper = Paper.fromJson(json);
      expect(paper.year, "2024");
      expect(paper.sections, isEmpty);
    });
  });
}
