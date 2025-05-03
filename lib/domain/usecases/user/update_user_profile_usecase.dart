// lib/domain/usecases/user/update_user_profile_usecase.dart
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class UpdateUserProfileUseCase {
  final UserRepository userRepository;

  UpdateUserProfileUseCase(this.userRepository);

  Future<void> execute(User user) async {
    await userRepository.saveUserProfile(user);
  }
}
