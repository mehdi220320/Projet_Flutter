class University {
  final int id;
  final String name;
  final String city;
  final String country;
  final String website;
  final String emailDomain;

  University({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.website,
    required this.emailDomain,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      website: json['website'] ?? '',
      emailDomain: json['email_domain'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'website': website,
      'email_domain': emailDomain,
    };
  }

  @override
  String toString() {
    return 'University(id: $id, name: $name, city: $city, country: $country)';
  }
}