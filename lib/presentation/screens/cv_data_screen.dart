// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, avoid_print

import 'dart:io';
import 'dart:math';

import 'package:cvgenius/config/const/enviroment.dart';
import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:cvgenius/presentation/widgets/pdf_theme_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

List<PdfColor> themeColors = [
  const PdfColor.fromInt(0xffa33d63),
  const PdfColor.fromInt(0xffCDF1E7),
  const PdfColor.fromInt(0xffFFDFBA),
  const PdfColor.fromInt(0xffBAE1FF),
  const PdfColor.fromInt(0xff800080),
];

class CvDataScreen extends ConsumerStatefulWidget {
  final Id userId;
  const CvDataScreen({super.key, required this.userId});

  @override
  ConsumerState<CvDataScreen> createState() => _CvDataScreenState();
}

class _CvDataScreenState extends ConsumerState<CvDataScreen> {
  Uint8List? _imageBytes;
  int selectedThemeIndex = 0;
  String? _generatedText;

  Future<String> generarCartaPresentacion(UserCv userCv, Locale locale) async {
    final apiKey = Enviroment.gemini;
    final client = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final isEnglish = locale.languageCode == 'en';
    final promptSpanish = [
      Content.text('''
  
  Genera una carta de presentación profesional para un currículum, basada en el siguiente perfil. 
  Si falta información en algún apartado, ignóralo en el texto generado. Usa un lenguaje inclusivo y profesional, evitando referencias de género.
  Omite un destinatario específico y solo deja el Estimado/a, omite la necesidad de tener que poner un nombre de destinatario.
  NO INCLUYAS [DATOS POR COMPLETAR] en el texto generado. Si falta información, simplemente omítela.
  Nombre: ${userCv.name}
  Edad: ${userCv.age}
  Experiencia laboral: 
  ${userCv.experiences.map((e) => '- ${e.companyName} (${e.startDate} - ${e.endDate}): ${e.position}').join('\n')}

  Formación académica:
  ${userCv.studies.map((s) => '- ${s.institutionName}: ${s.degree} (${s.startDate} - ${s.endDate})').join('\n')}

  Habilidades: ${userCv.skills.map((s) => s.name).join(', ')}

  El texto debe ser general y adaptable para cualquier destinatario, evitando detalles innecesarios como nombres específicos o fechas exactas.
  ''')
    ];
    final promptEnglish = [
      Content.text('''
  Generate a professional cover letter for a resume, based on the following profile.
  If any section lacks information, ignore it in the generated text. Use inclusive and professional language, avoiding gender-specific references.
  Leave the greeting as "Dear" without specifying a recipient's name.
  DO NOT INCLUDE [MISSING DATA] in the generated text. If information is missing, simply omit it.
  Name: ${userCv.name}
  Age: ${userCv.age}
  Work Experience: 
  ${userCv.experiences.map((e) => '- ${e.companyName} (${e.startDate} - ${e.endDate}): ${e.position}').join('\n')}

  Academic Background:
  ${userCv.studies.map((s) => '- ${s.institutionName}: ${s.degree} (${s.startDate} - ${s.endDate})').join('\n')}

  Skills: ${userCv.skills.map((s) => s.name).join(', ')}

  The text should be general and adaptable to any recipient, avoiding unnecessary details such as specific names or exact dates.
  ''')
    ];
    var prompt = isEnglish ? promptEnglish : promptSpanish;
    final count = await client.countTokens(prompt);
    print(count.totalTokens);
    final response = await client.generateContent(prompt);

    return response.text.toString();
  }

