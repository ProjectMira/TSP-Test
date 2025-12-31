import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/paper.dart';

class DataService {
  Future<List<Paper>> loadPapers() async {
    final String response = await rootBundle.loadString('assets/data/papers.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Paper.fromJson(json)).toList();
  }
}
