class InstallAppModel {
  final bool success;
  final List<InstallApp> data;

  InstallAppModel({
    required this.success,
    required this.data,
  });

  factory InstallAppModel.fromJson(Map<String, dynamic> json) {
    return InstallAppModel(
      success: json['success'] ?? false,
      data: (json['data'] as List)
          .map((e) => InstallApp.fromJson(e))
          .toList(),
    );
  }
}

class InstallApp {
  final int id;
  final String userName;
  final String contactNo;
  final String contactPerson;
  final String address;
  final String createdAt;
  final String? outgoing;
  final String? incomming;

  InstallApp({
    required this.id,
    required this.userName,
    required this.contactNo,
    required this.contactPerson,
    required this.address,
    required this.createdAt,
    this.outgoing,
    this.incomming,
  });

  factory InstallApp.fromJson(Map<String, dynamic> json) {
    return InstallApp(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      contactNo: json['contact_no'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['created_at'] ?? '',
      outgoing: json['outgoing'],
      incomming: json['incomming'],
    );
  }
}
