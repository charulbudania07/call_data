import 'package:call_management/model/connected_call_model.dart';
import 'package:flutter/material.dart';

class ConnectedCallProvider with ChangeNotifier {
  List<CallEntry> _calls = [
    CallEntry(name: 'Michael Brown', number: '9876543210', comment: 'Phone was busy', type: 'Cancelled'),
    CallEntry(name: 'Sarah Williams', number: '1234567890', comment: 'Satisfied', type: 'Answered'),
    CallEntry(name: 'Emma Johnson', number: '5551234567', comment: 'Verification done', type: 'Verified'),
    CallEntry(name: 'David Lee', number: '8888888888', comment: 'Call completed successfully', type: 'Answered'),
    CallEntry(name: 'Sophia Miller', number: '4445556666', comment: 'Did not respond', type: 'Cancelled'),
    CallEntry(name: 'James Smith', number: '3332221111', comment: 'ID verified and logged', type: 'Verified'),
    CallEntry(name: 'Olivia Davis', number: '9873214560', comment: 'Happy with response', type: 'Answered'),
    CallEntry(name: 'Liam Wilson', number: '1237894560', comment: 'Declined the offer', type: 'Cancelled'),
    CallEntry(name: 'Emma Garcia', number: '4567891230', comment: 'All documents received', type: 'Verified'),
    CallEntry(name: 'Noah Martinez', number: '9876543012', comment: 'Call ended with confirmation', type: 'Answered'),
    CallEntry(name: 'Ava Robinson', number: '6789054321', comment: 'Not interested', type: 'Cancelled'),
    CallEntry(name: 'Lucas Clark', number: '2223334444', comment: 'Requested callback tomorrow', type: 'Answered'),
    CallEntry(name: 'Mia Rodriguez', number: '5556667777', comment: 'Verified with documents', type: 'Verified'),
    CallEntry(name: 'Elijah Lewis', number: '7778889999', comment: 'Switched off', type: 'Cancelled'),
    CallEntry(name: 'Charlotte Walker', number: '8889990000', comment: 'Positive response', type: 'Answered'),
    CallEntry(name: 'William Hall', number: '1112223333', comment: 'Verification successful', type: 'Verified'),
    CallEntry(name: 'Amelia Allen', number: '4443332222', comment: 'Wrong number', type: 'Cancelled'),
    CallEntry(name: 'Benjamin Young', number: '9998887777', comment: 'Follow-up required', type: 'Answered'),
    CallEntry(name: 'Evelyn Hernandez', number: '6665554444', comment: 'Completed verification', type: 'Verified'),
    CallEntry(name: 'Henry King', number: '1010101010', comment: 'Disconnected abruptly', type: 'Cancelled'),
  ];

  String _selectedFilter = 'All';
  String _pendingFilter = 'All';

  List<CallEntry> get filteredCalls {
    if (_selectedFilter == 'All') return _calls;
    return _calls.where((call) => call.type == _selectedFilter).toList();
  }

  void setPendingFilter(String filter) {
    _pendingFilter = filter;
    notifyListeners();
  }

  void applyFilter() {
    _selectedFilter = _pendingFilter;
    notifyListeners();
  }

  void resetFilter() {
    _selectedFilter = 'All';
    _pendingFilter = 'All';
    notifyListeners();
  }

  String get currentFilter => _selectedFilter;
  String get pendingFilter => _pendingFilter;
}
