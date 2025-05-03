import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<User> execute(String email, String password) async {
    return await authRepository.signInWithEmailAndPassword(email, password);
  }
}
