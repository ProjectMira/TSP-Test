import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String timeTaken;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions) * 100;
    developer.log('🏆 ResultScreen: Displaying results - Score: $score/$totalQuestions (${percentage.toStringAsFixed(1)}%), Time: $timeTaken');
    Color resultColor = percentage >= 70
        ? Theme.of(context).colorScheme.secondary
        : (percentage >= 40 ? Colors.orange : Theme.of(context).colorScheme.error);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                percentage >= 70 ? 'Excellent!' : (percentage >= 40 ? 'Good Job!' : 'Keep Trying!'),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: const Color(0xFF1A237E),
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Time Taken: $timeTaken',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
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
                    developer.log('🏆 ResultScreen: Navigating back to home');
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
