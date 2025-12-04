import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:levelup/models/Offer.dart';
import 'package:levelup/models/environnement.dart';
import 'package:levelup/services/authentication.dart';

class OfferService {
  final String baseUrl = Environnement().url;

  Future<List<Offer>> getRecommendedOffers() async {
    final url = Uri.parse('$baseUrl/offers/recommended/');
    final token = await AuthService().getAccessToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final List<dynamic> offersData = responseBody['offers'] ?? [];

      final List<Offer> offers = offersData.map((item) {
        final offerJson = item['offer'];
        final predictedFit = item['predicted_fit']?.toDouble();

        // Create offer with predicted fit
        final offer = Offer.fromJson(offerJson);
        return Offer(
          id: offer.id,
          title: offer.title,
          company: offer.company,
          fieldRequired: offer.fieldRequired,
          description: offer.description,
          location: offer.location,
          requiredSkills: offer.requiredSkills,
          levelRequired: offer.levelRequired,
          deadline: offer.deadline,
          isClosed: offer.isClosed,
          predictedFit: predictedFit,
        );
      }).toList();

      return offers;
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(
        responseBody['detail'] ?? 'Get Recommended Offers failed',
      );
    }
  }
}
