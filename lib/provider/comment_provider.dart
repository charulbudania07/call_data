import 'package:call_management/api/api.dart';
import 'package:flutter/material.dart';

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
    final Map<String, dynamic> params = {
      "id": id,
      "actionType": actionType,
      "callStatus": callStatus.toLowerCase(),
      "profileType": profileType?.toLowerCase() ?? "",
      "comment": comment,
      "isFolloUp": isFollowUp,
    };

    try {

      String endpoint = "comment?id=$id&actionType=$actionType&callStatus=${callStatus.toLowerCase()}&profileType=${profileType?.toLowerCase() ??""}&comment=$comment&isFolloUp= $isFollowUp";
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
