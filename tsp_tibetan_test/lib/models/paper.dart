import 'section.dart';

class Paper {
  final String id;
  final String year;
  final List<Section> sections;

  Paper({
    required this.id,
    required this.year,
    required this.sections,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    var list = json['sections'] as List;
    List<Section> sectionsList = list.map((i) => Section.fromJson(i)).toList();

    return Paper(
      id: json['id'] as String,
      year: json['year'] as String,
      sections: sectionsList,
    );
  }
}