  Future<void> generarCarta(UserCv userCv) async {
    final locale = ref.read(localeProvider);
    final carta = await generarCartaPresentacion(userCv, locale);
    setState(() {
      _generatedText = carta;
    });
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes(); // Leer imagen como Uint8List
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      final bytes = await file.readAsBytes(); // Leer imagen como Uint8List
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(AppLocalizations.of(context)!.generandoCv),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cvFuture = ref.watch(isarUserProvider).getUserCv(widget.userId);
    final selectedTheme = ref.read(selectedThemeProvider);
    //creacion de carta de presentación

    //creacion del pdf
    Future<String> generatePdf(UserCv userCv, int themeIndex,
        PdfPageFormat format, BuildContext context) async {
      final pdf = pw.Document(
          title: userCv.name,
          author: 'CV Genius',
          creator: 'CV Genius',
          subject: 'CV Genius - Curriculum Vitae');

      final selectedTheme =
          ref.read(selectedThemeProvider); // Obtén el índice actual

      final themeColor = themeColors[selectedTheme]; // Selección del color
      final applocalizations = AppLocalizations.of(context);
      final pageTheme = await _myPageTheme(format, selectedTheme);
      // Pasa el índice
      pdf.addPage(pw.Page(
          pageTheme: pageTheme,
          build: (pw.Context context) {
            if (_generatedText != null) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10),
                child: pw.Text(_generatedText!),
              );
            } else {
              return pw.Container();
            }
          }));
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          build: (pw.Context context) => [
            pw.Partitions(
              children: [
                pw.Partition(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text(
                              userCv.name.toUpperCase(),
                              textScaleFactor: 2,
                              style: pw.Theme.of(context)
                                  .defaultTextStyle
                                  .copyWith(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                              '${userCv.age} ${applocalizations!.anios}',
                              textScaleFactor: 1.5,
                              style: pw.Theme.of(context)
                                  .defaultTextStyle
                                  .copyWith(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                                '${applocalizations.disponibilidad} ${userCv.availabilities.map((a) => a.title).join(', ')}',
                                textScaleFactor: 1.5,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(fontWeight: pw.FontWeight.bold)),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 10),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 20),
                            ),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: <pw.Widget>[
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: <pw.Widget>[
                                    pw.Text(userCv.country),
                                    pw.Text(userCv.city),
                                    pw.Text(userCv.address),
                                  ],
                                ),
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: <pw.Widget>[
                                    pw.Text(userCv.nationality),
                                    pw.Text(userCv.email),
                                    pw.Text(userCv.phoneNumber),
                                  ],
                                ),
                                pw.Padding(padding: pw.EdgeInsets.zero)
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_imageBytes != null && _imageBytes!.isNotEmpty)
                        pw.Expanded(
                          flex: 1,
                          child: pw.Align(
                            alignment: pw.Alignment.topRight,
                            child: pw.Container(
                              width: 150,
                              height: 150,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                image: pw.DecorationImage(
                                  image: pw.MemoryImage(_imageBytes!),
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            pw.Divider(color: themeColor),
            if (userCv.experiences.isNotEmpty)
              _Category(title: applocalizations.experiencia, color: themeColor),
            ...userCv.experiences.map((e) {
              return _Block(
                color: themeColor,
                title:
                    '${e.companyName.toUpperCase()} (${e.startDate} - ${e.endDate})',
                desc: '${e.position}\n${e.description}',
              );
            }),
            if (userCv.studies.isNotEmpty)
              _Category(title: applocalizations.estudios, color: themeColor),
            ...userCv.studies.map((study) {
              // Verificar el nivel de estudio según el contenido
              if (study.institutionName != null && study.degree != null) {
                return _Block(
                  color: themeColor,
                  title: study.institutionName.toUpperCase(),
                  desc:
                      '${study.degree} (${study.startDate} - ${study.endDate})',
                );
              } else if (study.institutionName != null) {
                return _Block(
                  color: themeColor,
                  title: study.institutionName.toUpperCase(),
                  desc: '${study.startDate} - ${study.endDate}',
                );
              } else if (study.degree != null) {
                return _Block(
                  color: themeColor,
                  title: study.degree,
                  desc: '${study.startDate} - ${study.endDate}',
                );
              } else if (study.isGraduated != null &&
                  study.isGraduated == true) {
                return _Block(
                  color: themeColor,
                  title: applocalizations.secCompleto,
                  desc: '${study.startDate} - ${study.endDate}',
                );
              } else {
                return _Block(
                  color: themeColor,
                  title: applocalizations.msg2,
                  desc: '',
                );
              }
            }),
            if (userCv.highStudies.isNotEmpty)
              ...userCv.highStudies.map(
                (study) {
                  return _Block(
                    color: themeColor,
                    title: study.institutionName.toUpperCase(),
                    desc:
                        '${study.degree} (${study.startDate} - ${study.endDate})',
                  );
                },
              ),
            if (userCv.skills.isNotEmpty)
              _Category(
                  title: applocalizations.conocimientos, color: themeColor),
            ...userCv.skills.map((skill) {
              return _Block(
                color: themeColor,
                title: skill.name,
                desc: skill.level,
              );
            }),
          ],
        ),
      );

      // Guardar el archivo
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/cv_${userCv.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      return filePath;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            semanticsLabel: AppLocalizations.of(context)!.generarCv,
            AppLocalizations.of(context)!.generarCv),
        centerTitle: true,
      ),
      body: FutureBuilder<UserCv?>(
        future: cvFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(AppLocalizations.of(context)!.msg2),
            );
          }

          final userCv = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar
                if (_imageBytes != null && _imageBytes!.isNotEmpty)
                  Semantics(
                    label: AppLocalizations.of(context)!.imagenDePerfil,
                    container: true,
                    enabled: true,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: MemoryImage(_imageBytes!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Datos personales
                _buildCard(
                  semantics: Semantics(
                    label: AppLocalizations.of(context)!.datosPersonales,
                  ),
                  context,
                  title: AppLocalizations.of(context)!.datosPersonales,
                  children: [
                    Text(
                        '${userCv.name}, ${userCv.age} ${AppLocalizations.of(context)!.anios}'),
                    Text(userCv.availabilities.map((a) => a.title).join(', ')),
                    Text(userCv.email),
                    Text(userCv.phoneNumber),
                    Text(userCv.country),
                    Text(userCv.city),
                    Text(userCv.address),
                  ],
                ),

                // Educación
                if (userCv.highStudies.isNotEmpty || userCv.studies.isNotEmpty)
                  _buildCard(
                    semantics: Semantics(
                      label: AppLocalizations.of(context)!.estudiosRealizados,
                    ),
                    context,
                    title: AppLocalizations.of(context)!.estudiosRealizados,
                    children: [
                      ...userCv.studies.map((study) => ListTile(
                            title: Text(
                              study.institutionName.toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(study.isGraduated
                                ? AppLocalizations.of(context)!.graduado
                                : AppLocalizations.of(context)!.enCurso),
                          )),
                      ...userCv.highStudies.map((highStudy) => ListTile(
                            title: Text(
                              highStudy.institutionName.toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(
                                '${highStudy.degree} ${highStudy.isGraduated} ? ${AppLocalizations.of(context)!.graduado} : ${AppLocalizations.of(context)!.enCurso}}'),
                          )),
                    ],
                  ),

                // Experiencia laboral
                if (userCv.experiences.isNotEmpty)
                  _buildCard(
                    semantics: Semantics(
                      label: AppLocalizations.of(context)!.experienciaLaboral,
                    ),
                    context,
                    title: AppLocalizations.of(context)!.experienciaLaboral,
                    children: userCv.experiences.map((e) {
                      return ListTile(
                        title: Text(
                          e.companyName.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text('${e.startDate} - ${e.endDate}'),
                        trailing: Text(e.position),
                      );
                    }).toList(),
                  ),

                // Conocimientos
                if (userCv.skills.isNotEmpty)
                  _buildCard(
                    semantics: Semantics(
                      label: AppLocalizations.of(context)!.conocimientos,
                    ),
                    context,
                    title: AppLocalizations.of(context)!.conocimientos,
                    children: userCv.skills.map((skill) {
                      return ListTile(
                        title: Text(
                          skill.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(skill.level),
                      );
                    }).toList(),
                  ),

                // Botones de acciones

                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: Text(AppLocalizations.of(context)!
                                      .seleccionarFoto),
                                  onTap: () {
                                    context.pop(context);
                                    pickImage();
                                  },
                                ),
                                if (Platform.isAndroid)
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: Text(AppLocalizations.of(context)!
                                        .tomarFoto),
                                    onTap: () {
                                      context.pop(context);
                                      takePicture();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(AppLocalizations.of(context)!.aniadirFoto),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  height: 250,
                  child: ThemePreview(),
                ),
                // Botón para generar PDF
                ElevatedButton(
                  onPressed: () async {
                    showLoadingDialog(context);
                    try {
                      await generarCarta(userCv);
                      final filePath = await generatePdf(
                          userCv, selectedTheme, PdfPageFormat.a4, context);
                      context.pop(context);
                      final result = await OpenFile.open(filePath);
                      if (result.type != ResultType.done) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!.noSePudoAbrirPdf),
                          ),
                        );
                      }
                    } catch (e) {
                      context.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                        ),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.generarCv),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required List<Widget> children,
      required Semantics semantics}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title, required this.color});

  final String title;
  final PdfColor color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      margin: const pw.EdgeInsets.only(bottom: 10, top: 20),
      padding: const pw.EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: pw.Text(
        title,
        textScaleFactor: 1.5,
      ),
    );
  }
}

