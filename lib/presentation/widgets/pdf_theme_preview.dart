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

class ThemePreview extends ConsumerStatefulWidget {
  const ThemePreview({super.key});

  @override
  ConsumerState<ThemePreview> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends ConsumerState<ThemePreview> {
  late Future<List<String>> _svgFilesFuture;

  @override
  void initState() {
    super.initState();
    _svgFilesFuture = loadSvgAssets(); // Cacheamos los SVG
  }

  @override
  Widget build(BuildContext context) {
    final selectedTheme = ref.watch(selectedThemeProvider);
    final controller = ScrollController();

    // Define una lista de colores para diferentes temas
    final themeColors = [
      const Color.fromRGBO(205, 241, 231, 1),
      const Color.fromRGBO(255, 223, 186,1),
      const Color.fromRGBO(186, 225, 255,1),
     
    ];

    // Asegúrate de que el índice de `selectedTheme` no exceda la longitud de `themeColors`
    final selectedColor = themeColors[selectedTheme % themeColors.length];

    return FutureBuilder<List<String>>(
      future: _svgFilesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los archivos SVG'));
        }

        final svgFiles = snapshot.data ?? [];

        return Column(
          children: [
            // Vista previa del tema seleccionado
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selectedColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedColor, width: 2),
              ),
              child: Center(
                child: Text(
                  'Vista previa de tema',
                  style: TextStyle(
                    color: selectedColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            // Lista horizontal de temas
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.horizontal,
                itemCount: svgFiles.length,
                itemBuilder: (context, index) {
                  final svgFile = svgFiles[index];
                  final isSelected = selectedTheme == index;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(selectedThemeProvider.notifier)
                          .selectTheme(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withOpacity(0.25)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? selectedColor : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          svgFile,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
