import 'package:levelup/models/skill.dart';

class Certification {
  final int id;
  final String name;
  final String issuer;
  final String? issuedAt;
  final String level;
  final List<Skill> skills;

  Certification({
    required this.id,
    required this.name,
    required this.issuer,
    this.issuedAt,
    required this.level,
    required this.skills,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      issuer: json['issuer'] ?? '',
      issuedAt: json['issued_at'],
      level: json['level'] ?? '',
      skills: (json['skills'] as List<dynamic>?)
          ?.map((skillJson) => Skill.fromJson(skillJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'issued_at': issuedAt,
      'level': level,
      'skills': skills.map((skill) => skill.toJson()).toList(),
    };
  }
}
