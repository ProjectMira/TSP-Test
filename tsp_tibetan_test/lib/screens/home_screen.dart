import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/paper.dart';
import '../services/data_service.dart';
import '../services/score_service.dart';
import '../services/app_settings_controller.dart';
import 'paper_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppSettingsController settingsController;

  const HomeScreen({
    super.key,
    required this.settingsController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Paper>> _papersFuture;
  late Future<Map<String, YearScoreOverview>> _scoreOverviewFuture;
  final DataService _dataService = DataService();
  final ScoreService _scoreService = ScoreService();

  @override
  void initState() {
    super.initState();
    developer.log('HomeScreen: Initializing and loading papers');
    _papersFuture = _dataService.loadPapers();
    _scoreOverviewFuture = _scoreService.getYearOverviews();
  }

  void _refreshScores() {
    setState(() {
      _scoreOverviewFuture = _scoreService.getYearOverviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(widget.settingsController.tr('Past Papers', 'ལོ་སྔོན་དྲི་ཤོག')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(settingsController: widget.settingsController),
                ),
              );
              _refreshScores();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, YearScoreOverview>>(
        future: _scoreOverviewFuture,
        builder: (context, scoreSnapshot) {
          return FutureBuilder<List<Paper>>(
            future: _papersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(widget.settingsController.tr('No papers found.', 'ལོ་ཤོག་མ་རྙེད།')),
                );
              }

              final papers = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: papers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final paper = papers[index];
                  final yearScore = scoreSnapshot.data?[paper.year];
                  final totalQuestions = paper.sections.fold<int>(
                    0,
                    (sum, section) => sum + section.questions.length,
                  );
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaperDetailScreen(
                            paper: paper,
                            settingsController: widget.settingsController,
                          ),
                        ),
                      );
                      _refreshScores();
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
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.article_outlined,
                                color: colors.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.settingsController.tr(
                                      'Year ${paper.year}',
                                      'ལོ་${paper.year}',
                                    ),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.settingsController.tr(
                                      '${paper.sections.length} Sections • $totalQuestions Questions',
                                      'དོན་ཚན་${paper.sections.length} • དྲི་བ་$totalQuestions',
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    yearScore == null
                                        ? widget.settingsController.tr('No attempts yet', 'ཚོད་ལྟ་མེད།')
                                        : widget.settingsController.tr(
                                            'Attempts: ${yearScore.attempts} • Best: ${yearScore.best?.percentage.toStringAsFixed(1) ?? '0.0'}%',
                                            'ཚོད་ལྟ་${yearScore.attempts} • མཐོ་ཤོས་${yearScore.best?.percentage.toStringAsFixed(1) ?? '0.0'}%',
                                          ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurface.withValues(alpha: 0.5),
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
              );
            },
          );
        },
      ),
    );
  }
}
