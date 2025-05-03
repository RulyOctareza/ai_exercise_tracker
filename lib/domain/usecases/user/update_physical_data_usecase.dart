import '../../repositories/user_repository.dart';

class UpdatePhysicalDataUseCase {
  final UserRepository userRepository;

  UpdatePhysicalDataUseCase(this.userRepository);

  Future<void> execute(String userId, double? height, double? weight) async {
    await userRepository.updatePhysicalData(userId, height, weight);
  }
}
