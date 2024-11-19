import 'package:cvgenius/presentation/providers/user_cv_provider.dart';
import 'package:cvgenius/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageViewForm extends ConsumerStatefulWidget {
  const PageViewForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PageViewFormState();
}

class _PageViewFormState extends ConsumerState<PageViewForm> {
  final PageController _pageViewController = PageController();
  int _activePage = 0;

  final List<Widget> _pages = [
    const PersonalData1(),
    const PersonalData2(),
    const PersonalData3(),
    const ExperienceJobsData(),
    const EducationData(),
    
   
  ];
  bool _isCurrentStepValid() {
    final userCv = ref.watch(userCvProvider);
    switch (_activePage) {
      case 0: // Validación para PersonalData
        return userCv.name.isNotEmpty && userCv.age.isNotEmpty;
      // Aquí puedes agregar validaciones para otros pasos
      case 1:
        return userCv.phoneNumber.isNotEmpty && userCv.email.isNotEmpty;
      case 2:
        return userCv.nationality.isNotEmpty && userCv.address.isNotEmpty;
      case 3:
        return userCv.experiences.isNotEmpty;
      case 4:
        return userCv.studies.isNotEmpty;
      default:
        return true;
    }
  }

  bool _isWelcomeScreenVisible =
      true; // Bandera para controlar si Step1 se muestra.

  void _hideWelcomeScreen() {
    setState(() {
      _isWelcomeScreenVisible = false;
    });
  }

  Future<void> _saveCv(WidgetRef ref) async {
    final notifier = ref.read(userCvProvider.notifier);

    try {
      notifier.setLoading(true);

      await Future.delayed(const Duration(seconds: 2));
      notifier.markAsSaved();
    } catch (e) {
      // ignore: avoid_print
      print('Error al guardar el CV: $e');
    } finally {
      notifier.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(userCvProvider.notifier);
    final isLoading = notifier.isLoading;
    final isSaved = notifier.isSaved;

    return Scaffold(
      body: _isWelcomeScreenVisible
          ? _buildWelcomeScreen() // Muestra Step1 si está activo.
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageViewController,
                  itemCount: _pages.length,
                  onPageChanged: (int value) {
                    setState(() {
                      _activePage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _pages[index % _pages.length];
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_activePage != 0)
                        ElevatedButton(
                          onPressed: () {
                            _pageViewController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Anterior'),
                        ),
                      if (_activePage != _pages.length - 1)
                        ElevatedButton(
                          onPressed: _isCurrentStepValid()
                              ? () {
                                  _pageViewController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          child: const Text('Siguiente'),
                        ),
                      if (_activePage == _pages.length - 1)
                        ElevatedButton(
                          onPressed:
                              isLoading || isSaved ? null : () => _saveCv(ref),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(isSaved ? 'Guardado' : 'Guardar'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¡Bienvenido!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _hideWelcomeScreen,
            child: const Text('Comenzar'),
          ),
        ],
      ),
    );
  }
}
