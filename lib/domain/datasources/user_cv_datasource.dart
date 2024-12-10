

import 'package:cvgenius/domain/entities/user.dart';
import 'package:isar/isar.dart';

abstract class UserCvDataSource {
  Future<UserCv> getUserCv(Id id);
  Stream<List<UserCv?>> getAllCvs();
  Future<void> saveUserCv(UserCv userCv);
  Future <void> deleteCv(Id id);
  Future <void> decrementSlot(Id id);
  Future <void> incrementSlot(Id id);
}