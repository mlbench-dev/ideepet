import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/lib.dart';
import 'package:lottie/lottie.dart';

import 'box_widget.dart';

class DetectorWidget extends StatefulWidget {
  const DetectorWidget({
    super.key,
    required this.onResult,
    required this.onTakePicture,
  });

  final void Function(List<Recognition>) onResult;
  final void Function(XFile) onTakePicture;

  @override
  State<DetectorWidget> createState() => _DetectorWidgetState();
}

class _DetectorWidgetState extends State<DetectorWidget>
    with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  CameraController? _cameraController;
  get _controller => _cameraController;
  Detector? _detector;
  StreamSubscription? _subscription;

  List<Recognition>? results;

  Map<String, String>? stats;

  bool isTakingPicture = false;
  bool isDetecting = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  var isPressedSound = false.obs;

  static const imageNUmber = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _takePictures() async {
    setState(() {
      isTakingPicture = true;
    });
    if (_cameraController == null || !_controller.value.isInitialized) {
      return;
    }

    for (int i = 0; i < imageNUmber; i++) {
      try {
        final XFile file = await _cameraController!.takePicture();
        widget.onTakePicture(file);
      } catch (e) {
        print('Error taking picture: $e');
      }
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    setState(() {
      isTakingPicture = false;
    });
  }

  void _initStateAsync() async {
    _initializeCamera();

    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        _subscription = instance.resultsStream.stream.listen((values) {
          setState(() {
            results = values['recognitions'];
            stats = values['stats'];
            if (results != null) {
              widget.onResult(results!);
            }
            if (results!.isNotEmpty &&
                (results![0].label.contains('dog') ||
                    results![0].label.contains('cat'))) {
              isDetecting = true;
            } else {
              isDetecting = false;
            }
          });
        });
      });
    });
  }

  void _initializeCamera() async {
    cameras = await availableCameras();

    if (cameras.isEmpty) {
      if (mounted) {
        showError(message: 'Nenhuma câmera disponível neste dispositivo.');
      }
      return;
    }

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});
        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    var aspect = 1 / _controller.value.aspectRatio;

    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Image.asset(
              'assets/onboarding/wallpaper_dog.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        Center(
          child: AspectRatio(
            aspectRatio: aspect,
            child: CameraPreview(_controller),
          ),
        ),
        // Stats
        // _statsWidget(),
        // Bounding boxes
        Center(
          child: AspectRatio(
            aspectRatio: aspect,
            child: _boundingBoxes(),
          ),
        ),
        Center(
          child: Lottie.asset(
            'assets/onboarding_biometric/scan.json',
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 3,
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: !isDetecting ? 0 : 0.6,
            child: Container(
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: isTakingPicture
                  // || !isDetecting
                  ? SizedBox.shrink()
                  : InkWell(
                      onTap: _takePictures,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 10,
                            ),
                          ),
                          child: ClipOval(
                            child: Container(
                              color: Colors.white,
                              child: Center(
                                child: CustomLogo.logoIcon(
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),

        Positioned(
          bottom: 150,
          right: 24,
          child: GestureDetector(
            onTapDown: (_) => startSound(),
            onTapUp: (_) => stopSound(),
            onTapCancel: () => stopSound(),
            child: Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.identity()
                    ..scale(isPressedSound.value ? 1.2 : 1.0),
                  transformAlignment: Alignment.center,
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPressedSound.value
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.9),
                    boxShadow: [
                      if (isPressedSound.value)
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.5),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: isPressedSound.value ? Colors.blue : Colors.black,
                    size: 28,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  void startSound() async {
    isPressedSound.value = true;
    await _audioPlayer.play(AssetSource('sound.mp3'));
  }

  void stopSound() async {
    isPressedSound.value = false;
    await _audioPlayer.stop();
  }

  // Widget _statsWidget() => (stats != null)
  //     ? Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Container(
  //           color: Colors.white.withAlpha(150),
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: stats!.entries
  //                   .map((e) => StatsWidget(e.key, e.value))
  //                   .toList(),
  //             ),
  //           ),
  //         ),
  //       )
  //     : const SizedBox.shrink();

  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }

    return Stack(
        children: results!.map((box) {
      if (box.label.contains('dog') || box.label.contains('cat')) {
        return BoxWidget(result: box);
      }
      return const SizedBox.shrink();
    }).toList());
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Interrompe o stream antes de liberar
    if (_cameraController?.value.isStreamingImages ?? false) {
      _cameraController?.stopImageStream();
    }

    _cameraController?.dispose();
    _cameraController = null;

    _detector?.stop();
    _subscription?.cancel();

    super.dispose();
  }
}
