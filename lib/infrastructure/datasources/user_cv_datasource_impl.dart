import 'dart:io';

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/domain/repositories/user_cv_repository.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class UserCvDataSourceImpl extends UserCvRepository {
  late Future<Isar> db;

  UserCvDataSourceImpl() {
    db = openIsar();
  }

  Future<Isar> openIsar() async {
    final Directory tempDir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [UserCvSchema, ExperienceSchema, StudySchema, SkillSchema],
        directory: tempDir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  @override
  Future<UserCv?> getUserCv(Id id) async {
    final isar = await db;
    return await isar.userCvs.filter().idEqualTo(id).findFirst();
  }
  
  @override
  Future<void> saveUserCv(UserCv userCv) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.userCvs.put(userCv);
      await userCv.experiences.save();
      await userCv.studies.save();
      await userCv.skills.save();
    });
  }
  
  @override
  Stream<List<UserCv>> getAllCvs() async*{
    final isar = await db;
    yield*  isar.userCvs.where().watch(fireImmediately: true);

  }
}
