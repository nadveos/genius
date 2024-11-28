// ignore_for_file: avoid_print

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
        [
          UserCvSchema,
          ExperienceSchema,
          StudySchema,
          SkillSchema,
          HighStudySchema
        ],
        directory: tempDir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

 @override
Future<void> deleteCv(Id id) async {
  try {
    final isar = await db;
    final userCv = await isar.userCvs.get(id);
    if (userCv != null) {
      await isar.writeTxn(() async {
        // Manejo seguro para relaciones
        if ( userCv.skills.isLoaded) {
          for (final skill in userCv.skills) {
            await isar.skills.delete(skill.id);
          }
        }
        userCv.skills.clear();

        if ( userCv.studies.isLoaded) {
          for (final study in userCv.studies) {
            await isar.studys.delete(study.id);
          }
        }
        userCv.studies.clear();

        if ( userCv.experiences.isLoaded) {
          for (final experience in userCv.experiences) {
            await isar.experiences.delete(experience.id);
          }
        }
        userCv.experiences.clear();

        if ( userCv.highStudies.isLoaded) {
          for (final highStudy in userCv.highStudies) {
            await isar.highStudys.delete(highStudy.id);
          }
        }
        userCv.highStudies.clear();

        // Eliminar el UserCv
        await isar.userCvs.delete(id);
      });
    }
  } catch (e) {
    print('Error deleting CV with ID $id: $e');
    throw Exception('Failed to delete CV');
  }
}



  @override
  Future<UserCv> getUserCv(Id id) async {
    final isar = await db;
    final userCv = await isar.userCvs.filter().idEqualTo(id).findFirst();
    if (userCv == null) {
      throw Exception('UserCv not found');
    }
    return userCv;
  }

  @override
Future<void> saveUserCv(UserCv userCv) async {
  try {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.userCvs.put(userCv);
      await userCv.experiences.save();
      await userCv.studies.save();
      await userCv.skills.save();
      await userCv.highStudies.save();
    });
  } catch (e) {
    print('Error saving UserCv: $e');
    throw Exception('Failed to save UserCv');
  }
}


 @override
Stream<List<UserCv>> getAllCvs() async* {
  try {
    final isar = await db;
    yield* isar.userCvs.where().watch(fireImmediately: true);
  } catch (e) {
    print('Error fetching all CVs: $e');
    yield []; // Devuelve una lista vacía en caso de error
  }
}

}
