
import 'package:cvgenius/domain/entities/user.dart';
import 'package:isar/isar.dart';

abstract class UserCvRepository {
  Future<UserCv> getUserCv(Id id);
  Stream<List<UserCv?>> getAllCvs();
  Future<void> saveUserCv(UserCv userCv);
  Future <void> deleteCv(Id id);
}