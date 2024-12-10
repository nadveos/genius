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
          )
          // ),
          // Builder(
          //   builder: (context) {
          //     return userCvAsyncValue.when(
          //       data: (data) {
          //         if (data.isNotEmpty) {
          //           return IconButton(
          //             icon: const Icon(Icons.add),
          //             onPressed: () {
          //               context.push('/create-cv');
          //             },
          //           );
          //         } else {
          //           return const SizedBox.shrink();
          //         }
          //       },
          //       loading: () => const SizedBox.shrink(),
          //       error: (error, stack) => const SizedBox.shrink(),
          //     );
          //   },
          // ),
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
                const Text(
                    'Mira 5 anuncios para desbloquear la creación de otro CV'),
                ElevatedButton(
                  onPressed: () {
                    showDialog(context: context, builder: (context) => const AlertDialog(
                    
                    content: DecoratedBox(decoration: BoxDecoration(color: Colors.black54), child: Text('Ver anuncio'),),
                    ),);
                  },
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
