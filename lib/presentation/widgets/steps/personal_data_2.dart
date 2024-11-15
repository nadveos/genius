import 'package:cvgenius/presentation/providers/user_cv_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalData2 extends ConsumerStatefulWidget {
  const PersonalData2({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PersonalDataState();
}

class _PersonalDataState extends ConsumerState<PersonalData2> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Escuchar cambios en los controladores
    _phoneController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);

    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _phoneController.text.isNotEmpty && _emailController.text.isNotEmpty;
    });
  }

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      ref.read(userCvProvider.notifier).updatePhoneNumber(_phoneController.text);
      ref.read(userCvProvider.notifier).updateEmail(_emailController.text);
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
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Ingrese su número de teléfono', hintText: 'Ej. 1234567890'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese su teléfono'
                      : null,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo Electronico'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Ingrese su correo'
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
