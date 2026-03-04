import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/paper.dart';
import '../models/section.dart';
import '../models/question.dart';

class DataService {
  Future<List<Paper>> loadPapers() async {
    developer.log('📚 DataService: Loading papers from english CSV assets');
    try {
      final csvPaths = await _findEnglishCsvPaths();
      final papers = <Paper>[];

      for (final path in csvPaths) {
        final paper = await _loadPaperFromCsv(path);
        if (paper != null) {
          papers.add(paper);
        }
      }

      papers.sort((a, b) => a.year.compareTo(b.year));
      for (var paper in papers) {
        developer.log('📚 DataService: Paper ${paper.year} has ${paper.sections.length} sections');
        for (var section in paper.sections) {
          developer.log('   📖 Section: ${section.nameEn} (${section.nameBo}) - ${section.questions.length} questions');
        }
      }
      return papers;
    } catch (e, stackTrace) {
      developer.log('❌ DataService: Error loading papers: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<String>> _findEnglishCsvPaths() async {
    final manifestRaw = await rootBundle.loadString('AssetManifest.json');
    final manifest = json.decode(manifestRaw) as Map<String, dynamic>;
    final csvPaths = manifest.keys
        .where(
          (key) => key.startsWith('assets/data/english-papers/') && key.toLowerCase().endsWith('.csv'),
        )
        .toList()
      ..sort();
    developer.log('📚 DataService: Found ${csvPaths.length} English CSV files');
    return csvPaths;
  }

  Future<Paper?> _loadPaperFromCsv(String assetPath) async {
    final yearMatch = RegExp(r'(\d{4})').firstMatch(assetPath);
    final year = yearMatch?.group(1);
    if (year == null) {
      developer.log('⚠️ DataService: Skipping CSV without year in filename: $assetPath');
      return null;
    }

    final csvRaw = await rootBundle.loadString(assetPath);
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(csvRaw);

    if (rows.length <= 1) {
      developer.log('⚠️ DataService: Skipping empty/invalid CSV: $assetPath');
      return null;
    }

    final headerRow = rows.first;
    final sectionColumn = _findColumnIndex(
      headerRow,
      const ['section name', 'section', 'sectionname'],
      fallback: 0,
    );
    final questionNumberColumn = _findColumnIndex(
      headerRow,
      const ['question number', 'question no', 'question no.', 'q no', 'qno'],
      fallback: 1,
    );
    final questionTextColumn = _findColumnIndex(
      headerRow,
      const ['question', 'question text'],
      fallback: 2,
    );
    final answerColumn = _findColumnIndex(
      headerRow,
      const ['answer', 'correct answer', 'correct'],
      fallback: 7,
    );
    final optionColumns = _findOptionColumns(headerRow, answerColumn);

    final List<Section> sections = [];
    final List<Question> currentQuestions = [];
    String currentSectionEn = '';
    String currentSectionBo = '';
    int generatedId = 1;

    void flushSectionIfNeeded() {
      if (currentSectionEn.isEmpty || currentQuestions.isEmpty) {
        currentQuestions.clear();
        return;
      }
      sections.add(
        Section(
          id: '${year}_${_slug(currentSectionEn)}',
          nameEn: currentSectionEn,
          nameBo: currentSectionBo,
          questions: List<Question>.from(currentQuestions),
        ),
      );
      currentQuestions.clear();
    }

    for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final sectionRaw = _cleanCell(_cell(row, sectionColumn));
      final questionNumberRaw = _cleanCell(_cell(row, questionNumberColumn));
      final questionText = _cleanCell(_cell(row, questionTextColumn));
      final optionsRaw = optionColumns.map((index) => _cleanCell(_cell(row, index))).toList();
      final answerRaw = _cleanCell(_cell(row, answerColumn));
      final hasAnyOptionData = optionsRaw.any((option) => option.isNotEmpty);

      final isSectionHeaderOnly =
          sectionRaw.isNotEmpty &&
          questionNumberRaw.isEmpty &&
          questionText.isEmpty &&
          !hasAnyOptionData &&
          answerRaw.isEmpty;
      final hasQuestionData = questionNumberRaw.isNotEmpty || questionText.isNotEmpty;

      if (isSectionHeaderOnly) {
        flushSectionIfNeeded();
        currentSectionEn = _normalizeSectionName(sectionRaw);
        currentSectionBo = _sectionNameBoFromEn(currentSectionEn);
        continue;
      }

      if (sectionRaw.isNotEmpty && currentSectionEn != _normalizeSectionName(sectionRaw)) {
        flushSectionIfNeeded();
        currentSectionEn = _normalizeSectionName(sectionRaw);
        currentSectionBo = _sectionNameBoFromEn(currentSectionEn);
      }

      if (!hasQuestionData || questionText.isEmpty) {
        developer.log('⚠️ DataService: Skipping incomplete row $rowIndex in $assetPath');
        continue;
      }

      if (currentSectionEn.isEmpty) {
        currentSectionEn = 'General';
        currentSectionBo = '';
      }

      final optionsEn = optionsRaw.where((option) => option.isNotEmpty).toList();
      if (optionsEn.length < 2) {
        developer.log('⚠️ DataService: Skipping question with insufficient options at row $rowIndex in $assetPath');
        continue;
      }

      final correctOptionIndex = _findCorrectOptionIndex(optionsEn, answerRaw);
      currentQuestions.add(
        Question(
          id: '$year-${_slug(currentSectionEn)}-${questionNumberRaw.isEmpty ? generatedId : questionNumberRaw}',
          textEn: questionText,
          textBo: '',
          optionsEn: optionsEn,
          optionsBo: List<String>.filled(optionsEn.length, ''),
          correctOptionIndex: correctOptionIndex,
        ),
      );
      generatedId++;
    }

    flushSectionIfNeeded();
    if (sections.isEmpty) {
      developer.log('⚠️ DataService: No valid sections found in $assetPath');
      return null;
    }

    return Paper(
      id: year,
      year: year,
      sections: sections,
    );
  }

  String _cleanCell(dynamic value) {
    if (value == null) {
      return '';
    }
    final text = value.toString().replaceAll('\r', '').trim();
    return text;
  }

  String _normalizeSectionName(String rawName) {
    final normalized = rawName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return normalized;
    }
    if (normalized.toLowerCase() == 'history') {
      return 'History';
    }
    if (normalized.toLowerCase() == 'politics') {
      return 'Politics';
    }
    if (normalized.toLowerCase() == 'general instructions') {
      return 'General Instructions';
    }
    if (normalized.toLowerCase() == 'general knowledge') {
      return 'General Knowledge';
    }
    if (normalized.toLowerCase() == 'history and politics' ||
        normalized.toLowerCase() == 'history & politics') {
      return 'History and Politics';
    }
    return normalized;
  }