// class _Block1 extends pw.StatelessWidget {
//   final String title;
//   final PdfColor color;
//   _Block1({required this.title, required this.color});
//   @override
//   pw.Widget build(pw.Context context) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: <pw.Widget>[
//         pw.Row(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: <pw.Widget>[
//               pw.Container(
//                 width: 6,
//                 height: 6,
//                 margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
//                 decoration: pw.BoxDecoration(
//                   color: color,
//                   shape: pw.BoxShape.circle,
//                 ),
//               ),
//               pw.Text(title,
//                   style: pw.Theme.of(context)
//                       .defaultTextStyle
//                       .copyWith(fontWeight: pw.FontWeight.bold)),
//             ]),
//       ],
//     );
//   }
// }

class _Block extends pw.StatelessWidget {
  final String title;
  final String desc;
  final PdfColor color;

  _Block({
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                decoration: pw.BoxDecoration(
                  color: color,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Text(title,
                  style: pw.Theme.of(context)
                      .defaultTextStyle
                      .copyWith(fontWeight: pw.FontWeight.bold)),
              pw.Spacer(),
            ]),
        pw.Container(
          decoration: pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: color, width: 2))),
          padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
          margin: const pw.EdgeInsets.only(left: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(desc),
            ],
          ),
        ),
      ],
    );
  }
}

Future<pw.PageTheme> _myPageTheme(
    PdfPageFormat format, int selectedThemeIndex) async {
  final themeSvgs = [
    'assets/svg/r0.svg',
    'assets/svg/r1.svg',
    'assets/svg/r2.svg',
    'assets/svg/r3.svg',
    'assets/svg/r4.svg',
  ];

  final bgShapePath = themeSvgs[selectedThemeIndex];

  final bgShape = await rootBundle.loadString(bgShapePath);

  // Configuración del formato
  format = format.applyMargin(
    left: 2.0 * PdfPageFormat.cm,
    top: 4.0 * PdfPageFormat.cm,
    right: 2.0 * PdfPageFormat.cm,
    bottom: 2.0 * PdfPageFormat.cm,
  );

  return pw.PageTheme(
    pageFormat: format,
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              child: pw.SvgImage(svg: bgShape),
              left: 0,
              top: 0,
            ),
            pw.Positioned(
              child: pw.Transform.rotate(
                angle: pi,
                child: pw.SvgImage(svg: bgShape),
              ),
              right: 0,
              bottom: 0,
            ),
          ],
        ),
      );
    },
  );
}
