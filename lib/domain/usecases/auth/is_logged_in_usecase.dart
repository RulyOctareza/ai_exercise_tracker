import '../../repositories/auth_repository.dart';

class IsLoggedInUseCase {
  final AuthRepository authRepository;

  IsLoggedInUseCase(this.authRepository);

  Future<bool> execute() async {
    return await authRepository.isLoggedIn();
  }
}
