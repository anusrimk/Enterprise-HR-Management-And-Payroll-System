import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic> _stats = {
    'totalEmployees': 0,
    'presentToday': 0,
    'onLeave': 0,
    'pendingLeaves': 0,
  };
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await DashboardService.getOverview();
      _stats = response;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load dashboard stats';
      _isLoading = false;
      notifyListeners();
    }
  }
}
