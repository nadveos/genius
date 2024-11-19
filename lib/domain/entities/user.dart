import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class UserCv {
  Id id = Isar.autoIncrement;
  final String name;
  final String age;
  final String email;
  final String phoneNumber;
  final String address;
  final String photoUrl ;
  final String nationality;
  final IsarLinks<Experience> experiences = IsarLinks<Experience>();
  final IsarLinks<Study> studies = IsarLinks<Study>();
  final IsarLinks<Skill> skills = IsarLinks<Skill>();

  UserCv({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.age,
    required this.photoUrl,
    required this.nationality
  });
}

@collection
class Experience {
  Id id = Isar.autoIncrement;
  late String companyName;
  late String position;
  late String startDate;
  late String endDate;
  late String description;
}

@collection
class Study {
  Id id = Isar.autoIncrement;
  late String institutionName;
  late String degree;
  late String startDate;
  late String endDate;
  late bool isGraduated;
}

@collection
class Skill {
  Id id = Isar.autoIncrement;
  late String name;
  late String level;
}

