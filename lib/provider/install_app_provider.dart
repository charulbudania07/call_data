import 'package:call_management/api/api.dart';
import 'package:call_management/model/install_app_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InstallAppProvider with ChangeNotifier {
  List<InstallApp> _installApps = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 15;
  bool _hasMore = true;


  DateTime? _fromDate;
  DateTime? _toDate;
  bool get isLoading => _isLoading;
  List<InstallApp> get installApps => _installApps;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  set fromDate(DateTime? value) {
    _fromDate = value;
    notifyListeners();
  }

  set toDate(DateTime? value) {
    _toDate = value;
    notifyListeners();
  }

  bool get hasMore => _hasMore;
  Future<void> fetchInstallApp({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) resetPagination();

    _isLoading = true;

    final String start = DateFormat('yyyy-MM-dd')
        .format(_fromDate ?? DateTime.now());
    final String end =
    DateFormat('yyyy-MM-dd').format(_toDate ?? DateTime.now());


    final String endpoint =
        "getInstalledApp?startTime=$start&endTime=$end&offset=$_offset&limit=$_limit";

    try {
      final response = await Api().post(endpoint, {});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];

        final List<InstallApp> records =
        data.map((e) => InstallApp.fromJson(e)).toList();

        if (records.length < _limit) _hasMore = false;

        _installApps.addAll(records);
      }
    } catch (e) {
      debugPrint('Error fetching connected calls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void resetPagination() {
    _installApps.clear();
    _offset = 0;
    _hasMore = true;
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    resetPagination();
    fetchInstallApp();
  }

  void resetFilter() {
    _fromDate = null;
    _toDate = null;
    resetPagination();
    fetchInstallApp();
  }
}
