// ignore_for_file: avoid_print

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:cvgenius/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        title: userCvAsyncValue.when(
          data: (data) {
            if (data.isNotEmpty) {
              return Text(AppLocalizations.of(context)!.misCvs);
            } else {
              return  Text(AppLocalizations.of(context)!.genius);
            }
          },
          loading: () =>  Text(AppLocalizations.of(context)!.genius),
          error: (error, stack) =>  Text(AppLocalizations.of(context)!.genius)
        ),
        actions: [
          IconButton(
            onPressed: changeTheme,
            // ignore: unrelated_type_equality_checks
            icon: ref.watch(themeProvider)
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
          ),
          Builder(
            builder: (context) {
              return userCvAsyncValue.when(
                data: (data) {
                  if (data.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        context.push('/create-cv');
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: userCvAsyncValue.when(
        data: (cvList) {
          if (cvList.isEmpty) {
            return const WelcomeScreen();
          } else {
            return _mycvs(cvList);
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.green,),
                onPressed: () {
                  context.push('/cv-data/${cvList[index].id}');
                },
              ),
              IconButton(
                onPressed: () {
                  ref.read(isarUserProvider).deleteCv(cvList[index].id);
                },
                icon: const Icon(Icons.delete, color: Colors.red,),
              ),
            ],
          ),
        );
      },
    );
  }
}
