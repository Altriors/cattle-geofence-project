import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isStreaming = false;
  String? _error;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isStreaming => _isStreaming;
  String? get error => _error;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _error = 'No cameras available';
        notifyListeners();
        return;
      }

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Camera initialization failed: $e';
      notifyListeners();
    }
  }

  Future<void> startImageStream(
      Function(CameraImage) onFrame) async {
    if (!_isInitialized || _isStreaming) return;
    await _controller?.startImageStream(onFrame);
    _isStreaming = true;
    notifyListeners();
  }

  Future<void> stopImageStream() async {
    if (!_isStreaming) return;
    await _controller?.stopImageStream();
    _isStreaming = false;
    notifyListeners();
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized) return null;
    try {
      return await _controller!.takePicture();
    } catch (e) {
      _error = 'Failed to capture image: $e';
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}