// models/user_model.dart
class User {
  final int id;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final String type;
  final String userGroup;
  final String token;

  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.username,
    required this.email,
    required this.type,
    required this.userGroup,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      username: json['username'],
      email: json['email'],
      type: json['type'],
      userGroup: json['user_group'],
      token: json['api_token'],
    );
  }
}
