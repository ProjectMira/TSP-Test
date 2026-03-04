import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tsp_tibetan_test/models/paper.dart';
import 'package:tsp_tibetan_test/models/section.dart';
import 'package:tsp_tibetan_test/models/question.dart';
import 'package:tsp_tibetan_test/services/score_service.dart';
import 'package:tsp_tibetan_test/services/preferences_service.dart';
import 'package:tsp_tibetan_test/services/app_settings_controller.dart';
import 'package:tsp_tibetan_test/services/notification_service.dart';
import 'package:tsp_tibetan_test/screens/home_screen.dart';
import 'package:tsp_tibetan_test/screens/paper_detail_screen.dart';
import 'package:tsp_tibetan_test/screens/result_screen.dart';

Question _makeQuestion({
  String id = 'q1',
  String textEn = 'What is 2+2?',
  List<String> optionsEn = const ['3', '4', '5', '6'],
  int? correctOptionIndex = 1,
}) {
  return Question(
    id: id,
    textEn: textEn,
    textBo: '',
    optionsEn: optionsEn,
    optionsBo: List.filled(optionsEn.length, ''),
    correctOptionIndex: correctOptionIndex,
  );
}

Section _makeSection({
  String id = 's1',
  String nameEn = 'General Knowledge',
  String nameBo = 'སྤྱི་ཤེས།',
  int questionCount = 3,
}) {
  return Section(
    id: id,
    nameEn: nameEn,
    nameBo: nameBo,
    questions: List.generate(
      questionCount,
      (i) => _makeQuestion(id: '$id-q$i', textEn: 'Question ${i + 1}?'),
    ),
  );
}

Paper _makePaper({String year = '2024', int sectionCount = 2}) {
  return Paper(
    id: year,
    year: year,
    sections: List.generate(
      sectionCount,
      (i) => _makeSection(id: '${year}_s$i', nameEn: 'Section ${i + 1}'),
    ),
  );
}

