import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/domain/repositories/user_cv_repository.dart';
import 'package:cvgenius/infrastructure/datasources/user_cv_datasource_impl.dart';
import 'package:isar/isar.dart';

class UserCvRepositoryImpl extends UserCvRepository {
  final UserCvDataSourceImpl datasource;

  UserCvRepositoryImpl({required this.datasource});
  @override
  Future<UserCv> getUserCv(Id id) {
    return datasource.getUserCv(id);
  }

  @override
  Future<void> saveUserCv(UserCv userCv) {
    return datasource.saveUserCv(userCv);
  }
  
  @override
  Stream<List<UserCv?>> getAllCvs() {
    return datasource.getAllCvs();
  }
}
