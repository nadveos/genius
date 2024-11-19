// ignore_for_file: avoid_print

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateCvScreen extends ConsumerStatefulWidget {
  const CreateCvScreen({super.key});

  @override
  ConsumerState<CreateCvScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<CreateCvScreen> {
  int _index = 0;

  final _formKeys =
      List<GlobalKey<FormState>>.generate(8, (index) => GlobalKey<FormState>());

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _posicionController = TextEditingController();
  final TextEditingController _desdeController = TextEditingController();
  final TextEditingController _hastaController = TextEditingController();
  final TextEditingController _posicionDescController = TextEditingController();

  final TextEditingController _tituloSecundarioController =
      TextEditingController();
  final TextEditingController _tituloTerciarioController =
      TextEditingController();
  final TextEditingController _institutionController = TextEditingController();

  final TextEditingController _startStudyController = TextEditingController();
  final TextEditingController _endStudyController = TextEditingController();
  final List<Map<String, dynamic>> _educacion = [];


  final TextEditingController _conocimientoController = TextEditingController();

  final List<Map<String, dynamic>> _experiencias = [];
  final List<Map<String, String>> _conocimientos = [];

  String _nivelSecundario = 'Secundario Completo';
  String _nivelTerciario = 'Terciario en Curso';
  bool _poseeTituloSecundario = false;
  bool _poseeTituloTerciario = false;
  bool _secundarioGuardado = false;

  void _guardarCV() async {
  // Crear la instancia de UserCv
  final userCv = UserCv(
    name: _nombreController.text,
    age: _edadController.text,
    email: _emailController.text,
    phoneNumber: _telefonoController.text,
    address: _direccionController.text,
    nationality: '', // Puedes completar esto según tus necesidades
    photoUrl: '', // Puedes completar esto según tus necesidades
  );

  // Crear listas de experiencias, estudios y habilidades
  final experiences = _experiencias
      .map((e) => Experience()
        ..companyName = e['empresa'] ?? ''
        ..position = e['posicion'] ?? ''
        ..startDate = e['desde'] ?? ''
        ..endDate = e['hasta'] ?? ''
        ..description = e['funciones'] ?? '')
      .toList();

  final studies = _educacion.map((e) {
    return Study()
      ..institutionName = e['institution'] ?? ''
      ..degree = e['nivelSecundario'] ?? e['titulo'] ?? ''
      ..startDate = e['desde'] ?? ''
      ..endDate = e['hasta'] ?? ''
      ..isGraduated = e['poseeTituloSecundario'] ?? false;
  }).toList();

  final skills = _conocimientos
      .map((c) => Skill()
        ..name = c['conocimiento'] ?? ''
        ..level = '') // Puedes ajustar el nivel aquí según corresponda
      .toList();

  final userCvRepository = ref.read(isarUserProvider);

  try {
    // Guardar el UserCv en la base de datos
    await userCvRepository.saveUserCv(userCv);

    // Obtener la instancia de Isar para las operaciones de transacción
    final isar = await userCvRepository.db;

    await isar.writeTxn(() async {
      // Guardar experiencias, estudios y habilidades en la base de datos
      for (var experience in experiences) {
        await isar.experiences.put(experience);
        userCv.experiences.add(experience); // Agregar la experiencia a UserCv
      }
      for (var study in studies) {
        await isar.studys.put(study);
        userCv.studies.add(study); // Agregar el estudio a UserCv
      }
      for (var skill in skills) {
        await isar.skills.put(skill);
        userCv.skills.add(skill); // Agregar la habilidad a UserCv
      }

      // Guardar las relaciones en el objeto UserCv
      await userCv.experiences.save();
      await userCv.studies.save();
      await userCv.skills.save();
    });

    print('CV guardado exitosamente');
  } catch (error) {
    print('Error al guardar el CV: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text('Nombre'),
        content: Form(
          key: _formKeys[0],
          child: TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
            hintText: 'Ej.: Juan Pérez',
            labelText: 'Nombre Completo'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su nombre';
              }
              return null;
            },
          ),
        ),
        isActive: _index == 0,
      ),
      Step(
        title: const Text('Edad'),
        content: Form(
          key: _formKeys[1],
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _edadController,
            decoration: const InputDecoration(labelText: 'Edad'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su edad';
              }
              return null;
            },
          ),
        ),
        isActive: _index == 1,
      ),
      Step(
        title: const Text('Email'),
        content: Form(
          key: _formKeys[2],
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su email';
              }
              return null;
            },
          ),
        ),
        isActive: _index == 2,
      ),
      Step(
        title: const Text('Teléfono'),
        content: Form(
          key: _formKeys[3],
          child: TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
            hintText: 'Ej.: 3874111222',
            labelText: 'Telefono'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su telefono';
              }
              return null;
            },
          ),
        ),
        isActive: _index == 3,
      ),
      Step(
        title: const Text('Dirección'),
        content: Form(
          key: _formKeys[4],
          child: TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
            hintText: 'Ej.: Av. San Martín 123, Salta',
            labelText: 'Direccion'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su direccion';
              }
              return null;
            },
          ),
        ),
        isActive: _index == 4,
      ),
      Step(
        title: const Text('Experiencia'),
        content: Form(
          key: _formKeys[5],
          child: Column(
            children: [
              for (var experiencia in _experiencias)
                ExpansionTile(
                  title: Text(
                    experiencia['empresa']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  children: [
                    ListTile(
                      title: Text('Desde: ${experiencia['desde']}'),
                    ),
                    ListTile(
                      title: Text('Hasta: ${experiencia['hasta']}'),
                    ),
                    ListTile(
                      title:
                          Text('Tareas/Funciones: ${experiencia['posicion']}'),
                    ),
                    ListTile(
                      title: Text(
                          'Descripcion de funciones: ${experiencia['funciones']}'),
                    ),
                  ],
                ),
              TextFormField(
                controller: _empresaController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la empresa'),
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor ingrese el nombre de la empresa';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _desdeController,
                decoration: const InputDecoration(labelText: 'Desde (año)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor ingrese el año de inicio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hastaController,
                decoration: const InputDecoration(labelText: 'Hasta (año)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor ingrese el año de finalización';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _posicionController,
                decoration: const InputDecoration(labelText: 'Posicion'),
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor describa su Posición';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _posicionDescController,
                decoration: const InputDecoration(
                    labelText: 'Descripcion de funciones'),
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor describa sus funciones';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKeys[5].currentState!.validate()) {
                    setState(() {
                      _experiencias.add({
                        'empresa': _empresaController.text,
                        'desde': _desdeController.text,
                        'hasta': _hastaController.text,
                        'posicion': _posicionController.text,
                        'funciones': _posicionDescController.text,
                      });
                      _empresaController.clear();
                      _desdeController.clear();
                      _hastaController.clear();
                      _posicionController.clear();
                      _posicionDescController.clear();
                      _formKeys[5].currentState!.reset();
                    });
                  }
                },
                child: const Text('Guardar Experiencia'),
              ),
            ],
          ),
        ),
        isActive: _index == 5,
      ),
      Step(
  title: const Text('Educación'),
  content: Form(
    key: _formKeys[6],
    child: Column(
      children: [
        if (!_secundarioGuardado)
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: _nivelSecundario,
                decoration: const InputDecoration(labelText: 'Nivel Secundario'),
                items: const [
                  DropdownMenuItem(
                      value: 'Secundario Completo', child: Text('Secundario Completo')),
                  DropdownMenuItem(
                      value: 'Secundario En Curso', child: Text('Secundario En Curso')),
                  DropdownMenuItem(
                      value: 'Secundario Incompleto', child: Text('Secundario Incompleto')),
                ],
                onChanged: (value) {
                  setState(() {
                    _nivelSecundario = value!;
                  });
                },
              ),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(labelText: 'Colegio o Institución'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la institución';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tituloSecundarioController,
                decoration: const InputDecoration(labelText: 'Título Obtenido/En Curso'),
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
                      decoration: const InputDecoration(labelText: 'Desde (año)'),
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
                      decoration: const InputDecoration(labelText: 'Hasta (año)'),
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
                        Switch(
                          activeColor: Colors.green,

                          value: _poseeTituloSecundario,
                          onChanged: (value) {
                            setState(() {
                              _poseeTituloSecundario = value;
                            });
                          },
                        ),
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
              ListTile(title: Text('Nivel Secundario: ${edu['nivelSecundario']}')),
              if (edu['nivelTerciario'] != null)
                ListTile(title: Text('Nivel Terciario/Universitario: ${edu['nivelTerciario']}')),
              ListTile(title: Text('Posee título: ${edu['poseeTituloSecundario'] ? 'Sí' : 'No'}')),
            ],
          ),
        Visibility(
          visible: _nivelSecundario == 'Secundario Completo',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _nivelTerciario,
                decoration: const InputDecoration(labelText: 'Nivel Terciario/Universitario'),
                items: const [
                  DropdownMenuItem(
                      value: 'Terciario en Curso', child: Text('Terciario en Curso')),
                  DropdownMenuItem(
                      value: 'Terciario Completo', child: Text('Terciario Completo')),
                  DropdownMenuItem(
                      value: 'Universitario en Curso', child: Text('Universitario en Curso')),
                  DropdownMenuItem(
                      value: 'Universitario Completo', child: Text('Universitario Completo')),
                ],
                onChanged: (value) {
                  setState(() {
                    _nivelTerciario = value!;
                  });
                },
              ),
              TextFormField(
                controller: _tituloTerciarioController,
                decoration: const InputDecoration(labelText: 'Título Terciario/Universitario'),
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
          onPressed: () {
            if (_formKeys[6].currentState!.validate()) {
              setState(() {
                final educacion = {
                  'nivelSecundario': _nivelSecundario,
                  'institution': _institutionController.text,
                  'poseeTituloSecundario': _poseeTituloSecundario,
                  'desde': _startStudyController.text,
                  'hasta': _endStudyController.text,
                };
                if (_tituloTerciarioController.text.isNotEmpty) {
                  educacion['nivelTerciario'] = _nivelTerciario;
                  educacion['titulo'] = _tituloTerciarioController.text;
                  educacion['poseeTituloTerciario'] = _poseeTituloTerciario;
                }
                _educacion.add(educacion);
                _tituloSecundarioController.clear();
                _tituloTerciarioController.clear();
                _institutionController.clear();
                _startStudyController.clear();
                _endStudyController.clear();
                _formKeys[6].currentState!.reset();
                if (_nivelSecundario == 'Secundario Completo') {
                  _secundarioGuardado = true;
                }
              });
            }
          },
          child: const Text('Guardar Educación'),
        ),
      ],
    ),
  ),
  isActive: _index == 6,
),

      Step(
        title: const Text('Otros Conocimientos'),
        content: Form(
          key: _formKeys[7],
          child: Column(
            children: [
              for (var conocimiento in _conocimientos)
                ExpansionTile(
                  title: Text(conocimiento['conocimiento']!),
                  children: [
                    ListTile(
                      title: Text(conocimiento['conocimiento']!),
                    ),
                  ],
                ),
              TextFormField(
                controller: _conocimientoController,
                decoration: const InputDecoration(labelText: 'Conocimiento'),
                validator: (value) {
                  if (_conocimientos.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Por favor ingrese un conocimiento';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKeys[7].currentState!.validate()) {
                    setState(() {
                      _conocimientos.add({
                        'conocimiento': _conocimientoController.text,
                      });
                      _conocimientoController.clear();
                      _formKeys[7].currentState!.reset();
                    });
                  }
                },
                child: const Text('Guardar Conocimiento'),
              ),
            ],
          ),
        ),
        isActive: _index == 7,
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Crear CV'),
      ),
      body: Stepper(
        physics: const BouncingScrollPhysics(),
        type: StepperType.vertical,
        currentStep: _index,
        onStepCancel: () {
          if (_index > 0) {
            setState(() {
              _index -= 1;
            });
          }
        },
        onStepContinue: () {
          if (_formKeys[_index].currentState!.validate() ||
              (_index == 5 && _experiencias.isNotEmpty) ||
              (_index == 6 &&
                  (_nivelSecundario == 'Secundario En Curso' ||
                      _nivelSecundario == 'Secundario Incompleto')) ||
              (_index == 7 && _conocimientos.isNotEmpty)) {
            if (_index == steps.length - 1) {
              _guardarCV();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CV guardado exitosamente'),
                ),
              );
              context.go('/');
            } else {
              setState(() {
                _index += 1;
              });
            }
          }
        },
        onStepTapped: (int index) {
          setState(() {
            _index = index;
          });
        },
        steps: steps,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isLastStep = _index == steps.length - 1;
          return Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isLastStep ? 'Guardar CV' : 'Continuar'),
              ),
              if (_index > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Atrás'),
                ),
            ],
          );
        },
      ),
    );
  }
}
