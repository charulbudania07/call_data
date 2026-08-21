class OtherCallResponse {
  final bool success;
  final List<OtherCall> data;

  OtherCallResponse({
    required this.success,
    required this.data,
  });

  factory OtherCallResponse.fromJson(Map<String, dynamic> json) {
    return OtherCallResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => OtherCall.fromJson(e))
          .toList(),
    );
  }
}

class OtherCall {
  final int id;
  final String userName;
  final String userPhone;
  final String consultantName;
  final String consultantPhone;
  final int callDuration;
  final String callStatus;
  final String callDate;

  OtherCall({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.consultantName,
    required this.consultantPhone,
    required this.callDuration,
    required this.callStatus,
    required this.callDate,
  });

  factory OtherCall.fromJson(Map<String, dynamic> json) {
    return OtherCall(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userName: (json['user_name'] ?? '').toString().trim(),
      userPhone: (json['user_phone'] ?? '').toString().trim(),
      consultantName: (json['consultant_name'] ?? '').toString().trim(),
      consultantPhone: (json['consultant_phone'] ?? '').toString().trim(),
      callDuration: json['call_duration'] is int
          ? json['call_duration']
          : int.tryParse(json['call_duration']?.toString() ?? '') ?? 0,
      callStatus: (json['call_status'] ?? '').toString().trim(),
      callDate: (json['call_date'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_phone': userPhone,
      'consultant_name': consultantName,
      'consultant_phone': consultantPhone,
      'call_duration': callDuration,
      'call_status': callStatus,
      'call_date': callDate,
    };
  }

  /// Parsed DateTime for the call, null if parsing fails
  DateTime? get callDateTime {
    try {
      return DateTime.parse(callDate);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() {
    return 'OtherCall(id: $id, userName: $userName, userPhone: $userPhone, callDate: $callDate)';
  }
}