import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../models/paper.dart';
import '../services/app_settings_controller.dart';
import 'quiz_screen.dart';

class SectionsScreen extends StatelessWidget {
  final Paper paper;
  final AppSettingsController settingsController;

  const SectionsScreen({
    super.key,
    required this.paper,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Select Section'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: paper.sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final section = paper.sections[index];
          return InkWell(
            onTap: () {
              developer.log('SectionsScreen: Selected section "${section.nameEn}" (index: $index)');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    paper: paper,
                    settingsController: settingsController,
                    startSectionIndex: index,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.secondary,
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
                            style: theme.textTheme.titleMedium?.copyWith(
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
                            '${section.questions.length} Questions',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.6),
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
          );
        },
      ),
    );
  }
}
