// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, avoid_print

import 'dart:io';
import 'dart:math';

import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:cvgenius/presentation/widgets/pdf_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const PdfColor green = PdfColor.fromInt(0xff9ce5d0);
const PdfColor lightGreen = PdfColor.fromInt(0xffcdf1e7);
const sep = 120.0;

class CvDataScreen extends ConsumerWidget {
  final Id userId;
  const CvDataScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataCv = ref.watch(isarUserProvider);
    final cv = dataCv.getUserCv(userId);
    final selectedTheme = ref.read(selectedThemeProvider);
    // Crear una variable para la decoración del tema

    Future<String> generatePdf(
        UserCv userCv, int themeIndex, PdfPageFormat format) async {
      final pdf = pw.Document(title: userCv.name, author: 'CVGenius');

      final selectedTheme =
          ref.read(selectedThemeProvider); // Obtén el índice actual

      final pageTheme =
          await _myPageTheme(format, selectedTheme); // Pasa el índice
      pdf.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          build: (pw.Context context) => [
            pw.Partitions(
              children: [
                pw.Partition(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 30, bottom: 20),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Text(userCv.name.toUpperCase(),
                                textScaleFactor: 2,
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
                                    pw.Text('${userCv.age} años'),
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
                    ],
                  ),
                ),
              ],
            ),
            if(userCv.experiences.isNotEmpty)
            _Category(title: 'Experiencia Laboral'),
            _Block(
              title: userCv.experiences.map((e) {
                return '${e.companyName.toUpperCase()} (${e.startDate} - ${e.endDate})\n ${e.position}';
              }).join('\n'),
              desc: userCv.experiences.map((e) {
                return e.description;
              }).join('\n'),
            ),
            if(userCv.highStudies.isNotEmpty || userCv.studies.isNotEmpty)
            _Category(title: 'Educación'),
            _Block(
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
            if(userCv.skills.isNotEmpty)
            _Category(title: 'Otros Conocimientos'),
            _Block1(
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
      appBar: AppBar(title: const Text('Generar CV')),
      body: FutureBuilder(
        future: cv,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text('No se encontró información del usuario'));
          }

          final userCv = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Card(
                      child: Column(
                        children: [
                          const Text(
                            'Datos Personales',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('${userCv.name}, ${userCv.age} años'),
                          Text(userCv.email),
                          Text(userCv.phoneNumber),
                          Text(userCv.address),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Card(
                      child: Column(
                        children: [
                          const Text(
                            'Experiencia Laboral',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: userCv.experiences.map((e) {
                              return Column(
                                children: [
                                  Text(
                                      '${e.companyName} (${e.startDate} - ${e.endDate})'),
                                  Text(e.position),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Card(
                      child: Column(
                        children: [
                          const Text(
                            'Conocimientos',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: userCv.skills.map((e) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(e.name),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (userCv.highStudies.isNotEmpty ||
                      userCv.studies.isNotEmpty)
                    SizedBox(
                      width: 200,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Card(
                        child: Column(
                          children: [
                            const Text(
                              'Educación',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: [
                                ...(userCv.studies.toList()).map(
                                  (study) {
                                    return Column(
                                      children: [
                                        Text(
                                            '${study.institutionName} (${study.startDate} - ${study.endDate})'),
                                      ],
                                    );
                                  },
                                ),
                                ...(userCv.highStudies.toList()).map(
                                  (study) {
                                    return Column(
                                      children: [
                                        Text(
                                            '${study.institutionName} (${study.startDate} - ${study.endDate})'),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 150, // Altura específica para `ThemePreview`
                child: ThemePreview(), // Muestra la vista previa de tema
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final filePath = await generatePdf(
                      userCv, selectedTheme, PdfPageFormat.a4);
                  final result = await OpenFile.open(filePath);
                  if (result.type != ResultType.done) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se pudo abrir el PDF')),
                    );
                  }
                },
                child: const Text('Generar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Category extends pw.StatelessWidget {
  _Category({required this.title});

  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        color: lightGreen,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
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

  _Block1({required this.title});
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
                decoration: const pw.BoxDecoration(
                  color: green,
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
  _Block({
    required this.title,
    required this.desc,
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
                decoration: const pw.BoxDecoration(
                  color: green,
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
          decoration: const pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: green, width: 2))),
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
