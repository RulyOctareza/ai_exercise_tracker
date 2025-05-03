
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  final AuthRepository authRepository;

  GoogleLoginUseCase(this.authRepository);

  Future<User> execute() async {
    return await authRepository.signInWithGoogle();
  }
}
