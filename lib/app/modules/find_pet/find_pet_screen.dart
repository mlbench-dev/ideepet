import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';
import 'package:idee_pet/app/core/core_old/widgets/oval_outline.dart';
import 'package:idee_pet/app/core/core_old/widgets/svgs.dart';
import 'package:idee_pet/app/core/helpers/messages.dart';
import 'package:idee_pet/app/core/services/navigation_service.dart';
import 'package:idee_pet/app/modules/find_pet_result/repository/find_pet_entity.dart';
import 'package:idee_pet/app/modules/find_pet_result/repository/find_pet_result_repository.dart';
import 'package:idee_pet/app/routes/find_pet_result_routes.dart';
import 'package:video_player/video_player.dart';

/// Screen used to scan a pet's muzzle in order to FIND a pet
/// (previously this screen was used to REGISTER a pet's biometrics).
/// The network/API upload call has been removed — only the camera +
/// 5-second hold-to-record logic remains.
class PetFindScanning extends StatefulWidget {
  const PetFindScanning({super.key});

  @override
  State<PetFindScanning> createState() => _PetFindScanningState();
}

class _PetFindScanningState extends State<PetFindScanning>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final _findPetResultRepository = FindPetResultRepository();

  /// "dog" or "cat", chosen in the pet type dialog before this screen.
  final String? _petType = (Get.arguments as Map?)?['pet'] as String?;
  bool _isIdentifying = false;

  @override
  void initState() {
    super.initState();
    // FindPetResultRepository is a plain GetConnect, not injected through a
    // GetX binding here, so its onInit() (which sets httpClient.baseUrl)
    // must be triggered manually — otherwise requests fail with
    // "No host specified in URI".
    _findPetResultRepository.onInit();
    WidgetsBinding.instance.addObserver(this);
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

  /// Called when the user taps the checkmark after recording.
  /// Scans the recorded video and, once the API call resolves, navigates to
  /// the "find pet result" screen to show whether the pet was found.
  Future<void> _onTickPressed() async {
    final video = _recordedVideo;
    if (video == null) return;

    final result = await _identifyPet(video);

    if (!mounted) return;

    if (result == null) {
      // Detection failed — restore the live camera feed so the user can
      // record and retry instead of seeing a blank/white video preview.
      await _retryRecording();
      return;
    }

    Get.find<NavigationService>().toNamed(
      FindPetResultRoutes.findPetResult,
      arguments: {'result': result},
    );
  }

  /// Sends the recorded muzzle video to the public "found pet" scan
  /// endpoint (POST /pets/identify_pet/) and returns the matched
  /// [FindPetResult], if any. Does not affect the existing camera /
  /// recording logic above.
  Future<FindPetResult?> _identifyPet(File video) async {
    if (_isIdentifying) return null;

    setState(() => _isIdentifying = true);

    try {
      final response = await _findPetResultRepository.identifyPetByVideo(
        video,
        pet: _petType,
      );

      // Prefer the message sent by the backend; the hardcoded texts are
      // only a fallback when the response carries none.
      final backendMessage = response.errorMessages.isNotEmpty
          ? response.errorMessages.first.toString()
          : response.result?.message;

      if (!response.success) {
        showError(message: backendMessage ?? 'Erro ao identificar o pet.');
        return null;
      }

      final result = response.result;
      if (result != null && result.exists) {
        showSuccess(
          message: backendMessage ?? 'Pet encontrado: ${result.petName ?? ''}',
        );
      } else {
        showInfo(
          message:
              backendMessage ?? 'Nenhum pet correspondente foi encontrado.',
        );
      }

      return result;
    } finally {
      if (mounted) setState(() => _isIdentifying = false);
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
                    "Encontrar Pet",
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
                      "Posicione o focinho do pet dentro da área indicada e \ntoque para gravar por até 5 segundos.",
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
          if (_isIdentifying)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
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
