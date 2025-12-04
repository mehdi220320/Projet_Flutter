// providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:levelup/models/certification.dart';
import 'package:levelup/models/profile.dart';
import 'package:levelup/models/skill.dart';
import 'package:levelup/models/user.dart';
import 'package:levelup/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  Profile? _profile;
  User? _user;
  List<Skill> _allSkills = [];
  List<Certification> _allCertifications = [];
  bool _loading = false;
  bool _loadingSkills = false;
  bool _loadingCertifications = false;
  String? _error;
  String? _skillsError;
  String? _certificationsError;

  Profile? get profile => _profile;
  User? get user => _user;
  List<Skill> get allSkills => _allSkills;
  List<Certification> get allCertifications => _allCertifications;
  bool get loading => _loading;
  bool get loadingSkills => _loadingSkills;
  bool get loadingCertifications => _loadingCertifications;
  String? get error => _error;
  String? get skillsError => _skillsError;
  String? get certificationsError => _certificationsError;

  Future<void> fetchMyProfile() async {
    _loading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _profile = await _profileService.getMyProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> updateProfile({
    String? fieldOfStudy,
    List<String>? skills,
    List<String>? certifications,
  }) async {
    _loading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _profile = await _profileService.updateProfile(
        fieldOfStudy: fieldOfStudy,
        skills: skills,
        certifications: certifications,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchAllSkills() async {
    // Only fetch if not already loading and not already loaded
    if (_loadingSkills || _allSkills.isNotEmpty) return;

    _loadingSkills = true;
    _skillsError = null;
    _safeNotifyListeners();

    try {
      _allSkills = await _profileService.getAllSkills();
    } catch (e) {
      _skillsError = e.toString();
      if (kDebugMode) {
        print('Skills fetch error: $e');
      }
    } finally {
      _loadingSkills = false;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchAllCertifications() async {
    // Only fetch if not already loading and not already loaded
    if (_loadingCertifications || _allCertifications.isNotEmpty) return;

    _loadingCertifications = true;
    _certificationsError = null;
    _safeNotifyListeners();

    try {
      _allCertifications = await _profileService.getAllCertifications();
    } catch (e) {
      _certificationsError = e.toString();
      if (kDebugMode) {
        print('Certifications fetch error: $e');
      }
    } finally {
      _loadingCertifications = false;
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

  void setUser(User user) {
    _user = user;
    _safeNotifyListeners();
  }

  void clear() {
    _profile = null;
    _user = null;
    _allSkills = [];
    _allCertifications = [];
    _error = null;
    _skillsError = null;
    _certificationsError = null;
    _loading = false;
    _loadingSkills = false;
    _loadingCertifications = false;
    _safeNotifyListeners();
  }
}
