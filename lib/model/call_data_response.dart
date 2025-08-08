class ConnectedCallsResponse {
  final bool success;
  final List<ConnectedCall> data;

  ConnectedCallsResponse({
    required this.success,
    required this.data,
  });

  factory ConnectedCallsResponse.fromJson(Map<String, dynamic> json) {
    return ConnectedCallsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ConnectedCall.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ConnectedCall {
  final int id;
  final String userName;
  final String userPhone;
  final String consultantName;
  final String consultantPhone;
  final int callDuration;
  final String callStatus;
  final String feedCallStatus;
  final FeedComments? feedComments;
  final String feedCreatedAt; // 🆕 New field

  ConnectedCall({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.consultantName,
    required this.consultantPhone,
    required this.callDuration,
    required this.callStatus,
    required this.feedCallStatus,
    this.feedComments,
    required this.feedCreatedAt,
  });

  factory ConnectedCall.fromJson(Map<String, dynamic> json) {
    return ConnectedCall(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      consultantName: json['consultant_name'] ?? '',
      consultantPhone: json['consultant_phone'] ?? '',
      callDuration: json['call_duration'] ?? 0,
      callStatus: json['call_status'] ?? '',
      feedCallStatus: json['feed_call_status'] ?? '',
      feedComments: json['feed_comments'] != null
          ? FeedComments.fromJson(json['feed_comments'])
          : null,
      feedCreatedAt: json['feed_created_at'] ?? '', // 🆕 Handle new field
    );
  }
}

class FeedComments {
  final String profileType;
  final String commentText;
  final String createdAt;
  final String updatedAt;
  final String actionType;

  FeedComments({
    required this.profileType,
    required this.commentText,
    required this.createdAt,
    required this.updatedAt,
    required this.actionType,
  });

  factory FeedComments.fromJson(Map<String, dynamic> json) {
    return FeedComments(
      profileType: json['profile_type'] ?? '',
      commentText: json['comment_text'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      actionType: json['action_type'] ?? '',
    );
  }
}
