// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, avoid_print

import 'dart:io';
import 'dart:math';

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:cvgenius/presentation/widgets/pdf_theme_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

List<PdfColor> themeColors = [
  const PdfColor.fromInt(0xffCDF1E7),
  const PdfColor.fromInt(0xffFFDFBA),
  const PdfColor.fromInt(0xffBAE1FF),
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

  @override
  Widget build(BuildContext context) {
    final cvFuture = ref.watch(isarUserProvider).getUserCv(widget.userId);
    final selectedTheme = ref.read(selectedThemeProvider);

    Future<String> generatePdf(
        UserCv userCv, int themeIndex, PdfPageFormat format) async {
      final pdf = pw.Document(title: userCv.name, author: 'CVGenius');

      final selectedTheme =
          ref.read(selectedThemeProvider); // Obtén el índice actual

      final themeColor = themeColors[selectedTheme]; // Selección del color

      final pageTheme =
          await _myPageTheme(format, selectedTheme); // Pasa el índice

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
                            pw.Text(userCv.name.toUpperCase(),
                                textScaleFactor: 2,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(fontWeight: pw.FontWeight.bold)),
                            pw.Text('${userCv.age} años',
                                textScaleFactor: 1.5,
                                style: pw.Theme.of(context)
                                    .defaultTextStyle
                                    .copyWith(fontWeight: pw.FontWeight.bold)),
                            pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 10)),
                            pw.Padding(
                                padding: const pw.EdgeInsets.only(top: 20)),
                            pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: <pw.Widget>[
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: <pw.Widget>[
                                    pw.Text(userCv.address),
                                    pw.Text(userCv.nationality),
                                  ],
                                ),
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: <pw.Widget>[
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
                            child: pw.ClipRRect(
                              horizontalRadius: 50,
                              child: pw.Image(pw.MemoryImage(_imageBytes!),
                                  width: 100, height: 100),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (userCv.experiences.isNotEmpty)
              _Category(title: 'Experiencia Laboral', color: themeColor),
            _Block(
              color: themeColor,
              title: userCv.experiences.map((e) {
                return '${e.companyName.toUpperCase()} (${e.startDate} - ${e.endDate})\n ${e.position}';
              }).join('\n'),
              desc: userCv.experiences.map((e) {
                return e.description;
              }).join('\n'),
            ),
            if (userCv.studies.isNotEmpty)
              _Category(title: 'Educación', color: themeColor),
            _Block(
              color: themeColor,
              title: userCv.studies.map((study) {
                // Verificar el nivel de estudio según el contenido
                if (study.institutionName != null && study.degree != null) {
                  return study.institutionName;
                } else if (study.institutionName != null) {
                  return study.institutionName;
                } else if (study.degree != null) {
                  return study.degree;
                } else {
                  return 'Información no disponible';
                }
              }).join('\n'),
              desc: userCv.studies.map((study) {
                return '${study.degree} (${study.startDate} - ${study.endDate})';
              }).join('\n'),
            ),
            if (userCv.highStudies.isNotEmpty)
              _Block(
                color: themeColor,
                title: userCv.highStudies.map((study) {
                  if (study.institutionName != null && study.degree != null) {
                    return study.institutionName;
                  } else if (study.institutionName != null) {
                    return study.institutionName;
                  } else if (study.degree != null) {
                    return study.degree;
                  } else {
                    return 'Información no disponible';
                  }
                }).join('\n'),
                desc: userCv.highStudies.map((study) {
                  return '${study.degree} (${study.startDate} - ${study.endDate})';
                }).join('\n'),
              ),
            if (userCv.skills.isNotEmpty)
              _Category(title: 'Otros Conocimientos', color: themeColor),
            _Block1(
              color: themeColor,
              title: userCv.skills.map((e) => e.name.toUpperCase()).join(', '),
            ),
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
        title: const Text('Generar CV'),
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
            return const Center(
              child: Text('No se encontró información del usuario'),
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
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: MemoryImage(_imageBytes!),
                  ),
                const SizedBox(height: 16),

                // Datos personales
                _buildCard(
                  context,
                  title: 'Datos Personales',
                  children: [
                    Text('${userCv.name}, ${userCv.age} años'),
                    Text(userCv.email),
                    Text(userCv.phoneNumber),
                    Text(userCv.address),
                  ],
                ),

                // Educación
                if (userCv.highStudies.isNotEmpty || userCv.studies.isNotEmpty)
                  _buildCard(
                    context,
                    title: 'Educación',
                    children: [
                      ...userCv.studies.map((study) => ListTile(
                            title: Text(study.institutionName),
                            subtitle: Text(
                                study.isGraduated ? "Graduado" : "En curso"),
                          )),
                      ...userCv.highStudies.map((highStudy) => ListTile(
                            title: Text(highStudy.institutionName),
                            subtitle: Text(highStudy.degree),
                          )),
                    ],
                  ),

                // Experiencia laboral
                if (userCv.experiences.isNotEmpty)
                  _buildCard(
                    context,
                    title: 'Experiencia Laboral',
                    children: userCv.experiences.map((e) {
                      return ListTile(
                        title: Text(e.companyName),
                        subtitle: Text('${e.startDate} - ${e.endDate}'),
                        trailing: Text(e.position),
                      );
                    }).toList(),
                  ),

                // Conocimientos
                if (userCv.skills.isNotEmpty)
                  _buildCard(
                    context,
                    title: 'Conocimientos',
                    children: userCv.skills.map((skill) {
                      return ListTile(
                        title: Text(skill.name),
                      );
                    }).toList(),
                  ),

                // Botones de acciones
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.browse_gallery),
                      label: const Text('Seleccionar Imagen'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  height: 250,
                  child: ThemePreview(),
                ),
                // Botón para generar PDF
                ElevatedButton(
                  onPressed: () async {
                    final filePath = await generatePdf(
                        userCv, selectedTheme, PdfPageFormat.a4);
                    context.pop(context);
                    final result = await OpenFile.open(filePath);
                    if (result.type != ResultType.done) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el PDF'),
                        ),
                      );
                    }
                  },
                  child: const Text('Generar CV'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required List<Widget> children}) {
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

class _Block1 extends pw.StatelessWidget {
  final String title;
  final PdfColor color;
  _Block1({required this.title, required this.color});
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
            ]),
      ],
    );
  }
}

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
  print('Índice del tema seleccionado en _myPageTheme: $selectedThemeIndex');

  final themeSvgs = [
    'assets/svg/r1.svg',
    'assets/svg/r2.svg',
    'assets/svg/r3.svg',
  ];

  final bgShapePath = themeSvgs[selectedThemeIndex];
  print('Ruta del SVG seleccionado: $bgShapePath');

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
