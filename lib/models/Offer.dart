import 'package:levelup/models/skill.dart';
import 'package:levelup/models/company.dart';

class Offer {
  final int id;
  final String title;
  final Company company;
  final String fieldRequired;
  final String description;
  final String location;
  final List<Skill> requiredSkills;
  final String levelRequired;
  final DateTime deadline;
  final bool isClosed;
  final double? predictedFit; // New field for recommendation score

  Offer({
    required this.id,
    required this.title,
    required this.company,
    required this.fieldRequired,
    required this.description,
    required this.location,
    required this.requiredSkills,
    required this.levelRequired,
    required this.deadline,
    required this.isClosed,
    this.predictedFit, // Optional field
  });

  String get logo {
    final titleLower = title.toLowerCase();

    if (titleLower.contains('assistant')) return '🤝';
    if (titleLower.contains('developer') || titleLower.contains('engineer'))
      return '💻';
    if (titleLower.contains('designer')) return '🎨';
    if (titleLower.contains('manager')) return '📊';
    if (titleLower.contains('analyst')) return '📈';
    if (titleLower.contains('scientist') || titleLower.contains('research'))
      return '🔬';
    if (titleLower.contains('medical') ||
        titleLower.contains('health') ||
        titleLower.contains('nurse'))
      return '🏥';
    if (titleLower.contains('teacher') || titleLower.contains('educator'))
      return '📚';
    if (titleLower.contains('finance') || titleLower.contains('accountant'))
      return '💰';
    if (titleLower.contains('sales') || titleLower.contains('marketing'))
      return '🎯';
    if (titleLower.contains('production') ||
        titleLower.contains('manufacturing'))
      return '🏭';
    if (titleLower.contains('security') || titleLower.contains('safety'))
      return '🛡️';
    if (titleLower.contains('consultant')) return '💼';
    if (titleLower.contains('director')) return '👔';

    return '🏢';
  }

  String get image {
    final titleLower = title.toLowerCase();

    // Tech roles
    if (titleLower.contains('developer') ||
        titleLower.contains('engineer') ||
        titleLower.contains('programmer') ||
        titleLower.contains('software')) {
      return "assets/images/tech_development.jpg";
    }

    // Design & Creative roles
    if (titleLower.contains('designer') ||
        titleLower.contains('creative') ||
        titleLower.contains('artist') ||
        titleLower.contains('fashion')) {
      return "assets/images/creative_design.jpeg";
    }

    // Management roles
    if (titleLower.contains('manager') ||
        titleLower.contains('director') ||
        titleLower.contains('executive') ||
        titleLower.contains('lead')) {
      return "assets/images/management.jpeg";
    }

    // Science & Research roles
    if (titleLower.contains('scientist') ||
        titleLower.contains('research') ||
        titleLower.contains('analyst') ||
        titleLower.contains('data')) {
      return "assets/images/science_research.jpg";
    }

    // Medical & Healthcare roles
    if (titleLower.contains('medical') ||
        titleLower.contains('health') ||
        titleLower.contains('nurse') ||
        titleLower.contains('doctor') ||
        titleLower.contains('care') ||
        titleLower.contains('hospital')) {
      return "assets/images/healthcare.jpeg";
    }

    // Education roles
    if (titleLower.contains('teacher') ||
        titleLower.contains('educator') ||
        titleLower.contains('professor') ||
        titleLower.contains('instructor')) {
      return "assets/images/education.jpeg";
    }

    // Finance roles
    if (titleLower.contains('finance') ||
        titleLower.contains('accountant') ||
        titleLower.contains('banking') ||
        titleLower.contains('audit')) {
      return "assets/images/finance.jpeg";
    }

    // Sales & Marketing roles
    if (titleLower.contains('sales') ||
        titleLower.contains('marketing') ||
        titleLower.contains('business') ||
        titleLower.contains('account executive')) {
      return "assets/images/sales_marketing.jpeg";
    }

    if (titleLower.contains('production') ||
        titleLower.contains('manufacturing') ||
        titleLower.contains('factory') ||
        titleLower.contains('operator')) {
      return "assets/images/production.jpeg";
    }

    // Security & Safety roles
    if (titleLower.contains('security') ||
        titleLower.contains('safety') ||
        titleLower.contains('protection') ||
        titleLower.contains('officer')) {
      return "assets/images/security.jpg";
    }

    // Assistant & Support roles
    if (titleLower.contains('assistant') ||
        titleLower.contains('support') ||
        titleLower.contains('administrative') ||
        titleLower.contains('coordinator')) {
      return "assets/images/support.jpeg";
    }

    // Default image
    return "assets/images/general_work.jpeg";
  }

  String get experience {
    if (levelRequired.toLowerCase().contains('senior')) {
      return "5+ years";
    } else if (levelRequired.toLowerCase().contains('mid') ||
        levelRequired.toLowerCase().contains('intern')) {
      return "3+ years";
    } else if (levelRequired.toLowerCase().contains('junior') ||
        levelRequired.toLowerCase().contains('entry')) {
      return "1 years";
    } else {
      return "0-1 years";
    }
  }

  int get mutualConnections => (id * 3) % 10;

  // Getter for formatted predicted fit percentage
  String get predictedFitPercentage {
    if (predictedFit == null) return '';
    return '${(predictedFit! * 100).toStringAsFixed(1)}% match';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company.toJson(),
      'field_required': fieldRequired,
      'description': description,
      'location': location,
      'required_skills': requiredSkills.map((skill) => skill.toJson()).toList(),
      'level_required': levelRequired,
      'deadline': deadline.toIso8601String(),
      'is_closed': isClosed,
      'predicted_fit': predictedFit,
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      company: Company.fromJson(json['company'] ?? {}),
      fieldRequired: json['field_required'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      requiredSkills:
          (json['required_skills'] as List<dynamic>?)
              ?.map((skillJson) => Skill.fromJson(skillJson))
              .toList() ??
          [],
      levelRequired: json['level_required'] ?? '',
      deadline: DateTime.parse(json['deadline'] ?? '2025-12-31'),
      isClosed: json['is_closed'] ?? false,
      predictedFit: json['predicted_fit']?.toDouble(),
    );
  }
}
