import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';
import 'package:idee_pet/app/core/core_old/widgets/oval_outline.dart';
import 'package:idee_pet/app/core/core_old/widgets/svgs.dart';
import 'package:idee_pet/app/core/helpers/messages.dart';
import 'package:idee_pet/app/modules/biometric/biometric_controller.dart';
import 'package:video_player/video_player.dart';

class BiometicScanning extends StatefulWidget {
  const BiometicScanning({super.key});

  @override
  State<BiometicScanning> createState() => _BiometicScanningState();
}

class _BiometicScanningState extends State<BiometicScanning>
    with WidgetsBindingObserver {
  final BiometricController controller = Get.find<BiometricController>();

  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.wakeUpCvServer();
    _initializeCamera();
  }

  bool _isInitializingCamera = false;

  Future<void> _initializeCamera() async {
    // Lifecycle events can fire in quick succession (e.g. inactive → resumed
    // when the screen wakes); avoid opening the camera twice.
    if (_isInitializingCamera) return;
    _isInitializingCamera = true;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted) {
          showError(message: 'Nenhuma câmera disponível neste dispositivo.');
        }
        return;
      }

      final cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await cameraController.initialize();
      } catch (e) {
        debugPrint('Error initializing camera: $e');
        await cameraController.dispose();
        return;
      }

      // The app may have gone to background again while initializing.
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (!mounted ||
          (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
        await cameraController.dispose();
        return;
      }

      setState(() => _cameraController = cameraController);
    } finally {
      _isInitializingCamera = false;
    }
  }

  /// Releases the camera so it isn't held while the app is in background.
  /// Clears the reference *before* disposing so the preview never builds
  /// with a disposed controller (which renders as a blank white screen).
  Future<void> _releaseCamera() async {
    final cameraController = _cameraController;
    if (cameraController == null) return;

    if (cameraController.value.isRecordingVideo) {
      await _cancelVideoRecording();
    }

    if (mounted) {
      setState(() => _cameraController = null);
    } else {
      _cameraController = null;
    }
    await cameraController.dispose();
  }

  bool _isRecording = false;
  File? _recordedVideo;
  VideoPlayerController? _videoController;

  Future<void> _beginVideoRecording() async {
    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized || cam.value.isRecordingVideo) {
      return;
    }

    try {
      await cam.startVideoRecording();
      if (mounted) setState(() => _isRecording = true);
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<void> _cancelVideoRecording() async {
    final cam = _cameraController;
    if (cam == null || !cam.value.isRecordingVideo) return;

    try {
      final file = await cam.stopVideoRecording();
      await File(file.path).delete();
    } catch (e) {
      debugPrint('Error cancelling video recording: $e');
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _finishVideoRecording() async {
    final cam = _cameraController;
    if (cam == null || !cam.value.isRecordingVideo) return;

    try {
      final file = await cam.stopVideoRecording();
      final videoFile = File(file.path);
      final videoController = VideoPlayerController.file(videoFile);
      await videoController.initialize();
      await videoController.setLooping(true);
      await videoController.play();

      if (!mounted) {
        await videoController.dispose();
        return;
      }

      setState(() {
        _isRecording = false;
        _recordedVideo = videoFile;
        _videoController = videoController;
      });
    } catch (e) {
      debugPrint('Error finishing video recording: $e');
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _onTickPressed() async {
    final video = _recordedVideo;
    if (video == null) return;

    final success = await controller.sendBiometryVideo(video);

    if (!mounted) return;

    if (success) {
      controller.goToSuccessScreen();
    } else {
      await _retryRecording();
    }
  }

  Future<void> _retryRecording() async {
    final oldVideoController = _videoController;
    final oldRecordedVideo = _recordedVideo;

    setState(() {
      _videoController = null;
      _recordedVideo = null;
    });

    await oldVideoController?.dispose();
    if (oldRecordedVideo != null && await oldRecordedVideo.exists()) {
      await oldRecordedVideo.delete();
    }

    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized) {
      await _initializeCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      await _videoController?.pause();
      await _releaseCamera();
    } else if (state == AppLifecycleState.resumed) {
      // Note: the controller is null here (released on pause), so this must
      // not bail out on a missing controller, or the camera never restarts.
      if (_recordedVideo == null) {
        if (_cameraController == null) await _initializeCamera();
      } else {
        await _videoController?.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: AppColors.greyWhite,
            child: Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _videoController != null && _videoController!.value.isInitialized
              ? _RecordedVideoPreview(controller: _videoController!)
              : _CameraPreviewBackground(cameraController: _cameraController),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Positioned(
                      child: Text(
                    "Reconhecimento",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                        color: AppColors.primary),
                  )),
                  Positioned(
                    top: 45,
                    left: 0,
                    right: 0,
                    child: Text(
                      textAlign: TextAlign.start,
                      maxLines: 2,
                      "Posicione o focinho dentro da área indicada e \ntoque para gravar por até 5 segundos.",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          color: AppColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: _HoldToScanControls(
              recordDuration: const Duration(seconds: 5),
              isCapturing: _isRecording,
              hasRecordedVideo: _recordedVideo != null,
              onHoldStart: _beginVideoRecording,
              onHoldCancel: _cancelVideoRecording,
              onHoldComplete: _finishVideoRecording,
              onTickTap: _onTickPressed,
              onRetry: _retryRecording,
            ),
          ),
          Obx(
            () => controller.isUploadingBiometry.isTrue
                ? Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          'Processando...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewBackground extends StatelessWidget {
  const _CameraPreviewBackground({required this.cameraController});

  final CameraController? cameraController;

  @override
  Widget build(BuildContext context) {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _RecordedVideoPreview extends StatelessWidget {
  const _RecordedVideoPreview({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _HoldToScanControls extends StatefulWidget {
  const _HoldToScanControls({
    required this.recordDuration,
    required this.onHoldStart,
    required this.onHoldCancel,
    required this.onHoldComplete,
    this.isCapturing = false,
    this.hasRecordedVideo = false,
    this.onTickTap,
    this.onRetry,
  });

  final Duration recordDuration;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldCancel;
  final VoidCallback onHoldComplete;
  final bool isCapturing;
  final bool hasRecordedVideo;
  final VoidCallback? onTickTap;
  final VoidCallback? onRetry;

  @override
  State<_HoldToScanControls> createState() => _HoldToScanControlsState();
}

class _HoldToScanControlsState extends State<_HoldToScanControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.recordDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _finishRecording();
        }
      });
  }

  @override
  void didUpdateWidget(covariant _HoldToScanControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recording was stopped from outside (e.g. the app went to background):
    // reset the progress ring so it doesn't keep animating.
    // No setState needed: build() runs right after didUpdateWidget.
    if (oldWidget.isCapturing && !widget.isCapturing && _isRecording) {
      _isRecording = false;
      _controller.stop();
      _controller.reset();
    }
  }

  void _startRecording() {
    if (_isRecording || widget.isCapturing || widget.hasRecordedVideo) return;
    setState(() => _isRecording = true);
    _controller.forward(from: 0);
    widget.onHoldStart();
  }

  /// Stops recording and keeps the video — triggered either by a second tap
  /// (manual stop) or by the ring animation completing (5s auto-stop).
  void _finishRecording() {
    if (!_isRecording) return;
    _resetRingState();
    widget.onHoldComplete();
  }

  void _resetRingState() {
    if (!_isRecording) return;
    setState(() => _isRecording = false);
    _controller.stop();
    _controller.reset();
  }

  void _handleTap() {
    if (widget.hasRecordedVideo) {
      widget.onTickTap?.call();
      return;
    }
    if (_isRecording) {
      _finishRecording();
    } else {
      _startRecording();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 125,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoredBox(
                  color: AppColors.primary,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Segure firme · 5s",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: OvalOutline(
                width: 230,
                height: 302,
                child: CustomLogo.logoOutline(height: 130, width: 130),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _handleTap,
                child: SizedBox(
                  height: 96,
                  width: 96,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 96,
                          width: 96,
                          child: CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 14,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.red),
                          ),
                        ),
                        child!,
                      ],
                    ),
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: ClipOval(
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: widget.hasRecordedVideo
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.green,
                                    size: 34,
                                  )
                                : CustomLogo.logoIcon(height: 30, width: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          widget.hasRecordedVideo
              ? Positioned(
                  bottom: 100,
                  left: 160,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onRetry,
                    child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                        ),
                        child: Icon(Icons.refresh)),
                  ))
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
