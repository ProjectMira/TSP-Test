import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../services/app_settings_controller.dart';

class ResultScreen extends StatelessWidget {
  final AppSettingsController settingsController;
  final String paperYear;
  final String scopeLabel;
  final int score;
  final int totalQuestions;
  final String timeTaken;
  final double bestPercentage;
  final int attemptsInScope;

  const ResultScreen({
    super.key,
    required this.settingsController,
    required this.paperYear,
    required this.scopeLabel,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.bestPercentage,
    required this.attemptsInScope,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final percentage = (score / totalQuestions) * 100;

    developer.log('ResultScreen: Score: $score/$totalQuestions (${percentage.toStringAsFixed(1)}%), Time: $timeTaken');

    Color resultColor = percentage >= 70
        ? colors.secondary
        : (percentage >= 40 ? Colors.orange : colors.error);

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subtleBg = isDark ? const Color(0xFF252525) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(settingsController.tr('Result', 'གྲུབ་འབྲས།')),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.black).withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.inter(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                    Text(
                      '/$totalQuestions',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                percentage >= 70
                    ? settingsController.tr('Excellent!', 'ཕུལ་བྱུང་།')
                    : (percentage >= 40
                        ? settingsController.tr('Good Job!', 'ལེགས་པོ་བྱས།')
                        : settingsController.tr('Keep Trying!', 'མུ་མཐུད་དུ་སྦྱོང་།')),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                settingsController.tr('$scopeLabel • Year $paperYear', '$scopeLabel • ལོ་$paperYear'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: subtleBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, color: colors.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Text(
                      settingsController.tr('Time Taken: $timeTaken', 'དུས་ཚོད། $timeTaken'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: subtleBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      settingsController.tr(
                        'Best for this scope: ${bestPercentage.toStringAsFixed(1)}%',
                        'ས་ཁུལ་འདིའི་མཐོ་ཤོས། ${bestPercentage.toStringAsFixed(1)}%',
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      settingsController.tr(
                        'Attempts here: $attemptsInScope',
                        'འདིར་ཚོད་ལྟ། $attemptsInScope',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    settingsController.tr('Back to Home', 'གཙོ་ངོས་ལ་ཕྱིར་ལོག'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
