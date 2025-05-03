
import 'package:ai_exercise_tracker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;

  PosePainter({required this.poses, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    final leftPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = AppColors.limeGreen;

    final rightPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = AppColors.purple;

    final jointPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white
          ..strokeWidth = 4.0;

    for (final pose in poses) {
      pose.landmarks.forEach((type, landmark) {
        canvas.drawCircle(
          Offset(landmark.x * scaleX, landmark.y * scaleY),
          6,
          jointPaint,
        );
      });

      // Draw lines connecting the landmarks
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
      );

      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
      );

      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
      );
      _drawLine(
        canvas,
        pose,
        leftPaint,
        rightPaint,
        scaleX,
        scaleY,
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Pose pose,
    Paint leftPaint,
    Paint rightPaint,
    double scaleX,
    double scaleY,
    PoseLandmarkType type1,
    PoseLandmarkType type2,
  ) {
    final PoseLandmark? joint1 = pose.landmarks[type1];
    final PoseLandmark? joint2 = pose.landmarks[type2];

    if (joint1 == null || joint2 == null) return;

    // Determine which paint to use based on left/right side
    Paint paintToUse;
    if (type1.toString().contains('left') ||
        type2.toString().contains('left')) {
      paintToUse = leftPaint;
    } else {
      paintToUse = rightPaint;
    }

    // For lines connecting left and right (like shoulders), use a gradient
    if ((type1.toString().contains('left') &&
            type2.toString().contains('right')) ||
        (type1.toString().contains('right') &&
            type2.toString().contains('left'))) {
      final Rect lineRect = Rect.fromPoints(
        Offset(joint1.x * scaleX, joint1.y * scaleY),
        Offset(joint2.x * scaleX, joint2.y * scaleY),
      );

      final gradient = LinearGradient(
        colors: [AppColors.limeGreen, AppColors.purple],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

      final gradientPaint =
          Paint()
            ..shader = gradient.createShader(lineRect)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

      paintToUse = gradientPaint;
    }

    canvas.drawLine(
      Offset(joint1.x * scaleX, joint1.y * scaleY),
      Offset(joint2.x * scaleX, joint2.y * scaleY),
      paintToUse,
    );
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.poses != poses || oldDelegate.imageSize != imageSize;
  }
}
