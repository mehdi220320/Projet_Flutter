
class Skill {
  final int id;
  final String name;

  Skill({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}