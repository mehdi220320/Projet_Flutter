// providers/university_provider.dart
import 'package:flutter/foundation.dart';
import 'package:levelup/models/university.dart';
import 'package:levelup/services/universitiesService.dart';

class UniversityProvider extends ChangeNotifier {
  final UniversityService _universityService = UniversityService();

  List<University> _universities = [];
  bool _loading = false;
  String? _error;

  List<University> get universities => _universities;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchAllUniversities() async {
    // Only fetch if not already loading
    if (_loading) return;

    _loading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _universities = await _universityService.getAllUniversities();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Universities fetch error: $e');
      }
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  // Safe method to notify listeners without causing build phase conflicts
  void _safeNotifyListeners() {
    Future.microtask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  void clear() {
    _universities = [];
    _error = null;
    _loading = false;
    _safeNotifyListeners();
  }
}
