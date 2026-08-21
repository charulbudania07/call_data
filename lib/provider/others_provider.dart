import 'package:call_management/api/api.dart';
import 'package:call_management/model/other_model_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OthersProvider with ChangeNotifier {
  List<OtherCall> _otherCalls = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 15;
  bool _hasMore = true;

  DateTime? _fromDate;
  DateTime? _toDate;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  List<OtherCall> get otherCalls => _otherCalls;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  Future<void> fetchOtherCalls({bool loadMore = false}) async {
    if (_isLoading) return;
    if (!_hasMore && loadMore) return;

    if (!loadMore) resetPagination();

    _isLoading = true;
    notifyListeners();


    final String start = DateFormat('yyyy-MM-dd')
        .format(_fromDate ?? DateTime.now().subtract(const Duration(days: 30)));
    final String end =
    DateFormat('yyyy-MM-dd').format(_toDate ?? DateTime.now());

    final String endpoint =
        "getOtherCalls?startTime=$start&endTime=$end&offset=$_offset&limit=$_limit";

    try {
      final response = await Api().post(endpoint, {});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<OtherCall> records =
        data.map((e) => OtherCall.fromJson(e)).toList();

        if (records.length < _limit) _hasMore = false;

        _otherCalls.addAll(records);
        _offset += _limit;
      }
    } catch (e) {
      debugPrint('Error fetching other calls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeRecordById(int id) {
    _otherCalls.removeWhere((record) => record.id == id);
    notifyListeners();
  }


  Future<void> loadMore() async {
    if (!_isLoading && _hasMore) {
      await fetchOtherCalls(loadMore: true);
    }
  }

  Future<void> refresh() async {
    resetPagination();
    await fetchOtherCalls();
  }

  void resetPagination() {
    _otherCalls.clear();
    _offset = 0;
    _hasMore = true;
  }

  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    resetPagination();
    fetchOtherCalls();
  }

  void resetFilter() {
    _fromDate = null;
    _toDate = null;
    resetPagination();
    fetchOtherCalls();
  }
}