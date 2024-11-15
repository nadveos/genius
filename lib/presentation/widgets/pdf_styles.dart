import 'dart:convert';

import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importa flutter_svg para mostrar SVGs

// Método para cargar los archivos SVG desde assets
Future<List<String>> loadSvgAssets() async {
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifest = json.decode(manifestJson);

  // Filtramos los archivos SVG en la carpeta assets/svg
  return manifest.keys
      .where((key) => key.startsWith('assets/svg/') && key.endsWith('.svg'))
      .toList();
}

class ThemePreview extends ConsumerWidget {
  const ThemePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);

    return FutureBuilder<List<String>>(
      future: loadSvgAssets(), // Cargar los archivos SVG
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los archivos SVG'));
        }

        final svgFiles = snapshot.data ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: svgFiles.length,
          itemBuilder: (context, index) {
            final svgFile = svgFiles[index];
            return GestureDetector(
              onTap: () {
                ref.read(selectedThemeProvider.notifier).state = index;
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedTheme == index ? Colors.black.withOpacity(0.25) : Colors.white,
                  border: Border.all(
                    color: selectedTheme == index ? Colors.blue : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    svgFile,  // Aquí cargamos el archivo SVG
                    width: 100,  // Ajusta el tamaño según sea necesario
                    height: 100, // Ajusta el tamaño según sea necesario
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
