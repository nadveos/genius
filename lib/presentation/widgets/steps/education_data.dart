import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/user_cv_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EducationData extends ConsumerStatefulWidget {
  const EducationData({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EducationDataState();
}

class _EducationDataState extends ConsumerState<EducationData> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloSecundarioController;
  late final TextEditingController _tituloTerciarioController;
  late final TextEditingController _institutionController;
  late final TextEditingController _startStudyController;
  late final TextEditingController _endStudyController;
  final List<Map<String, dynamic>> _educacion = [];

  //others
  String _nivelSecundario = 'Secundario Completo';
  String _nivelTerciario = 'Terciario en Curso';
  bool _poseeTituloSecundario = false;
  bool _poseeTituloTerciario = false;
  final bool _secundarioGuardado = false;

  @override
  void initState() {
    super.initState();
    _institutionController = TextEditingController();
    _tituloSecundarioController = TextEditingController();
    _startStudyController = TextEditingController();
    _endStudyController = TextEditingController();
    _tituloTerciarioController = TextEditingController();
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _tituloSecundarioController.dispose();
    _startStudyController.dispose();
    _endStudyController.dispose();
    _tituloTerciarioController.dispose();
    super.dispose();
  }

  void _saveEducation() {
    if (_formKey.currentState!.validate()) {
      final studyData = Study()
        ..degree = _nivelSecundario
        ..institutionName = _institutionController.text
        ..isGraduated = _poseeTituloSecundario
        ..startDate = _startStudyController.text
        ..endDate = _endStudyController.text;
      // Guardar los datos del nivel secundario
      ref.read(userCvProvider.notifier).addStudy(studyData);
      
// ignore: avoid_print
      print(ref.read(userCvProvider).studies);

      // Si es "Secundario Completo" y posee título, verificar los estudios terciarios/universitarios
      if (_nivelSecundario == 'Secundario Completo' && _poseeTituloSecundario) {
        if (_tituloTerciarioController.text.isNotEmpty &&
            _institutionController.text.isNotEmpty) {
          ref.read(userCvProvider.notifier).addStudy(
                Study()
                  ..degree = _nivelTerciario
                  ..institutionName = _institutionController.text
                  ..isGraduated = _poseeTituloTerciario,
              );
        }
      }
      // Limpiar los campos y resetear el formulario
      _tituloSecundarioController.clear();
      _tituloTerciarioController.clear();
      _institutionController.clear();
      _startStudyController.clear();
      _endStudyController.clear();
      _poseeTituloSecundario = false;
      _poseeTituloTerciario = false;
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educación')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_secundarioGuardado)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _nivelSecundario,
                      decoration:
                          const InputDecoration(labelText: 'Nivel Secundario'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Secundario Completo',
                            child: Text('Secundario Completo')),
                        DropdownMenuItem(
                            value: 'Secundario En Curso',
                            child: Text('Secundario En Curso')),
                        DropdownMenuItem(
                            value: 'Secundario Incompleto',
                            child: Text('Secundario Incompleto')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _nivelSecundario = value!;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _institutionController,
                      decoration: const InputDecoration(
                          labelText: 'Colegio o Institución'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre de la institución';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _tituloSecundarioController,
                      decoration: const InputDecoration(
                          labelText: 'Título Obtenido/En Curso'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el título secundario';
                        }
                        return null;
                      },
                    ),
                    if (_nivelSecundario == 'Secundario Completo')
                      Column(
                        children: [
                          TextFormField(
                            controller: _startStudyController,
                            decoration:
                                const InputDecoration(labelText: 'Desde (año)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el año de inicio';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _endStudyController,
                            decoration:
                                const InputDecoration(labelText: 'Hasta (año)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el año de finalización';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              const Text('Posee título:'),
                              Radio<bool>(
                                value: true,
                                groupValue: _poseeTituloSecundario,
                                onChanged: (value) {
                                  setState(() {
                                    _poseeTituloSecundario = value!;
                                  });
                                },
                              ),
                              const Text('Sí'),
                              Radio<bool>(
                                value: false,
                                groupValue: _poseeTituloSecundario,
                                onChanged: (value) {
                                  setState(() {
                                    _poseeTituloSecundario = value!;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              for (var edu in _educacion)
                ExpansionTile(
                  title: Text(edu['institution'] ?? 'Sin institución'),
                  children: [
                    ListTile(
                      title:
                          Text('Nivel Secundario: ${edu['nivelSecundario']}'),
                    ),
                    if (edu['nivelTerciario'] != null)
                      ListTile(
                        title: Text(
                            'Nivel Terciario/Universitario: ${edu['nivelTerciario']}'),
                      ),
                    ListTile(
                      title: Text(
                          'Posee título: ${edu['poseeTituloSecundario'] ? 'Sí' : 'No'}'),
                    ),
                  ],
                ),
              Visibility(
                visible: _nivelSecundario == 'Secundario Completo',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _nivelTerciario,
                      decoration: const InputDecoration(
                          labelText: 'Nivel Terciario/Universitario'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Terciario en Curso',
                            child: Text('Terciario en Curso')),
                        DropdownMenuItem(
                            value: 'Terciario Completo',
                            child: Text('Terciario Completo')),
                        DropdownMenuItem(
                            value: 'Universitario en Curso',
                            child: Text('Universitario en Curso')),
                        DropdownMenuItem(
                            value: 'Universitario Completo',
                            child: Text('Universitario Completo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _nivelTerciario = value!;
                        });
                      },
                    ),
                    TextFormField(
                      controller: _tituloTerciarioController,
                      decoration: const InputDecoration(
                          labelText: 'Título Terciario/Universitario'),
                    ),
                    if (_nivelTerciario == 'Terciario Completo' ||
                        _nivelTerciario == 'Universitario Completo')
                      Row(
                        children: [
                          const Text('Posee título:'),
                          Radio<bool>(
                            value: true,
                            groupValue: _poseeTituloTerciario,
                            onChanged: (value) {
                              setState(() {
                                _poseeTituloTerciario = value!;
                              });
                            },
                          ),
                          const Text('Sí'),
                          Radio<bool>(
                            value: false,
                            groupValue: _poseeTituloTerciario,
                            onChanged: (value) {
                              setState(() {
                                _poseeTituloTerciario = value!;
                              });
                            },
                          ),
                          const Text('No'),
                        ],
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _saveEducation,
                child: const Text('Guardar Educación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
