class CallRecord {
  final int id;
  final String userName;
  final String userPhone;
  final String consultantName;
  final String consultantPhone;
  final int callDuration;
  final String callStatus;

  CallRecord({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.consultantName,
    required this.consultantPhone,
    required this.callDuration,
    required this.callStatus,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      id: json['id'],
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'] ?? '',
      consultantName: json['consultant_name'] ?? '',
      consultantPhone: json['consultant_phone'] ?? '',
      callDuration: json['call_duration'] ?? 0,
      callStatus: json['call_status'] ?? '',
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
    };
  }
}
