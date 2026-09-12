class UserModel {
  final String id;
  final String fullName;
  final String name;
  final String churchID;
  final String chapterID;
  final String season;
  final String church;
  final String email;
  final String gender;
  final String phoneNumber;
  final String role;
  final dynamic birthday; // نفس المنطق القديم: ممكن يكون Timestamp أو String

  const UserModel({
    required this.id,
    required this.fullName,
    required this.name,
    required this.churchID,
    required this.chapterID,
    required this.season,
    required this.church,
    required this.email,
    required this.gender,
    required this.phoneNumber,
    required this.role,
    this.birthday,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      fullName: data['full_name'] as String? ?? '',
      name: data['name'] as String? ?? '',
      churchID: data['ChurchID'] as String? ?? '',
      chapterID: data['ChapterID'] as String? ?? '',
      season: data['Season'] as String? ?? '',
      church: data['Church'] as String? ?? '',
      email: data['email'] as String? ?? '',
      gender: data['Gender'] as String? ?? '',
      phoneNumber: data['Phone_Namber'] as String? ?? '',
      role: data['role'] as String? ?? 'User',
      birthday: data['Birthday'],
    );
  }
}