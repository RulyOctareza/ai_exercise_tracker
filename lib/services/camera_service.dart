import 'package:camera/camera.dart';
import 'package:get/get.dart';

class CameraService extends GetxService {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  final isInitialized = false.obs;
  final isProcessing = false.obs;

  CameraController? get cameraController => _cameraController;

  Future<CameraService> init() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException(
          'No cameras available',
          'No cameras found on device',
        );
      }

      // Initialize with front camera first for better pose detection
      await _initializeCameraController(
        _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        ),
      );

      isInitialized.value = true;
      return this;
    } on CameraException catch (e) {
      print('Error initializing camera: ${e.code}, ${e.description}');
      return this;
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _cameraController!.initialize();
    } on CameraException catch (e) {
      print(
        'Error initializing camera controller: ${e.code}, ${e.description}',
      );
      rethrow;
    }
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!isInitialized.value ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    if (_cameraController!.value.isStreamingImages) {
      return;
    }

    try {
      await _cameraController!.startImageStream((image) {
        if (!isProcessing.value) {
          isProcessing.value = true;
          onImage(image);
        }
      });
    } on CameraException catch (e) {
      print('Error starting image stream: ${e.code}, ${e.description}');
    }
  }

  void processingDone() {
    isProcessing.value = false;
  }

  Future<void> stopImageStream() async {
    if (_cameraController == null ||
        !_cameraController!.value.isStreamingImages) {
      return;
    }

    try {
      await _cameraController!.stopImageStream();
    } on CameraException catch (e) {
      print('Error stopping image stream: ${e.code}, ${e.description}');
    }
  }

  void toggleCameraDirection() async {
    if (_cameras.length < 2) return;

    final currentDirection = _cameraController?.description.lensDirection;
    final newDirection =
        currentDirection == CameraLensDirection.front
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    final newCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == newDirection,
      orElse: () => _cameras.first,
    );

    await _initializeCameraController(newCamera);
    isInitialized.value = true;
  }

  @override
  void onClose() {
    stopImageStream();
    _cameraController?.dispose();
    super.onClose();
  }
}
