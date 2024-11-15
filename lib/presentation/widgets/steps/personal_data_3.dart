import 'package:cvgenius/presentation/providers/user_cv_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalData3 extends ConsumerStatefulWidget {
  const PersonalData3({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PersonalDataState();
}

class _PersonalDataState extends ConsumerState<PersonalData3> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nationalityController;
  late TextEditingController _addressController;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nationalityController = TextEditingController();
    _addressController = TextEditingController();

    // Escuchar cambios en los controladores
    _nationalityController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nationalityController.removeListener(_validateForm);
    _addressController.removeListener(_validateForm);

    _nationalityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _nationalityController.text.isNotEmpty && _addressController.text.isNotEmpty;
    });
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      ref.read(userCvProvider.notifier).updateNationality(_nationalityController.text);
      ref.read(userCvProvider.notifier).updateAddress(_addressController.text);
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
                  controller: _nationalityController,
                  decoration: const InputDecoration(labelText: 'Nacionalidad'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese su nacionalidad'
                      : null,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Dirección completa', hintText: 'Ej. Calle 123, Ciudad'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese su dirección'
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
