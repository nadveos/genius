import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:cvgenius/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {

  const HomeScreen({super.key, });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCvAsyncValue = ref.watch(isarRealUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis CVs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/create-cv');
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.push('/create-cv');
      //   },
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: userCvAsyncValue.when(
        data: (cvList) {
          if (cvList.isEmpty) {
            return const CreateCvScreen();
          } else {
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
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.push('/cv-data/${cvList[index].id}');
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          // Lógica para eliminar el CV
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
