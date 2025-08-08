import 'package:call_management/api/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _commentMap = {};

  void addCommentLocally(String name, Map<String, dynamic> commentData) {
    if (!_commentMap.containsKey(name)) {
      _commentMap[name] = [];
    }
    _commentMap[name]!.add(commentData);
    notifyListeners();
  }

  List<Map<String, dynamic>> getCommentsFor(String name) {
    return _commentMap[name] ?? [];
  }

  int getCommentCount(String name) => _commentMap[name]?.length ?? 0;

  Future<bool> submitCommentToServer({
    required int id,
    required String actionType,
    required String callStatus,
    required String? profileType,
    required String comment,
    required bool isFollowUp,
    String? recordingPath,
  }) async {

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id');
      String? name = prefs.getString('name');
      String endpoint = "comment?id=$id&actionType=$actionType&user_id=$userId&user_name=$name&callStatus=${callStatus}&profileType=${profileType?.toLowerCase() ??""}&comment=$comment&isFollowUp=$isFollowUp";
      final response = await Api().post(endpoint,{});
      if (response.statusCode == 200) {
        print("Comment submitted successfully");
        return true;
      } else {
        print("Failed to submit comment: ${response.statusMessage}");
        return false;
      }
    } catch (e) {
      print("Error submitting comment: $e");
      return false;
    }
  }

}
