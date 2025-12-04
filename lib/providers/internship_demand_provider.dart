import 'package:flutter/material.dart';
import 'package:levelup/models/internship_demand.dart';
import 'package:levelup/services/internship_demand_service.dart';

class InternshipDemandProvider extends ChangeNotifier {
  final InternshipDemandService _service;
  List<InternshipDemand> _demands = [];
  bool _loading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 20;

  InternshipDemandProvider({InternshipDemandService? service})
    : _service = service ?? InternshipDemandService();

  // Getters
  List<InternshipDemand> get demands => _demands;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Filtered lists
  List<InternshipDemand> get pendingDemands =>
      _demands.where((d) => d.status.toLowerCase() == 'pending').toList();

  List<InternshipDemand> get approvedDemands =>
      _demands.where((d) => d.status.toLowerCase() == 'approved').toList();

  List<InternshipDemand> get rejectedDemands =>
      _demands.where((d) => d.status.toLowerCase() == 'rejected').toList();

  // Sorted by date (newest first)
  List<InternshipDemand> get sortedByDate {
    final sorted = List<InternshipDemand>.from(_demands);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> fetchMyDemands({bool refresh = false}) async {
    if (refresh) {
      _demands.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newDemands = await _service.getMyDemands();

      if (refresh) {
        _demands = newDemands;
      } else {
        _demands.addAll(newDemands);
      }

      _hasMore = newDemands.length >= _perPage;
      if (newDemands.isNotEmpty) {
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
      if (_demands.isEmpty) {
        _demands = [];
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // NEW: Simple create demand with just application ID
  Future<bool> createSimpleDemand({required int applicationId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newDemand = await _service.createSimpleDemand(
        applicationId: applicationId,
      );

      _demands.insert(0, newDemand);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Keep old method for backward compatibility
  Future<bool> createDemand({
    required String university,
    required int applicationId,
    required String offerTitle,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final newDemand = await _service.createDemand(
        university: university,
        applicationId: applicationId,
        offerTitle: offerTitle,
      );

      _demands.insert(0, newDemand);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> requestAttestation(int demandId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.requestAttestation(demandId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDemandStatus(int demandId, String status) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDemand = await _service.updateDemandStatus(demandId, status);

      final index = _demands.indexWhere((d) => d.id == demandId);
      if (index != -1) {
        _demands[index] = updatedDemand;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDemand(int demandId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDemand(demandId);

      _demands.removeWhere((d) => d.id == demandId);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Check if a demand already exists for an application
  bool demandExistsForApplication(int applicationId) {
    return _demands.any((demand) => demand.application == applicationId);
  }

  // Get demand by application ID
  InternshipDemand? getDemandByApplicationId(int applicationId) {
    try {
      return _demands.firstWhere(
        (demand) => demand.application == applicationId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshDemands() async {
    await fetchMyDemands(refresh: true);
  }

  Future<void> loadMoreDemands() async {
    if (!_loading && _hasMore) {
      await fetchMyDemands();
    }
  }
  // Add these methods to InternshipDemandProvider class

  Future<bool> generateConvention(int demandId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.generateConvention(demandId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> generateLetter(int demandId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.generateLetter(demandId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  InternshipDemand? getDemandById(int id) {
    try {
      return _demands.firstWhere((demand) => demand.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
