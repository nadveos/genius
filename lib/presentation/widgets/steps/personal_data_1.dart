import 'package:cvgenius/presentation/providers/user_cv_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalData1 extends ConsumerStatefulWidget {
  const PersonalData1({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PersonalDataState();
}

class _PersonalDataState extends ConsumerState<PersonalData1> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();

    // Escuchar cambios en los controladores
    _nameController.addListener(_validateForm);
    _ageController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _ageController.removeListener(_validateForm);

    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _nameController.text.isNotEmpty && _ageController.text.isNotEmpty;
    });
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      ref.read(userCvProvider.notifier).updateName(_nameController.text);
      ref.read(userCvProvider.notifier).updateAge(_ageController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo', hintText: 'Ej. Juan Pérez'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese su nombre'
                      : null,
                ),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese su edad'
                      : null,
                ),
                ElevatedButton(
                  onPressed: _isFormValid ? _saveData : null,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
