import 'package:cvgenius/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para manejar el estado del CV
final userCvProvider = StateNotifierProvider<UserCvNotifier, UserCv>((ref) {
  return UserCvNotifier();
});

// Notifier para manejar el estado de UserCv
class UserCvNotifier extends StateNotifier<UserCv> {
  UserCvNotifier()
      : super(
          UserCv(
            name: '',
            email: '',
            phoneNumber: '',
            address: '',
            age: '',
            photoUrl: '',
            nationality: '',
          ),
        );
  bool _isSaved = false;
  bool _isLoading = false;

  bool get isSaved => _isSaved;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    // Notificar cambios a la UI
    state = state;
  }

  void markAsSaved() {
    _isSaved = true;
    state = state;
  }

  // Actualizar datos personales
  void updateName(String name) {
    state = UserCv(
      name: name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      address: state.address,
      age: state.age,
      photoUrl: state.photoUrl,
      nationality: state.nationality,
    );
  }

  void updateEmail(String email) {
    state = UserCv(
      name: state.name,
      email: email,
      phoneNumber: state.phoneNumber,
      address: state.address,
      age: state.age,
      photoUrl: state.photoUrl,
      nationality: state.nationality,
    );
  }

  void updatePhoneNumber(String phoneNumber) {
    state = UserCv(
      name: state.name,
      email: state.email,
      phoneNumber: phoneNumber,
      address: state.address,
      age: state.age,
      photoUrl: state.photoUrl,
      nationality: state.nationality,
    );
  }

  void updateAddress(String address) {
    state = UserCv(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      address: address,
      age: state.age,
      photoUrl: state.photoUrl,
      nationality: state.nationality,
    );
  }

  void updateAge(String age) {
    state = UserCv(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      address: state.address,
      age: age,
      photoUrl: state.photoUrl,
      nationality: state.nationality,
    );
  }

  void updateNationality(String nationality) {
    state = UserCv(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      address: state.address,
      age: state.age,
      photoUrl: state.photoUrl,
      nationality: nationality,
    );
 
  }

  // Método para actualizar la foto
  void updatePhoto(String photoUrl) {
    state = UserCv(
      name: state.name,
      email: state.email,
      phoneNumber: state.phoneNumber,
      address: state.address,
      age: state.age,
      nationality: state.nationality,
      photoUrl: photoUrl,
    );
  }

  // Agregar experiencia
  void addExperience(Experience experience) {
    state.experiences.add(experience);
   
  }

  // Agregar estudio
  void addStudy(Study study) {
    state.studies.add(study);
  }

  // Agregar habilidad
  void addSkill(Skill skill) {
    state.skills.add(skill);
  }

  // Eliminar experiencia
  void removeExperience(Experience experience) {
    state.experiences.remove(experience);
  }

  // Eliminar estudio
  void removeStudy(Study study) {
    state.studies.remove(study);
  }

  // Eliminar habilidad
  void removeSkill(Skill skill) {
    state.skills.remove(skill);
  }
}
