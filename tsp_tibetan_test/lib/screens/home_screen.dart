import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/paper.dart';
import '../services/data_service.dart';
import 'paper_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Paper>> _papersFuture;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    developer.log('🏠 HomeScreen: Initializing and loading papers');
    _papersFuture = _dataService.loadPapers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Past Papers'),
      ),
      body: FutureBuilder<List<Paper>>(
        future: _papersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No papers found.'));
          }

          final papers = snapshot.data!;
          developer.log('🏠 HomeScreen: Displaying ${papers.length} papers');
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: papers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final paper = papers[index];
              return InkWell(
                onTap: () {
                  developer.log('🏠 HomeScreen: Tapped on Paper ${paper.year}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaperDetailScreen(paper: paper),
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
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.article_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Year ${paper.year}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A237E),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${paper.sections.length} Sections',
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
          );
        },
      ),
    );
  }
}
