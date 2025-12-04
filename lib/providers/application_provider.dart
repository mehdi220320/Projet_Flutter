import 'package:flutter/foundation.dart';
import 'package:levelup/services/applicationService.dart';
import 'package:levelup/models/application.dart';

class ApplicationProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _applicationResult;

  List<Application> _applications = [];

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get applicationResult => _applicationResult;

  List<Application> get applications => _applications;

  List<Application> get pendingApplications =>
      _applications.where((app) => app.status == 'pending').toList();

  List<Application> get acceptedApplications =>
      _applications.where((app) => app.status == 'accepted').toList();

  List<Application> get rejectedApplications =>
      _applications.where((app) => app.status == 'rejected').toList();

  final Applicationservice _service = Applicationservice();

  Future<void> applyToOffer(String offerId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.register(offer_id: offerId);
      _applicationResult = result;

      await fetchMyApplications();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchMyApplications() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedApplications = await _service.getMyApplications();
      _applications = fetchedApplications;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshApplications() async {
    await fetchMyApplications();
  }

  void clearApplications() {
    _applications = [];
    _error = null;
    notifyListeners();
  }

  List<Application> get sortedByDate {
    final apps = List<Application>.from(_applications);
    apps.sort((a, b) => b.id.compareTo(a.id));
    return apps;
  }

  List<Application> get sortedByPredictedFit {
    final apps = List<Application>.from(_applications);
    apps.sort((a, b) => b.predictedFit.compareTo(a.predictedFit));
    return apps;
  }

  List<Application> get highMatchApplications {
    return _applications.where((app) => app.predictedFit > 0.7).toList();
  }

  void clear() {
    _applications = [];
    _error = null;
    _loading = false;
    _applicationResult = null;
    notifyListeners();
  }
}
