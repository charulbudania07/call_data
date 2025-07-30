import 'package:call_management/api/api.dart';
import 'package:call_management/model/call_Record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeProvider with ChangeNotifier {
  final Map<String, List<CallRecord>> _recordsByTab = {
    'Cancelled': [],
    'Answered': [],
    'Verification': [],
  };

  final Map<String, DateTime?> _fromDates = {};
  final Map<String, DateTime?> _toDates = {};

  final Map<String, int> _offsets = {
    'Cancelled': 1,
    'Answered': 1,
    'Verification': 1,
  };

  final Map<String, bool> _hasMoreData = {
    'Cancelled': true,
    'Answered': true,
    'Verification': true,
  };

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? getFromDate(String tab) => _fromDates[tab];
  DateTime? getToDate(String tab) => _toDates[tab];

  List<CallRecord> getByTab(String tab) => _recordsByTab[tab] ?? [];

  Future<void> loadMore(String tab) async {
    if (!_hasMoreData[tab]!) return;
    final offset = _offsets[tab]!;
    await fetchDataForTab(tab, offset: offset, limit: 15);
  }

  Future<void> fetchDataForTab(
      String tab, {
        DateTime? from,
        DateTime? to,
        bool applyFilter = false,
        int offset = 1,
        int limit = 15,
      }) async {
    _isLoading = true;
    notifyListeners();

    if (applyFilter && from != null && to != null) {
      _fromDates[tab] = from;
      _toDates[tab] = to;
    }

    final String start = DateFormat('yyyy-MM-dd').format(
        _fromDates[tab] ?? DateTime.now());
    final String end = DateFormat('yyyy-MM-dd').format(
        _toDates[tab] ?? DateTime.now());

    String apiName = _getApiForTab(tab);
    String endpoint = "$apiName?startTime=$start&endTime=$end&offset=$offset&limit=$limit";

    try {
      final response = await Api().post(endpoint, {});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<CallRecord> records = data.map((e) => CallRecord.fromJson(e)).toList();

        if (offset == 1) {
          _recordsByTab[tab] = records;
        } else {
          _recordsByTab[tab]!.addAll(records);
        }
        if (records.length < limit) {
          _hasMoreData[tab] = false;
        } else {
          _hasMoreData[tab] = true;
          _offsets[tab] = offset + limit;
        }
      }else {
        if (offset == 1) _recordsByTab[tab] = [];
        _hasMoreData[tab] = false; // If failure, no more data
      }
    } catch (e) {
      if (offset == 1) _recordsByTab[tab] = [];
      debugPrint('Error fetching $tab: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Helper to map tab to API
  String _getApiForTab(String tab) {
    switch (tab) {
      case 'Answered':
        return 'getAnswerCalls';
      case 'Cancelled':
        return 'getCancelCalls';
      case 'Verification':
        return 'getVerifications';
      default:
        return 'getAnswerCalls';
    }
  }

  void updateFilterDates(DateTime from, DateTime to, String tab) {
    _fromDates[tab] = from;
    _toDates[tab] = to;
    fetchDataForTab(tab, from: from, to: to, applyFilter: true); // ✅ Save as filter
  }

  void resetFilter(String tab) {
    _fromDates.remove(tab);
    _toDates.remove(tab);
    fetchDataForTab(tab);
  }

  void removeRecordById(String tab, int id) {
    _recordsByTab[tab]?.removeWhere((record) => record.id == id);
    notifyListeners();
  }

}