import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository userRepository;

  GetUserProfileUseCase(this.userRepository);

  Future<User?> execute(String userId) async {
    return await userRepository.getUserById(userId);
  }
}
