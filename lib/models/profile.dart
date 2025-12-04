// lib/models/profile.dart

import 'package:levelup/models/user.dart';

class Profile {
  final int id;
  final User user;
  final String role;
  final String fieldOfStudy;
  final double gpa;
  final int score;
  final University? university;
  final dynamic company; 
  final List<String> skills;
  final List<dynamic> certifications; 
  final bool isVerified;

  Profile({
    required this.id,
    required this.user,
    required this.role,
    required this.fieldOfStudy,
    required this.gpa,
    required this.score,
    this.university,
    this.company,
    required this.skills,
    required this.certifications,
    required this.isVerified,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}), // Parse user object
      role: json['role'] ?? '',
      fieldOfStudy: json['field_of_study'] ?? '',
      gpa: double.tryParse(json['gpa']?.toString() ?? '0.0') ?? 0.0,
      score: json['score'] ?? 0,
      university: json['university'] != null
          ? University.fromJson(json['university'])
          : null,
      company: json['company'],
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((skill) => skill.toString()) // Convert to string
              .toList() ??
          [],
      certifications: json['certifications'] as List<dynamic>? ?? [],
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'role': role,
      'field_of_study': fieldOfStudy,
      'gpa': gpa.toString(),
      'score': score,
      'university': university?.toJson(),
      'company': company,
      'skills': skills,
      'certifications': certifications,
      'is_verified': isVerified,
    };
  }
}

class University {
  final int id;
  final String name;
  final String city;
  final String country;

  University({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'city': city, 'country': country};
  }
}
