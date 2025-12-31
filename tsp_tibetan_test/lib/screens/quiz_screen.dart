import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../models/paper.dart';
import '../models/question.dart';
import 'result_screen.dart';

enum LanguageMode { english, tibetan, both }

class QuizScreen extends StatefulWidget {
  final Paper paper;
  final int startSectionIndex;
  final bool onlyOneSection;

  const QuizScreen({
    super.key,
    required this.paper,
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

  @override
  void initState() {
    super.initState();
    developer.log('🎯 QuizScreen: Initializing quiz for paper ${widget.paper.year}');
    developer.log('🎯 QuizScreen: Start section: ${widget.startSectionIndex}, Only one section: ${widget.onlyOneSection}');
    currentSectionIndex = widget.startSectionIndex;
    currentQuestionIndex = 0;
    _loadQuestions();
    _startTimer();
  }

  void _loadQuestions() {
    allQuestions = [];
    if (widget.onlyOneSection) {
      final section = widget.paper.sections[widget.startSectionIndex];
      developer.log('🎯 QuizScreen: Loading single section "${section.nameEn}" with ${section.questions.length} questions');
      allQuestions.addAll(section.questions);
    } else {
      developer.log('🎯 QuizScreen: Loading ALL sections');
      for (int i = 0; i < widget.paper.sections.length; i++) {
        final section = widget.paper.sections[i];
        developer.log('   📖 Adding section "${section.nameEn}" with ${section.questions.length} questions');
        allQuestions.addAll(section.questions);
      }
      // Adjust currentQuestionIndex to point to the start of the selected section
      int startIndex = 0;
      for (int i = 0; i < widget.startSectionIndex; i++) {
        startIndex += widget.paper.sections[i].questions.length;
      }
      currentQuestionIndex = startIndex;
      developer.log('🎯 QuizScreen: Starting at question index $startIndex');
    }
    developer.log('🎯 QuizScreen: Total questions loaded: ${allQuestions.length}');
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
    final isCorrect = selectedIndex == question.correctOptionIndex;
    developer.log('🎯 QuizScreen: Question ${currentQuestionIndex + 1} answered: selected=$selectedIndex, correct=${question.correctOptionIndex}, isCorrect=$isCorrect');

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = selectedIndex;
    });

    if (isCorrect) {
      score++;
      developer.log('🎯 QuizScreen: Score updated to $score');
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

  void _jumpToSection(int sectionIndex) {
    if (widget.onlyOneSection) return;

    int startIndex = 0;
    for (int i = 0; i < sectionIndex; i++) {
      startIndex += widget.paper.sections[i].questions.length;
    }

    setState(() {
      currentSectionIndex = sectionIndex;
      currentQuestionIndex = startIndex;
      _isAnswered = false;
      _selectedOptionIndex = null;
    });
  }

  void _finishQuiz() {
    _timer?.cancel();
    developer.log('🎯 QuizScreen: Quiz finished! Score: $score/${allQuestions.length}, Time: $_formattedTime');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: allQuestions.length,
          timeTaken: _formattedTime,
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
      developer.log('🎯 QuizScreen: Language mode changed to ${languageMode.name}');
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

  @override
  Widget build(BuildContext context) {
    if (allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions in this section.')),
      );
    }

    final question = allQuestions[currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                _formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _toggleLanguage,
            icon: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            label: Text(
              _getLanguageButtonText(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (languageMode == LanguageMode.both)
                  const SizedBox(height: 4),
                if (languageMode == LanguageMode.tibetan || languageMode == LanguageMode.both)
                  Text(
                    widget.paper.sections[currentSectionIndex].nameBo,
                    style: GoogleFonts.getFont(
                      'Noto Serif Tibetan',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Question ${currentQuestionIndex + 1}/${allQuestions.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey[600],
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
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontSize: 22,
                                    height: 1.4,
                                  ),
                            ),
                          if (languageMode == LanguageMode.both) const SizedBox(height: 16),
                          if (languageMode == LanguageMode.tibetan || languageMode == LanguageMode.both)
                            Text(
                              question.textBo,
                              style: GoogleFonts.getFont(
                                'Noto Serif Tibetan',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                          const SizedBox(height: 40),
                          ...List.generate(question.optionsEn.length, (index) {
                            final isSelected = _selectedOptionIndex == index;
                            final isCorrect = index == question.correctOptionIndex;
                            
                            Color? backgroundColor;
                            Color? borderColor;
                            Color textColor = Colors.black87;

                            if (_isAnswered) {
                              if (isSelected) {
                                if (isCorrect) {
                                  backgroundColor = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);
                                  borderColor = Theme.of(context).colorScheme.secondary;
                                  textColor = Theme.of(context).colorScheme.secondary;
                                } else {
                                  backgroundColor = Theme.of(context).colorScheme.error.withValues(alpha: 0.2);
                                  borderColor = Theme.of(context).colorScheme.error;
                                  textColor = Theme.of(context).colorScheme.error;
                                }
                              } else if (isCorrect) {
                                // Show correct answer even if not selected
                                backgroundColor = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);
                                borderColor = Theme.of(context).colorScheme.secondary;
                                textColor = Theme.of(context).colorScheme.secondary;
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: _isAnswered ? null : () => _answerQuestion(index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: backgroundColor ?? Colors.white,
                                    border: Border.all(
                                      color: borderColor ?? Colors.grey.shade300,
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
                                              ? (isCorrect ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error)
                                              : Colors.grey.shade100,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index), // A, B, C, D
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _isAnswered && (isSelected || isCorrect)
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
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
                                                question.optionsBo[index],
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
                                          color: isCorrect ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
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
