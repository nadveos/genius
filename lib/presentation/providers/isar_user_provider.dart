
import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isarUserProvider = Provider<UserCvDataSourceImpl>((ref) {
  return UserCvDataSourceImpl();
});
 final isarRealUserProvider = StreamProvider<List<UserCv>>((ref) {
  final isarUserService = ref.read(isarUserProvider);
  return isarUserService.getAllCvs();
});
final selectedThemeProvider = StateProvider<int>((ref) => 0);
