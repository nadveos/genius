// ignore_for_file: avoid_print

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/infrastructure/datasources/user_cv_datasource_impl.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final userCvProvider =
    StateNotifierProvider.family<UserCvNotifier, UserCv, Id>(
  (ref, userId) => UserCvNotifier(
    ref.watch(isarUserProvider), // Pasamos el datasource al notifier
    userId,                      // Pasamos el ID del usuario
  ),
);


class UserCvNotifier extends StateNotifier<UserCv> {
  UserCvNotifier(this._dataSource, this._userId)
      : super(
          UserCv(
            name: '',
            email: '',
            phoneNumber: '',
            address: '',
            age: '',
            nationality: '',
            city: '',
            state: '',
            country: '',
            slotsUnlocked: 1,
            totalAdsWatched: 0,
          ),
        );

  final UserCvDataSourceImpl _dataSource;
  final Id _userId;

  

  Future<void> decrementSlot() async {
    try {
      // Llama a la implementación existente en el datasource
      await _dataSource.decrementSlot(_userId);

      // Obtén el estado actualizado desde la base de datos
      final updatedUserCv = await _dataSource.getUserCv(_userId);

      // Notifica el nuevo estado
      state = updatedUserCv;
    } catch (e) {
      // Manejo de errores si ocurre algún problema
      print('Error decrementando slot: $e');
      throw Exception("Failed to decrement slot");
    }
  }

  Future<void> incrementSlot() async {
    try {
      // Llama a la implementación existente en el datasource
      await _dataSource.incrementSlot(_userId);

      // Obtén el estado actualizado desde la base de datos
      final updatedUserCv = await _dataSource.getUserCv(_userId);

      // Notifica el nuevo estado
      state = updatedUserCv;
    } catch (e) {
      // Manejo de errores si ocurre algún problema
      print('Error incrementando slot: $e');
      throw Exception("Failed to increment slot");
    }
  }

}
