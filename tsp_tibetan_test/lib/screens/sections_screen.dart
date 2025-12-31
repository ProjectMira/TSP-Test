import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../models/paper.dart';
import 'quiz_screen.dart';

class SectionsScreen extends StatelessWidget {
  final Paper paper;

  const SectionsScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              developer.log('📖 SectionsScreen: Selected section "${section.nameEn}" (index: $index)');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    paper: paper,
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
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A237E),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            section.nameBo,
                            style: GoogleFonts.getFont(
                              'Noto Serif Tibetan',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A237E).withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${section.questions.length} Questions',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
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
