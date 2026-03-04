import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PracticeAttempt {
  final String id;
  final String paperYear;
  final String scopeKey;
  final String scopeLabel;
  final int score;
  final int totalQuestions;
  final int durationSeconds;
  final DateTime completedAt;

  PracticeAttempt({
    required this.id,
    required this.paperYear,
    required this.scopeKey,
    required this.scopeLabel,
    required this.score,
    required this.totalQuestions,
    required this.durationSeconds,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paperYear': paperYear,
      'scopeKey': scopeKey,
      'scopeLabel': scopeLabel,
      'score': score,
      'totalQuestions': totalQuestions,
      'durationSeconds': durationSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory PracticeAttempt.fromJson(Map<String, dynamic> json) {
    return PracticeAttempt(
      id: json['id'] as String,
      paperYear: json['paperYear'] as String,
      scopeKey: json['scopeKey'] as String,
      scopeLabel: json['scopeLabel'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      durationSeconds: json['durationSeconds'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  double get percentage => totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;
}

class BestScoreSummary {
  final int score;
  final int totalQuestions;

  const BestScoreSummary({
    required this.score,
    required this.totalQuestions,
  });

  double get percentage => totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
    };
  }

  factory BestScoreSummary.fromJson(Map<String, dynamic> json) {
    return BestScoreSummary(
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
    );
  }
}

class ScoreSaveResult {
  final BestScoreSummary bestForScope;
  final int attemptsInScope;

  const ScoreSaveResult({
    required this.bestForScope,
    required this.attemptsInScope,
  });
}

class YearScoreOverview {
  final int attempts;
  final BestScoreSummary? best;

  const YearScoreOverview({
    required this.attempts,
    required this.best,
  });
}

class ScoreService {
  static const _attemptsKey = 'score_attempts_v1';
  static const _bestKey = 'score_best_v1';
  static const _maxStoredAttempts = 500;

  Future<ScoreSaveResult> saveAttempt({
    required String paperYear,
    required String scopeKey,
    required String scopeLabel,
    required int score,
    required int totalQuestions,
    required int durationSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final attempt = PracticeAttempt(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      paperYear: paperYear,
      scopeKey: scopeKey,
      scopeLabel: scopeLabel,
      score: score,
      totalQuestions: totalQuestions,
      durationSeconds: durationSeconds,
      completedAt: DateTime.now(),
    );

    final attempts = await getAttempts();
    attempts.insert(0, attempt);
    if (attempts.length > _maxStoredAttempts) {
      attempts.removeRange(_maxStoredAttempts, attempts.length);
    }

    final attemptsJson = attempts.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_attemptsKey, attemptsJson);

    final bestMap = await _readBestMap();
    final compositeKey = _compositeKey(paperYear, scopeKey);
    final currentBest = bestMap[compositeKey];
    if (currentBest == null || attempt.percentage >= currentBest.percentage) {
      bestMap[compositeKey] = BestScoreSummary(
        score: score,
        totalQuestions: totalQuestions,
      );
      await _writeBestMap(bestMap);
    }

    final attemptsInScope = attempts
        .where((item) => item.paperYear == paperYear && item.scopeKey == scopeKey)
        .length;

    return ScoreSaveResult(
      bestForScope: bestMap[compositeKey]!,
      attemptsInScope: attemptsInScope,
    );
  }

  Future<List<PracticeAttempt>> getAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_attemptsKey) ?? <String>[];
    final attempts = <PracticeAttempt>[];
    for (final item in rawList) {
      try {
        final decoded = json.decode(item) as Map<String, dynamic>;
        attempts.add(PracticeAttempt.fromJson(decoded));
      } catch (_) {
        // Skip malformed historical rows.
      }
    }
    return attempts;
  }

  Future<BestScoreSummary?> getBestForScope(String paperYear, String scopeKey) async {
    final map = await _readBestMap();
    return map[_compositeKey(paperYear, scopeKey)];
  }

  Future<Map<String, YearScoreOverview>> getYearOverviews() async {
    final attempts = await getAttempts();
    final bestMap = await _readBestMap();
    final years = <String>{...attempts.map((item) => item.paperYear)};
    final result = <String, YearScoreOverview>{};

    for (final year in years) {
      final attemptsForYear = attempts.where((item) => item.paperYear == year).toList();
      BestScoreSummary? best;
      for (final entry in bestMap.entries) {
        if (entry.key.startsWith('$year|')) {
          final candidate = entry.value;
          if (best == null || candidate.percentage > best.percentage) {
            best = candidate;
          }
        }
      }

      result[year] = YearScoreOverview(
        attempts: attemptsForYear.length,
        best: best,
      );
    }

    return result;
  }

  Future<Map<String, BestScoreSummary>> _readBestMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bestKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final bestMap = <String, BestScoreSummary>{};
    for (final entry in decoded.entries) {
      try {
        bestMap[entry.key] = BestScoreSummary.fromJson(entry.value as Map<String, dynamic>);
      } catch (_) {
        // Skip malformed row.
      }
    }
    return bestMap;
  }

  Future<void> _writeBestMap(Map<String, BestScoreSummary> map) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = map.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_bestKey, json.encode(encoded));
  }

  String _compositeKey(String paperYear, String scopeKey) => '$paperYear|$scopeKey';
}
