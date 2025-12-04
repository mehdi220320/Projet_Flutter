
class Company {
  final int id;
  final String name;
  final String industry;
  final String website;
  final String city;
  final String country;

  Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.website,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'website': website,
      'city': city,
      'country': country,
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      industry: json['industry'] ?? '',
      website: json['website'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;
}
