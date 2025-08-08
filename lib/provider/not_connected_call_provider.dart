import 'package:call_management/api/api.dart';
import 'package:call_management/model/call_data_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotConnectedCallProvider with ChangeNotifier {
  final List<ConnectedCall> _calls = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 15;

  String? _filterStatus;
  String _pendingFilter = 'All';
  DateTime? _fromDate;
  DateTime? _toDate;

  List<ConnectedCall> get filteredCalls {
    if (_filterStatus == null || _filterStatus == 'All') return _calls;

    return _calls.where((call) {
      final actionType = call.feedComments?.actionType?.toLowerCase();
      return actionType == _filterStatus!.toLowerCase();
    }).toList();
  }



  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  String get pendingFilter => _pendingFilter;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  // ======= Public Methods ========

  Future<void> fetchCalls({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) resetPagination();

    _isLoading = true;

    final String start = DateFormat('yyyy-MM-dd')
        .format(_fromDate ?? DateTime.now());
    final String end =
    DateFormat('yyyy-MM-dd').format(_toDate ?? DateTime.now());

    final String statusParam = (_filterStatus != null && _filterStatus != 'All')
        ? '&callStatus=$_filterStatus'
        : '';

    final String endpoint =
        "getNotConnectedCalls?startTime=$start&endTime=$end&offset=$_offset&limit=$_limit$statusParam";

    try {
      final response = await Api().post(endpoint, {});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<ConnectedCall> records =
        data.map((e) => ConnectedCall.fromJson(e)).toList();

        if (records.length < _limit) _hasMore = false;

        _calls.addAll(records);
        _offset += _limit;
      }
    } catch (e) {
      debugPrint('Error fetching connected calls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterStatus(String? status) {
    _filterStatus = status;
    fetchCalls();
  }

  void setPendingFilter(String status) {
    _pendingFilter = status;
    notifyListeners(); // UI may need immediate update
  }

  void applyActionType(String selected){
    _pendingFilter = selected;
    _filterStatus = selected;
    notifyListeners();
  }

  void applyFilter() {
    _filterStatus = _pendingFilter;
    fetchCalls();
  }

  void resetFilter() {
    _pendingFilter = 'All';
    _filterStatus = null;
    _fromDate = null;
    _toDate = null;
    fetchCalls();
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    fetchCalls();
  }

  void loadMore() {
    if (_hasMore && !_isLoading) {
      fetchCalls(loadMore: true);
    }
  }

  void refresh() {
    fetchCalls();
  }

  void resetPagination() {
    _calls.clear();
    _offset = 0;
    _hasMore = true;
  }

  void removeRecordById(int id) {
    _calls.removeWhere((record) => record.id == id);
    notifyListeners();
  }
}
