import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../models/paper.dart';
import '../services/app_settings_controller.dart';
import 'quiz_screen.dart';

class PaperDetailScreen extends StatelessWidget {
  final Paper paper;
  final AppSettingsController settingsController;

  const PaperDetailScreen({
    super.key,
    required this.paper,
    required this.settingsController,
  });

  int get _totalQuestions {
    return paper.sections.fold(0, (sum, section) => sum + section.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(settingsController.tr('Paper ${paper.year}', 'ལོ་ཤོག ${paper.year}')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                developer.log('PaperDetailScreen: Starting FULL TEST for paper ${paper.year}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      paper: paper,
                      settingsController: settingsController,
                      startSectionIndex: 0,
                      onlyOneSection: false,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                        : [const Color(0xFF2E7D32), const Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.15 : 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settingsController.tr('Start Full Test', 'ཚང་མའི་ཚོད་ལྟ་འགོ་འཛུགས།'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            settingsController.tr(
                              '$_totalQuestions Questions • ${paper.sections.length} Sections',
                              'དྲི་བ་$_totalQuestions • དོན་ཚན་${paper.sections.length}',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            settingsController.tr('Or choose a section', 'ཡང་ན་དོན་ཚན་འདེམས།'),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 16),

          ...List.generate(paper.sections.length, (index) {
            final section = paper.sections[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < paper.sections.length - 1 ? 16 : 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    developer.log('PaperDetailScreen: Starting section ${section.nameEn} (index: $index)');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          paper: paper,
                          settingsController: settingsController,
                          startSectionIndex: index,
                          onlyOneSection: true,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.nameEn,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                section.nameBo,
                                style: GoogleFonts.getFont(
                                  'Noto Serif Tibetan',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primary.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                settingsController.tr(
                                  '${section.questions.length} Questions',
                                  'དྲི་བ་${section.questions.length}',
                                ),
                                style: TextStyle(
                                  color: colors.onSurface.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: colors.onSurface.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