AppSettingsController _makeController() {
  return AppSettingsController(
    preferencesService: PreferencesService(),
    notificationService: NotificationService(),
  );
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('Model tests', () {
    test('Paper has correct year and section count', () {
      final paper = _makePaper(year: '2023', sectionCount: 3);
      expect(paper.year, '2023');
      expect(paper.sections.length, 3);
    });

    test('Section contains questions', () {
      final section = _makeSection(questionCount: 5);
      expect(section.questions.length, 5);
      expect(section.name, 'General Knowledge');
    });

    test('Question has correct option index', () {
      final q = _makeQuestion(correctOptionIndex: 2);
      expect(q.correctOptionIndex, 2);
      expect(q.optionsEn.length, 4);
    });

    test('Question.fromJson round-trips correctly', () {
      final original = _makeQuestion(
        id: 'test-1',
        textEn: 'Who discovered gravity?',
        optionsEn: ['Einstein', 'Newton', 'Galileo', 'Hawking'],
        correctOptionIndex: 1,
      );

      final json = {
        'id': original.id,
        'textEn': original.textEn,
        'textBo': original.textBo,
        'optionsEn': original.optionsEn,
        'optionsBo': original.optionsBo,
        'correctOptionIndex': original.correctOptionIndex,
      };

      final restored = Question.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.textEn, original.textEn);
      expect(restored.correctOptionIndex, original.correctOptionIndex);
      expect(restored.optionsEn.length, original.optionsEn.length);
    });

    test('Paper.fromJson parses sections', () {
      final json = {
        'id': '2025',
        'year': '2025',
        'sections': [
          {
            'id': 's1',
            'nameEn': 'History',
            'nameBo': 'ལོ་རྒྱུས།',
            'questions': [
              {
                'id': 'q1',
                'textEn': 'First question?',
                'optionsEn': ['A', 'B', 'C', 'D'],
                'correctOptionIndex': 0,
              },
            ],
          },
        ],
      };

      final paper = Paper.fromJson(json);
      expect(paper.year, '2025');
      expect(paper.sections.length, 1);
      expect(paper.sections.first.nameEn, 'History');
      expect(paper.sections.first.questions.length, 1);
    });
  });

  group('ScoreService', () {
    test('PracticeAttempt calculates percentage', () {
      final attempt = PracticeAttempt(
        id: '1',
        paperYear: '2024',
        scopeKey: 'full',
        scopeLabel: 'Full Test',
        score: 7,
        totalQuestions: 10,
        durationSeconds: 120,
        completedAt: DateTime.now(),
      );
      expect(attempt.percentage, 70.0);
    });

    test('PracticeAttempt percentage is 0 when totalQuestions is 0', () {
      final attempt = PracticeAttempt(
        id: '2',
        paperYear: '2024',
        scopeKey: 'full',
        scopeLabel: 'Full Test',
        score: 0,
        totalQuestions: 0,
        durationSeconds: 0,
        completedAt: DateTime.now(),
      );
      expect(attempt.percentage, 0.0);
    });

    test('BestScoreSummary JSON round-trip', () {
      const best = BestScoreSummary(score: 8, totalQuestions: 10);
      final json = best.toJson();
      final restored = BestScoreSummary.fromJson(json);
      expect(restored.score, 8);
      expect(restored.totalQuestions, 10);
      expect(restored.percentage, 80.0);
    });

    test('PracticeAttempt JSON round-trip', () {
      final now = DateTime(2026, 3, 3, 12, 0, 0);
      final attempt = PracticeAttempt(
        id: 'test-id',
        paperYear: '2023',
        scopeKey: 'section:history',
        scopeLabel: 'History',
        score: 5,
        totalQuestions: 10,
        durationSeconds: 300,
        completedAt: now,
      );

      final json = attempt.toJson();
      final restored = PracticeAttempt.fromJson(json);
      expect(restored.id, 'test-id');
      expect(restored.paperYear, '2023');
      expect(restored.scopeKey, 'section:history');
      expect(restored.score, 5);
      expect(restored.percentage, 50.0);
    });
  });

  group('AppSettingsController', () {
    test('tr returns English by default', () {
      final controller = _makeController();
      expect(controller.tr('Hello', 'བཀྲ་ཤིས་བདེ་ལེགས།'), 'Hello');
    });

    test('default themeMode is system', () {
      final controller = _makeController();
      expect(controller.themeMode, ThemeMode.system);
    });

    test('default interfaceLanguage is english', () {
      final controller = _makeController();
      expect(controller.interfaceLanguage, InterfaceLanguage.english);
    });

    test('default reminderEnabled is false', () {
      final controller = _makeController();
      expect(controller.reminderEnabled, false);
    });
  });

  group('Widget tests', () {
    testWidgets('PaperDetailScreen shows full test button and sections', (WidgetTester tester) async {
      final paper = _makePaper(year: '2024', sectionCount: 2);
      final controller = _makeController();

      await tester.pumpWidget(_wrapWithApp(
        PaperDetailScreen(
          paper: paper,
          settingsController: controller,
        ),
      ));

      expect(find.text('Start Full Test'), findsOneWidget);
      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
      expect(find.text('Paper 2024'), findsOneWidget);
    });

    testWidgets('ResultScreen displays score and percentage message', (WidgetTester tester) async {
      final controller = _makeController();

      await tester.pumpWidget(_wrapWithApp(
        ResultScreen(
          settingsController: controller,
          paperYear: '2024',
          scopeLabel: 'Full Test',
          score: 8,
          totalQuestions: 10,
          timeTaken: '02:30',
          bestPercentage: 80.0,
          attemptsInScope: 3,
        ),
      ));

      expect(find.text('8'), findsOneWidget);
      expect(find.text('/10'), findsOneWidget);
      expect(find.text('Excellent!'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
      expect(find.text('Time Taken: 02:30'), findsOneWidget);
    });

    testWidgets('ResultScreen shows "Keep Trying" for low scores', (WidgetTester tester) async {
      final controller = _makeController();

      await tester.pumpWidget(_wrapWithApp(
        ResultScreen(
          settingsController: controller,
          paperYear: '2024',
          scopeLabel: 'History',
          score: 2,
          totalQuestions: 10,
          timeTaken: '01:00',
          bestPercentage: 20.0,
          attemptsInScope: 1,
        ),
      ));

      expect(find.text('Keep Trying!'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('ResultScreen shows "Good Job" for mid-range scores', (WidgetTester tester) async {
      final controller = _makeController();

      await tester.pumpWidget(_wrapWithApp(
        ResultScreen(
          settingsController: controller,
          paperYear: '2024',
          scopeLabel: 'Full Test',
          score: 5,
          totalQuestions: 10,
          timeTaken: '03:00',
          bestPercentage: 50.0,
          attemptsInScope: 2,
        ),
      ));

      expect(find.text('Good Job!'), findsOneWidget);
    });
  });
}
