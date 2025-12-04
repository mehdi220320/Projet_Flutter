import 'package:flutter/foundation.dart';
import 'package:levelup/models/Offer.dart';
import 'package:levelup/services/OfferService.dart';

class OfferProvider extends ChangeNotifier {
  final OfferService _recommendedOfferService = OfferService();

  List<Offer> _recommendedOffers = [];
  bool _loading = false;
  String? _error;

  List<Offer> get recommendedOffers => _recommendedOffers;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchRecommendedOffers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedOffers = await _recommendedOfferService
          .getRecommendedOffers();
      _recommendedOffers = fetchedOffers;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshRecommendedOffers() async {
    await fetchRecommendedOffers();
  }

  void clear() {
    _recommendedOffers = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }

  // Sort offers by predicted fit (highest first)
  List<Offer> get sortedByPredictedFit {
    final offers = List<Offer>.from(_recommendedOffers);
    offers.sort((a, b) {
      final aFit = a.predictedFit ?? 0;
      final bFit = b.predictedFit ?? 0;
      return bFit.compareTo(aFit);
    });
    return offers;
  }

  // Get highly recommended offers (above 0.4 match)
  List<Offer> get highlyRecommendedOffers {
    return _recommendedOffers
        .where(
          (offer) => offer.predictedFit != null && offer.predictedFit! > 0.4,
        )
        .toList();
  }
}
