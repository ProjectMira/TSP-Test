import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_fonts/google_fonts.dart';
import '../models/paper.dart';
import 'quiz_screen.dart';


class PaperDetailScreen extends StatelessWidget {
  final Paper paper;

  const PaperDetailScreen({super.key, required this.paper});

  int get _totalQuestions {
    return paper.sections.fold(0, (sum, section) => sum + section.questions.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Paper ${paper.year}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Start Full Test Button - Green at the top
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                developer.log('📄 PaperDetailScreen: Starting FULL TEST for paper ${paper.year}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      paper: paper,
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
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
                          const Text(
                            'Start Full Test',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalQuestions Questions • ${paper.sections.length} Sections',
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
          
          // Sections Header
          Text(
            'Or choose a section',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Individual Sections List
          ...List.generate(paper.sections.length, (index) {
            final section = paper.sections[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < paper.sections.length - 1 ? 16 : 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    developer.log('📄 PaperDetailScreen: Starting section ${section.nameEn} (index: $index)');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          paper: paper,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Section Number Badge
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Section Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.nameEn,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
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
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow indicator
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
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