  String _sectionNameBoFromEn(String englishName) {
    switch (englishName) {
      case 'General Knowledge':
        return 'སྤྱི་ཤེས།';
      case 'History and Politics':
        return 'ལོ་རྒྱུས་དང་སྲིད་དོན།';
      case 'History':
        return 'ལོ་རྒྱུས།';
      case 'Politics':
        return 'སྲིད་དོན།';
      case 'General Instructions':
        return 'སྤྱིར་བཏང་སློབ་སྟོན།';
      default:
        return '';
    }
  }

  int? _findCorrectOptionIndex(List<String> options, String answerRaw) {
    if (answerRaw.isEmpty) {
      return null;
    }

    final normalizedAnswer = _normalizeAnswer(answerRaw);
    for (var i = 0; i < options.length; i++) {
      if (_normalizeAnswer(options[i]) == normalizedAnswer) {
        return i;
      }
    }

    final letterMatch = RegExp(r'^[A-Da-d]$').firstMatch(answerRaw.trim());
    if (letterMatch != null) {
      final idx = answerRaw.toUpperCase().codeUnitAt(0) - 65;
      if (idx >= 0 && idx < options.length) {
        return idx;
      }
    }
    return null;
  }

  String _normalizeAnswer(String value) {
    final lowercase = value.toLowerCase().trim();
    final noTrailing = lowercase.replaceAll(RegExp(r'[.,;:!?]+$'), '');
    return noTrailing.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _slug(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  }

  int _findColumnIndex(
    List<dynamic> headerRow,
    List<String> candidates, {
    required int fallback,
  }) {
    for (var i = 0; i < headerRow.length; i++) {
      final normalized = _normalizeHeader(_cleanCell(headerRow[i]));
      if (candidates.any((candidate) => normalized == _normalizeHeader(candidate))) {
        return i;
      }
    }
    return fallback;
  }

  List<int> _findOptionColumns(List<dynamic> headerRow, int answerColumn) {
    final optionColumns = <int>[];
    for (var i = 0; i < headerRow.length; i++) {
      final normalized = _normalizeHeader(_cleanCell(headerRow[i]));
      if (normalized.startsWith('option')) {
        optionColumns.add(i);
      }
    }

    if (optionColumns.isNotEmpty) {
      optionColumns.sort();
      return optionColumns;
    }

    final fallbackOptions = <int>[];
    for (var i = 3; i < answerColumn; i++) {
      fallbackOptions.add(i);
    }
    return fallbackOptions;
  }

  String _normalizeHeader(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  dynamic _cell(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) {
      return '';
    }
    return row[index];
  }
}
