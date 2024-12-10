// ignore_for_file: avoid_print

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateCvScreen extends ConsumerStatefulWidget {
  const CreateCvScreen({super.key});

  @override
  ConsumerState<CreateCvScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<CreateCvScreen> {
  /// The current index of the step in the CV creation process.
  /// 
  /// This variable is used to keep track of the user's progress
  /// through the different steps of creating a CV.
  int _index = 0;

  final _formKeys =
      List<GlobalKey<FormState>>.generate(8, (index) => GlobalKey<FormState>());

  //datos personales controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  //experiencias controllers
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _posicionController = TextEditingController();
  final TextEditingController _desdeController = TextEditingController();
  final TextEditingController _hastaController = TextEditingController();
  final TextEditingController _posicionDescController = TextEditingController();
  final List<Map<String, dynamic>> _experiencias = [];

//estudios superiores controllers
  final TextEditingController _tituloTerciarioController =
      TextEditingController();
  final TextEditingController _institutioHighController =
      TextEditingController();
  final TextEditingController _startHighStudyController =
      TextEditingController();
  final TextEditingController _endHighStudyController = TextEditingController();
  final List<Map<String, dynamic>> _highEducacion = [];
  bool _poseeTituloTerciario = false;

  //estudios secundarios controllers
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _tituloSecundarioController =
      TextEditingController();
  final TextEditingController _startStudyController = TextEditingController();
  final TextEditingController _endStudyController = TextEditingController();
  final List<Map<String, dynamic>> _educacion = [];
  bool _poseeTituloSecundario = false;
  bool _secundarioGuardado = false;
  bool _terciarioGuardado = false;
  String _nivelSecundario = 'Secundario Completo';

  //skills controllers
  final TextEditingController _conocimientoController = TextEditingController();
  String _nivelController = 'Basico';
  final List<Map<String, String>> _conocimientos = [];
//availability controllers
  final List<Map<String, dynamic>> _availabilities = [];
  String _availController = 'Full Time';

  /// Saves the CV asynchronously.
  ///
  /// This method performs the necessary operations to save the current CV.
  /// It may involve file I/O, database operations, or other asynchronous tasks.
  /// Ensure that any required data is available before calling this method.
  ///
  /// Usage:
  /// ```dart
  /// _guardarCV();
  /// ```
  void _guardarCV() async {
    // Crear la instancia de UserCv
    final userCv = UserCv(
      name: _nombreController.text,
      age: _edadController.text,
      email: _emailController.text,
      phoneNumber: _telefonoController.text,
      address: _direccionController.text,
      nationality: _nationalityController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      // Puedes completar esto según tus necesidades
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

    final studies = _educacion
        .where((e) => e['nivelSecundario']?.isNotEmpty ?? false)
        .map((e) {
      return Study()
        ..institutionName = e['institution'] ?? ''
        ..degree = e['titulo'] ?? ''
        ..startDate = e['desde'] ?? ''
        ..endDate = e['hasta'] ?? ''
        ..isGraduated = e['poseeTituloSecundario'] ?? false;
    }).toList();

    final highStudies = _highEducacion
        .map((e) => HighStudy()
          ..institutionName = e['institution'] ?? ''
          ..degree = e['titulo'] ?? ''
          ..startDate = e['desde'] ?? ''
          ..endDate = e['hasta'] ?? ''
          ..isGraduated = e['poseeTituloTerciario'] ?? false)
        .toList();

    final skills = _conocimientos
        .map((c) => Skill()
          ..name = c['conocimiento'] ?? ''
          ..level = c['nivel'] ??
              '') // Puedes ajustar el nivel aquí según corresponda
        .toList();
    final availability = _availabilities.map((e) {
      return Availability()..title = e['avail'] ?? '';
    }).toList();

    final userCvRepository = ref.read(isarUserProvider);

    try {
      // Guardar el UserCv en la base de datos
      await userCvRepository.saveUserCv(userCv);

      // Obtener la instancia de Isar para las operaciones de transacción
      final isar = await userCvRepository.db;

      await isar.writeTxn(() async {
        for (var experience in experiences) {
          await isar.experiences.put(experience);
          userCv.experiences.add(experience);
        }
        for (var highStudy in highStudies) {
          await isar.highStudys.put(highStudy);
          userCv.highStudies.add(highStudy);
        }
        for (var study in studies) {
          await isar.studys.put(study);
          userCv.studies.add(study);
        }
        for (var skill in skills) {
          await isar.skills.put(skill);
          userCv.skills.add(skill);
        }
        for (var avail in availability) {
          print('Guardando disponibilidad: ${avail.title}');
          await isar.availabilitys.put(avail);
          userCv.availabilities.add(avail);
        }

        await userCv.experiences.save();
        await userCv.highStudies.save();
        await userCv.studies.save();
        await userCv.skills.save();
        await userCv.availabilities.save();
      });

      print('CV guardado exitosamente');
    } catch (error) {
      print('Error al guardar el CV: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// A list of steps used in the create CV screen.
    /// Each step represents a part of the CV creation process.
    List<Step> steps = [
      _step0(),
      _step1(),
      _step2(),
      _step3(),
      _step4(),
      _step5(),
      _step6(),
      _step7(),
    ];
    /// Validates the current step in the CV creation process.
    ///
    /// This method checks if the data entered in the current step is valid
    /// based on the given index.
    ///
    /// - Parameter index: The index of the step to validate.
    /// - Returns: A boolean value indicating whether the step is valid.
    bool validateStep(int index) {
      switch (index) {
        case 0:
          return _formKeys[0].currentState!.validate();
        case 1:
          return _formKeys[1].currentState!.validate();
        case 2:
          return _formKeys[2].currentState!.validate();
        case 3:
          return _experiencias.isNotEmpty || _experiencias.isEmpty;
        case 4:
          return _nivelSecundario == 'Secundario En Curso' ||
              _nivelSecundario == 'Secundario Incompleto' ||
              _nivelSecundario == 'Secundario Completo';
        case 5:
          return _highEducacion.isNotEmpty || _highEducacion.isEmpty;
        case 6:
          return _conocimientos.isNotEmpty || _conocimientos.isEmpty;
        case 7:
          return _formKeys[7].currentState!.validate();
        // No requiere validación
        default:
          return false;
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
            semanticsLabel: AppLocalizations.of(context)!.crearCv,
            AppLocalizations.of(context)!.crearCv),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          child: Stepper(
            physics: const BouncingScrollPhysics(),
            type: StepperType.horizontal,
            connectorColor: const WidgetStatePropertyAll(Colors.transparent),
            stepIconBuilder: (stepIndex, stepState) {
              switch (stepIndex) {
                case 0:
                  return const Icon(Icons.person_4_outlined);
                case 1:
                  return const Icon(
                    Icons.person_2_outlined,
                  );
                case 2:
                  return const Icon(Icons.person_3_outlined);
                case 3:
                  return const Icon(Icons.work_history_outlined);
                case 4:
                case 5:
                  return const Icon(Icons.school_outlined);
                case 6:
                  return const Icon(Icons.star_outline_outlined);
                case 7:
                  return const Icon(Icons.watch_later_outlined);
                default:
                  return const Icon(Icons.help_outlined);
              }
            },
            stepIconMargin: const EdgeInsets.all(0),
            currentStep: _index,
            onStepCancel: () {
              if (_index > 0) {
                setState(() {
                  _index -= 1;
                });
              }
            },
            onStepContinue: () {
              if (validateStep(_index)) {
                if (_index == steps.length - 1) {
                  _guardarCV();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          semanticsLabel:
                              AppLocalizations.of(context)!.cvGuardado,
                          AppLocalizations.of(context)!.cvGuardado),
                    ),
                  );
                  context.go('/'); // Navegar a la pantalla principal
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
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (_index > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: Text(
                            semanticsLabel: AppLocalizations.of(context)!.atras,
                            AppLocalizations.of(context)!.atras),
                      ),
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(
                          semanticsLabel: isLastStep
                              ? AppLocalizations.of(context)!.guardarCv
                              : AppLocalizations.of(context)!.continuar,
                          isLastStep
                              ? AppLocalizations.of(context)!.guardarCv
                              : AppLocalizations.of(context)!.continuar),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Step _step7() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[7],
        child: Center(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.disponibilidad,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ToggleButtons(
                isSelected: [
                  _availController == 'Full Time',
                  _availController == 'Part Time'
                ],
                onPressed: (int index) {
                  setState(() {
                    _availController = index == 0 ? 'Full Time' : 'Part Time';
                    if (_availabilities.isEmpty) {
                      _availabilities.add({'avail': _availController});
                    } else {
                      _availabilities[0]['avail'] = _availController;
                    }
                  });
                  print(
                      _availabilities); // Verifica que se está actualizando correctamente
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(AppLocalizations.of(context)!.fullTime),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(AppLocalizations.of(context)!.partTime),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Step _step6() {
    return Step(
      stepStyle: const StepStyle(),
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[6],
        child: Center(
          child: Column(
            children: [
              Text(
                semanticsLabel:
                    'Conocimientos Adicionales, ingrese sus conocimientos adicionales',
                AppLocalizations.of(context)!.conocimientosAdicionales,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              for (var conocimiento in _conocimientos)
                ExpansionTile(
                  title: Text(conocimiento['conocimiento']!),
                  children: [
                    ListTile(
                      title: Text(conocimiento['conocimiento']!),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _conocimientoController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.conocimientos),
                validator: (value) {
                  if (_conocimientos.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _nivelController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.nivel),
                items: [
                  DropdownMenuItem(
                    value: 'Basico',
                    child: Text(
                      AppLocalizations.of(context)!.basico,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Intermedio',
                    child: Text(
                      AppLocalizations.of(context)!.intermedio,
                    ),
                  ),
                  DropdownMenuItem(
                      value: 'Avanzado',
                      child: Text(AppLocalizations.of(context)!.avanzado)),
                ],
                onChanged: (value) {
                  setState(() {
                    _nivelController = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKeys[6].currentState!.validate()) {
                      setState(() {
                        _conocimientos.add({
                          'conocimiento': _conocimientoController.text,
                          'nivel':
                              _nivelController, // Puedes ajustar el nivel aquí según corresponda
                        });
                        _conocimientoController.clear();
                        _formKeys[6].currentState!.reset();
                      });
                    }
                  },
                  child:
                      Text(AppLocalizations.of(context)!.guardarConocimientos),
                ),
              ),
            ],
          ),
        ),
      ),
      isActive: _index == 6,
    );
  }

  Step _step5() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[5],
        child: Center(
          child: Column(
            children: [
              Text(
                semanticsLabel:
                    'Estudios Realizados, ingrese sus estudios terciarios o universitarios',
                AppLocalizations.of(context)!.estudiosRealizados,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              for (var highEducacion in _highEducacion)
                ExpansionTile(
                  title: Text(highEducacion['institution']!),
                  children: [
                    ListTile(
                      title: Text(highEducacion['titulo']!),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              if (!_terciarioGuardado)
                TextFormField(
                  controller: _institutioHighController,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.instiUni),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.msg1;
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tituloTerciarioController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tituloUni),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _startHighStudyController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fechaInicio),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _endHighStudyController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fechaFin),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.poseeTitulo),
                  Switch(
                    activeColor: Colors.green,
                    value: _poseeTituloTerciario,
                    onChanged: (value) {
                      setState(() {
                        _poseeTituloTerciario = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _terciarioGuardado = false;
                      _tituloTerciarioController.clear();
                      _institutioHighController.clear();
                      _startHighStudyController.clear();
                      _endHighStudyController.clear();
                      _poseeTituloTerciario = false;
                      _formKeys[5].currentState!.reset();
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                    onPressed: () {
                      if (_formKeys[5].currentState!.validate()) {
                        setState(() {
                          final highEducacion = {
                            'institution': _institutioHighController.text,
                            'titulo': _tituloTerciarioController.text,
                            'desde': _startHighStudyController.text,
                            'hasta': _endHighStudyController.text,
                            'poseeTituloTerciario': _poseeTituloTerciario,
                          };

                          _highEducacion.add(highEducacion);
                          _tituloTerciarioController.clear();
                          _institutioHighController.clear();
                          _startHighStudyController.clear();
                          _endHighStudyController.clear();
                          _poseeTituloTerciario = false;
                          _formKeys[5].currentState!.reset();
                          _terciarioGuardado = true;
                        });
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.guardarEstudios,
                    )),
              ),
            ],
          ),
        ),
      ),
      isActive: _index == 5,
    );
  }

  Step _step4() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[4],
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                semanticsLabel:
                    'Estudios Realizados, ingrese sus estudios secundarios',
                AppLocalizations.of(context)!.estudiosRealizados,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Formulario para agregar el nivel secundario
              const SizedBox(height: 10),
              if (!_secundarioGuardado)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _nivelSecundario,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.nivelSec),
                      items: [
                        DropdownMenuItem(
                            value: 'Secundario En Curso',
                            child:
                                Text(AppLocalizations.of(context)!.secEnCurso)),
                        DropdownMenuItem(
                            value: 'Secundario Incompleto',
                            child: Text(
                                AppLocalizations.of(context)!.secIncompleto)),
                        DropdownMenuItem(
                            value: 'Secundario Completo',
                            child: Text(
                                AppLocalizations.of(context)!.secCompleto)),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _nivelSecundario = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _institutionController,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.instiSec),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.msg1;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _tituloSecundarioController,
                      decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.tituloSec),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.msg1;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    if (_nivelSecundario == 'Secundario Completo')
                      Column(
                        children: [
                          TextFormField(
                            controller: _startStudyController,
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.fechaInicio),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.msg1;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _endStudyController,
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.fechaFin),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.msg1;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(AppLocalizations.of(context)!.poseeTitulo),
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
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKeys[4].currentState!.validate()) {
                            setState(() {
                              final educacion = {
                                'nivelSecundario': _nivelSecundario,
                                'institution': _institutionController.text,
                                'poseeTituloSecundario': _poseeTituloSecundario,
                                'desde': _startStudyController.text,
                                'hasta': _endStudyController.text,
                                'titulo': _tituloSecundarioController.text,
                              };

                              _educacion.add(educacion);

                              // Marcar como guardado y limpiar controladores
                              _secundarioGuardado = true;
                              _tituloSecundarioController.clear();
                              _institutionController.clear();
                              _startStudyController.clear();
                              _endStudyController.clear();
                              _formKeys[4].currentState!.reset();
                            });
                          }
                        },
                        child:
                            Text(AppLocalizations.of(context)!.guardarEstudios),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              // Lista de estudios guardados
              for (var edu in _educacion)
                ExpansionTile(
                  title: Text(edu['institution'] ?? 'Sin institución'),
                  children: [
                    ListTile(
                        title: Text(
                            '${AppLocalizations.of(context)!.nivelSec}: ${edu['nivelSecundario']}')),
                  ],
                ),
              // Botón para agregar estudios terciarios o universitarios
            ],
          ),
        ),
      ),
      isActive: _index == 4,
    );
  }

  Step _step3() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[3],
        child: Center(
          child: Column(
            children: [
              Text(
                semanticsLabel:
                    'Experiencia Laboral, ingrese su experiencia laboral',
                AppLocalizations.of(context)!.experienciaLaboral,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                      title: Text(
                          '${AppLocalizations.of(context)!.desde}: ${experiencia['desde']}'),
                    ),
                    ListTile(
                      title: Text(
                          '${AppLocalizations.of(context)!.hasta}: ${experiencia['hasta']}'),
                    ),
                    ListTile(
                      title: Text(
                          '${AppLocalizations.of(context)!.puesto}: ${experiencia['posicion']}'),
                    ),
                    ListTile(
                      title: Text(
                          '${AppLocalizations.of(context)!.funciones}: ${experiencia['funciones']}'),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _empresaController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.nombreEmpresa),
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _desdeController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fechaInicio),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _hastaController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fechaFin),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _posicionController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.puesto),
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _posicionDescController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.funciones),
                validator: (value) {
                  if (_experiencias.isEmpty &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKeys[3].currentState!.validate()) {
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
                        _formKeys[3].currentState!.reset();
                      });
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.guardarExperiencia),
                ),
              ),
            ],
          ),
        ),
      ),
      isActive: _index == 3,
    );
  }

  Step _step2() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[2],
        child: Center(
          child: Column(
            children: [
              Text(
                semanticsLabel:
                    'Datos Personales, ingrese su dirección y nacionalidad',
                AppLocalizations.of(context)!.datosPersonales,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nationalityController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.nacionalidadEjem,
                    labelText: AppLocalizations.of(context)!.nacionalidad),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.paisEjem,
                    labelText: AppLocalizations.of(context)!.pais),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.provinciaEjem,
                    labelText: AppLocalizations.of(context)!.provincia),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.ciudadEjem,
                    labelText: AppLocalizations.of(context)!.ciudad),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.direccionEjem,
                    labelText: AppLocalizations.of(context)!.direccion),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      isActive: _index == 2,
    );
  }

  Step _step1() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[1],
        child: Center(
          child: Column(
            children: [
              Text(
                semanticsLabel: 'Datos Personales, ingreso de email y telefono',
                AppLocalizations.of(context)!.datosPersonales,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email),
                validator: (value) {
                  final regex = RegExp(
                      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+(\.[a-zA-Z]+)?$');

                  if (value == null ||
                      value.isEmpty ||
                      !regex.hasMatch(value)) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.telefonoEjem,
                    labelText: AppLocalizations.of(context)!.telefono),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      isActive: _index == 1,
    );
  }

  Step _step0() {
    return Step(
      title: const SizedBox.shrink(),
      content: Form(
        key: _formKeys[0],
        child: Center(
          child: Column(
            children: [
              Text(
                semanticsLabel: 'Datos Personales',
                AppLocalizations.of(context)!.datosPersonales,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.nombreEjem,
                    labelText: AppLocalizations.of(context)!.nombreCompleto),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _edadController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.edad),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.msg1;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      isActive: _index == 0,
    );
  }
}
