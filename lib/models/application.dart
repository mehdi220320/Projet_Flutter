import 'package:flutter/material.dart';
import 'package:levelup/models/Offer.dart';
import 'package:levelup/models/user.dart';

class Application {
  final int id;
  final User user;
  final Offer offer;
  final String status;
  final double predictedFit;

  Application({
    required this.id,
    required this.user,
    required this.offer,
    required this.status,
    required this.predictedFit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'offer': offer.toJson(),
      'status': status,
      'predicted_fit': predictedFit,
    };
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      offer: Offer.fromJson(json['offer'] ?? {}),
      status: json['status'] ?? 'pending',
      predictedFit: json['predicted_fit']?.toDouble() ?? 0.0,
    );
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String get predictedFitPercentage {
    return '${(predictedFit * 100).toStringAsFixed(1)}% match';
  }

  Color get predictedFitColor {
    if (predictedFit >= 0.7) return Colors.green;
    if (predictedFit >= 0.5) return Colors.orange;
    return Colors.red;
  }
}