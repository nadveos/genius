// ignore_for_file: avoid_print

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:cvgenius/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userCvAsyncValue = ref.watch(isarRealUserProvider);

    void changeTheme() {
      ref.read(themeProvider.notifier).toggleTheme();
    }

    // Función para manejar la visualización de anuncios y aumentar los slots
    Future<void> mostrarAnuncio(
      UserCv userCv,
      WidgetRef ref,
    ) async {
      try {
        // Simulación de la espera del anuncio
        await Future.delayed(const Duration(seconds: 3));

        // Validar si el usuario existe
        final userCv = ref.read(isarRealUserProvider).value?.first;
        if (userCv == null) {
          throw Exception('No se encontró un UserCv válido');
        }

        // Incrementar slots desbloqueados y anuncios vistos en una única transacción
        final userCvRepository = ref.read(isarUserProvider);
        final isar = await userCvRepository.db;

        await isar.writeTxn(() async {
          // Incrementar slots luego de mirar el anuncio
          
        });

        print('Anuncio mostrado y datos actualizados exitosamente');
      } catch (e) {
        print('Error al mostrar anuncio: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // title: userCvAsyncValue.when(
        //     data: (data) {
        //       if (data.isNotEmpty) {
        //         return Text(AppLocalizations.of(context)!.misCvs);
        //       } else {
        //         return Text(AppLocalizations.of(context)!.genius);
        //       }
        //     },
        //     loading: () => Text(AppLocalizations.of(context)!.genius),
        //     error: (error, stack) =>
        //         Text(AppLocalizations.of(context)!.genius)),
        actions: [
          IconButton(
            onPressed: changeTheme,
            // ignore: unrelated_type_equality_checks
            icon: ref.watch(themeProvider)
                ? const Icon(
                    Icons.dark_mode,
                    color: Colors.blue,
                  )
                : const Icon(
                    Icons.light_mode,
                    color: Colors.blue,
                  ),
          ),
        ],
      ),
      body: userCvAsyncValue.when(
        data: (cvList) {
          if (cvList.isEmpty) {
            return const WelcomeScreen();
          } else {
            return Column(
              children: [
                Expanded(child: _mycvs(cvList)),
                // Mostrar los slots disponibles dinámicamente y manejar la navegación
                

// Mostrar texto sobre anuncios
                const Text(
                  'Mira 1 anuncio para desbloquear la creación de otro CV',
                ),

// Botón para mostrar anuncio
                ElevatedButton(
                  onPressed: cvList.isNotEmpty
                      ? () async {
                          final userCv = cvList.first;
                          await mostrarAnuncio(userCv, ref);
                        }
                      : null, // Desactiva el botón si no hay usuarios en la lista
                  child: const Text('Ver anuncio'),
                ),

                DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey[300]),
                  child: const SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: Center(
                      child: Text('Anuncio'),
                    ),
                  ),
                ),
              ],
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  ListView _mycvs(List<UserCv> cvList) {
    return ListView.builder(
      itemCount: cvList.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(cvList[index].name.toUpperCase()),
          subtitle: Text(cvList[index].email),
          leading: CircleAvatar(
            child: Text(cvList[index].name[0].toUpperCase()),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.remove_red_eye,
              color: Colors.green,
            ),
            onPressed: () {
              context.push('/cv-data/${cvList[index].id}');
            },
          ),
        );
      },
    );
  }
}
