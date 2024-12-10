import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class UserCv {
  Id id = Isar.autoIncrement;
  final String name;
  final String age;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String country;
  final String nationality;
  String? coverLetter;
  int totalAdsWatched = 0; // Anuncios totales vistos.
  int slotsUnlocked = 1; // Slots desbloqueados actualmente.
  final IsarLinks<Availability> availabilities = IsarLinks<Availability>();
  final IsarLinks<Experience> experiences = IsarLinks<Experience>();
  final IsarLinks<Study> studies = IsarLinks<Study>();
  final IsarLinks<Skill> skills = IsarLinks<Skill>();
  final IsarLinks<HighStudy> highStudies = IsarLinks<HighStudy>();

  UserCv(
      {required this.name,
      required this.email,
      required this.phoneNumber,
      required this.address,
      required this.age,
      required this.nationality,
      required this.city,
      required this.state,
      required this.country,
      this.coverLetter,
      this.totalAdsWatched = 0,
      this.slotsUnlocked = 1});
}

@collection
class Availability {
  Id id = Isar.autoIncrement;
  late String title;
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
class HighStudy {
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
