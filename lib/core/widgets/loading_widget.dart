import 'package:ai_exercise_tracker/core/constants/assets_paths.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool useAnimation;

  const LoadingWidget({Key? key, this.message, this.useAnimation = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (useAnimation) ...[
            Lottie.asset(
              AssetPaths.loadingAnimPath,
              width: 100,
              height: 100,
              repeat: true,
            ),
          ] else ...[
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
            ),
          ],
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
