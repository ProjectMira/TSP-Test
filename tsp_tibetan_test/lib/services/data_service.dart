import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import '../models/paper.dart';

class DataService {
  Future<List<Paper>> loadPapers() async {
    developer.log('📚 DataService: Loading papers from assets/data/papers.json');
    try {
      final String response = await rootBundle.loadString('assets/data/papers.json');
      developer.log('📚 DataService: Successfully loaded JSON data');
      final List<dynamic> data = json.decode(response);
      developer.log('📚 DataService: Parsed ${data.length} papers from JSON');
      final papers = data.map((json) => Paper.fromJson(json)).toList();
      for (var paper in papers) {
        developer.log('📚 DataService: Paper ${paper.year} has ${paper.sections.length} sections');
        for (var section in paper.sections) {
          developer.log('   📖 Section: ${section.nameEn} (${section.nameBo}) - ${section.questions.length} questions');
        }
      }
      return papers;
    } catch (e, stackTrace) {
      developer.log('❌ DataService: Error loading papers: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
