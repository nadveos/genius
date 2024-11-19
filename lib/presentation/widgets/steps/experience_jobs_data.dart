import 'package:cvgenius/domain/domain.dart';
import 'package:cvgenius/presentation/providers/user_cv_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExperienceJobsData extends ConsumerStatefulWidget {
  const ExperienceJobsData({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExperienceData1State();
}

class _ExperienceData1State extends ConsumerState<ExperienceJobsData> {
  final List<Map<String, TextEditingController>> _controllersList = [];

  @override
  void initState() {
    super.initState();
    _addNewExperience(); // Añadir el primer formulario de experiencia
  }

  @override
  void dispose() {
    for (var controllers in _controllersList) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addNewExperience() {
    setState(() {
      _controllersList.add({
        "empresa": TextEditingController(),
        "posicion": TextEditingController(),
        "desde": TextEditingController(),
        "hasta": TextEditingController(),
        "descripcion": TextEditingController(),
      });
    });
  }

  void _saveData() {
    for (var controllers in _controllersList) {
      if (controllers.values.any((controller) => controller.text.isEmpty)) {
        // Muestra un error si algún campo está vacío
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, completa todos los campos')),
        );
        return;
      }

      // Guarda cada experiencia en el provider
      ref.read(userCvProvider.notifier).addExperience(
            Experience()
              ..companyName = controllers["empresa"]!.text
              ..position = controllers["posicion"]!.text
              ..startDate = controllers["desde"]!.text
              ..endDate = controllers["hasta"]!.text
              ..description = controllers["descripcion"]!.text,
          );
    }

    // Limpia la lista de controladores después de guardar
    setState(() {
      _controllersList.clear();
      _addNewExperience();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Experiencias guardadas exitosamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiencias laborales'),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _controllersList.length,
                  itemBuilder: (context, index) {
                    final controllers = _controllersList[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: controllers["empresa"],
                              decoration: const InputDecoration(labelText: 'Empresa'),
                            ),
                            TextFormField(
                              controller: controllers["posicion"],
                              decoration: const InputDecoration(
                                labelText: 'Posición',
                                hintText: 'Ej. Secretaria, Gerente, etc.',
                              ),
                            ),
                            TextFormField(
                              controller: controllers["desde"],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Desde (año)',
                                hintText: 'Ej. 2010',
                              ),
                            ),
                            TextFormField(
                              controller: controllers["hasta"],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Hasta (año)',
                                hintText: 'Ej. 2015',
                              ),
                            ),
                            TextFormField(
                              controller: controllers["descripcion"],
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                                hintText: 'Ej. Responsabilidades, logros, etc.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addNewExperience,
                child: const Text('Agregar otra experiencia'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Guardar todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
