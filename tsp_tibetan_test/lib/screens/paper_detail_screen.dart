import 'package:flutter/material.dart';
import '../models/paper.dart';
import 'quiz_screen.dart';


class PaperDetailScreen extends StatelessWidget {
  final Paper paper;

  const PaperDetailScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Paper ${paper.year}'),
      ),
      body: Column(
        children: [
          // Top Section: Big Green Start Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Start from the first section and go through all
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Full Paper',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Bottom Section: List of Sections
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: paper.sections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final section = paper.sections[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Section Start Button (Green, Left)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Start only this section
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
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.green,
                              size: 30,
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
                              section.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                            const SizedBox(height: 4),
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
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
