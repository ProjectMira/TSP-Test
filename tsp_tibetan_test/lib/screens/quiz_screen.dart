import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../models/paper.dart';
import '../models/question.dart';
import '../services/app_settings_controller.dart';
import '../services/feedback_service.dart';
import '../services/score_service.dart';
import 'result_screen.dart';

enum LanguageMode { english, tibetan, both }

class QuizScreen extends StatefulWidget {
  final Paper paper;
  final AppSettingsController settingsController;
  final int startSectionIndex;
  final bool onlyOneSection;

  const QuizScreen({
    super.key,
    required this.paper,
    required this.settingsController,
    required this.startSectionIndex,
    this.onlyOneSection = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late int currentSectionIndex;
  late int currentQuestionIndex;
  late List<Question> allQuestions;
  int score = 0;
  LanguageMode languageMode = LanguageMode.english;
  Timer? _timer;
  int _secondsElapsed = 0;

  int? _selectedOptionIndex;
  bool _isAnswered = false;
  final ScoreService _scoreService = ScoreService();
  final FeedbackService _feedbackService = FeedbackService();

  @override
  void initState() {
    super.initState();
    currentSectionIndex = widget.startSectionIndex;
    currentQuestionIndex = 0;
    _loadQuestions();
    _startTimer();
    _feedbackService.initialize();
  }

  void _loadQuestions() {
    allQuestions = [];
    if (widget.onlyOneSection) {
      final section = widget.paper.sections[widget.startSectionIndex];
      allQuestions.addAll(section.questions);
    } else {
      for (int i = 0; i < widget.paper.sections.length; i++) {
        allQuestions.addAll(widget.paper.sections[i].questions);
      }
      int startIndex = 0;
      for (int i = 0; i < widget.startSectionIndex; i++) {
        startIndex += widget.paper.sections[i].questions.length;
      }
      currentQuestionIndex = startIndex;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsElapsed ~/ 60;
    final seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _answerQuestion(int selectedIndex) {
    if (_isAnswered) return;

    final question = allQuestions[currentQuestionIndex];
    final hasKnownCorrectAnswer = question.correctOptionIndex != null;
    final isCorrect = hasKnownCorrectAnswer && selectedIndex == question.correctOptionIndex;

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = selectedIndex;
    });

    if (isCorrect) {
      score++;
      _feedbackService.playCorrect();
    } else {
      _feedbackService.playIncorrect();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (currentQuestionIndex < allQuestions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            _isAnswered = false;
            _selectedOptionIndex = null;
            _updateCurrentSectionIndex();
          });
        } else {
          _finishQuiz();
        }
      }
    });
  }

  void _updateCurrentSectionIndex() {
    if (widget.onlyOneSection) return;

    int count = 0;
    for (int i = 0; i < widget.paper.sections.length; i++) {
      count += widget.paper.sections[i].questions.length;
      if (currentQuestionIndex < count) {
        if (currentSectionIndex != i) {
          setState(() {
            currentSectionIndex = i;
          });
        }
        break;
      }
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

    final selectedSection = widget.paper.sections[widget.startSectionIndex];
    final scopeKey = widget.onlyOneSection ? 'section:${_slug(selectedSection.nameEn)}' : 'full';
    final scopeLabel = widget.onlyOneSection ? selectedSection.nameEn : 'Full Test';

    final saveResult = await _scoreService.saveAttempt(
      paperYear: widget.paper.year,
      scopeKey: scopeKey,
      scopeLabel: scopeLabel,
      score: score,
      totalQuestions: allQuestions.length,
      durationSeconds: _secondsElapsed,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          settingsController: widget.settingsController,
          paperYear: widget.paper.year,
          scopeLabel: scopeLabel,
          score: score,
          totalQuestions: allQuestions.length,
          timeTaken: _formattedTime,
          bestPercentage: saveResult.bestForScope.percentage,
          attemptsInScope: saveResult.attemptsInScope,
        ),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      if (languageMode == LanguageMode.english) {
        languageMode = LanguageMode.tibetan;
      } else if (languageMode == LanguageMode.tibetan) {
        languageMode = LanguageMode.both;
      } else {
        languageMode = LanguageMode.english;
      }
    });
  }

  String _getLanguageButtonText() {
    switch (languageMode) {
      case LanguageMode.english:
        return 'English';
      case LanguageMode.tibetan:
        return 'Tibetan';
      case LanguageMode.both:
        return 'Both';
    }
  }

  String _slug(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _optionBoAt(Question question, int index) {
    if (index < question.optionsBo.length) {
      final value = question.optionsBo[index].trim();
      if (value.isNotEmpty) return value;
    }
    return question.optionsEn[index];
  }

  String _questionTextBo(Question question) {
    final value = question.textBo.trim();
    return value.isNotEmpty ? value : question.textEn;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(child: Text(widget.settingsController.tr('No questions in this section.', 'དོན་ཚན་འདིར་དྲི་བ་མེད།'))),
      );
    }

    final question = allQuestions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                _formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _toggleLanguage,
            icon: Icon(Icons.language, color: colors.primary),
            label: Text(
              _getLanguageButtonText(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(
                  color: colors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                if (languageMode == LanguageMode.english || languageMode == LanguageMode.both)
                  Text(
                    widget.paper.sections[currentSectionIndex].nameEn,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (languageMode == LanguageMode.both) const SizedBox(height: 4),
                if (languageMode == LanguageMode.tibetan || languageMode == LanguageMode.both)
                  Text(
                    widget.paper.sections[currentSectionIndex].nameBo,
                    style: GoogleFonts.getFont(
                      'Noto Serif Tibetan',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / allQuestions.length,
                    backgroundColor: colors.onSurface.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.settingsController.tr(
                      'Question ${currentQuestionIndex + 1}/${allQuestions.length}',
                      'དྲི་བ་${currentQuestionIndex + 1}/${allQuestions.length}',
                    ),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (languageMode == LanguageMode.english || languageMode == LanguageMode.both)
                            Text(
                              question.textEn,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                                height: 1.4,
                                color: colors.onSurface,
                              ),
                            ),
                          if (languageMode == LanguageMode.both) const SizedBox(height: 16),
                          if (languageMode == LanguageMode.tibetan || languageMode == LanguageMode.both)
                            Text(
                              _questionTextBo(question),
                              style: GoogleFonts.getFont(
                                'Noto Serif Tibetan',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                                color: colors.onSurface,
                              ),
                            ),
                          const SizedBox(height: 40),
                          ...List.generate(question.optionsEn.length, (index) {
                            final isSelected = _selectedOptionIndex == index;
                            final isCorrect = question.correctOptionIndex != null && index == question.correctOptionIndex;

                            Color? backgroundColor;
                            Color? borderColor;
                            Color textColor = colors.onSurface;

                            if (_isAnswered) {
                              if (isSelected) {
                                if (isCorrect) {
                                  backgroundColor = colors.secondary.withValues(alpha: 0.2);
                                  borderColor = colors.secondary;
                                  textColor = colors.secondary;
                                } else {
                                  backgroundColor = colors.error.withValues(alpha: 0.2);
                                  borderColor = colors.error;
                                  textColor = colors.error;
                                }
                              } else if (isCorrect) {
                                backgroundColor = colors.secondary.withValues(alpha: 0.2);
                                borderColor = colors.secondary;
                                textColor = colors.secondary;
                              }
                            }

                            final defaultBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                            final defaultBorder = isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: _isAnswered ? null : () => _answerQuestion(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: backgroundColor ?? defaultBg,
                                    border: Border.all(
                                      color: borderColor ?? defaultBorder,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isAnswered && (isSelected || isCorrect)
                                              ? (isCorrect ? colors.secondary : colors.error)
                                              : colors.onSurface.withValues(alpha: 0.08),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _isAnswered && (isSelected || isCorrect)
                                                  ? Colors.white
                                                  : colors.onSurface.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (languageMode == LanguageMode.english || languageMode == LanguageMode.both)
                                              Text(
                                                question.optionsEn[index],
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: textColor,
                                                ),
                                              ),
                                            if (languageMode == LanguageMode.both) const SizedBox(height: 4),
                                            if (languageMode == LanguageMode.tibetan || languageMode == LanguageMode.both)
                                              Text(
                                                _optionBoAt(question, index),
                                                style: GoogleFonts.getFont(
                                                  'Noto Serif Tibetan',
                                                  fontSize: 18,
                                                  color: textColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (_isAnswered && isSelected)
                                        Icon(
                                          isCorrect ? Icons.check_circle : Icons.cancel,
                                          color: isCorrect ? colors.secondary : colors.error,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
