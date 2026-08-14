import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../controllers/game_controller.dart';
import 'widgets/result_dialog.dart';
import 'widgets/quiz_dialog.dart';

class ScanView extends StatefulWidget {
  const ScanView({Key? key}) : super(key: key);

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile file = await _controller!.takePicture();
      final Uint8List imageBytes = await file.readAsBytes();

      // Call Gemini API
      final aiService = AiService();
      final result = await aiService.analyzeWaste(imageBytes);

      int scanCoins = 0;
      if (mounted) {
        final gameController = Provider.of<GameController>(context, listen: false);
        scanCoins = gameController.addRandomCoins();
      }

      setState(() {
        _isProcessing = false;
      });

      // Show Result Dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ResultDialog(
            imageBytes: imageBytes,
            objectName: result['objectName'] ?? 'ไม่ทราบชื่อ',
            className: result['className'] ?? 'ไม่ทราบ',
            description: result['description'] ?? 'ไม่พบคำอธิบายเพิ่มเติมสำหรับสิ่งนี้',
            scanCoins: scanCoins,
            onCollect: () => _generateAndShowQuiz(
              imageBytes,
              result['objectName'] ?? 'ไม่ทราบชื่อ',
              result['className'] ?? 'ไม่ทราบ',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _generateAndShowQuiz(Uint8List imageBytes, String objectName, String className) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final aiService = AiService();
      final quizData = await aiService.generateQuiz(objectName, className);

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => QuizDialog(
            imageBytes: imageBytes,
            quizData: quizData,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final frameSize = size.width * 0.7; // กรอบกว้าง 70% ของหน้าจอ

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview (Full Screen)
          Positioned.fill(
            child: _buildCameraPreview(),
          ),
          
          // Custom Overlay (Scanner Frame)
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.15),
                  // Frame Container
                  SizedBox(
                    width: frameSize,
                    height: frameSize,
                    child: Stack(
                      children: [
                        // Corners
                        Align(alignment: Alignment.topLeft, child: _buildCorner()),
                        Align(alignment: Alignment.topRight, child: RotatedBox(quarterTurns: 1, child: _buildCorner())),
                        Align(alignment: Alignment.bottomRight, child: RotatedBox(quarterTurns: 2, child: _buildCorner())),
                        Align(alignment: Alignment.bottomLeft, child: RotatedBox(quarterTurns: 3, child: _buildCorner())),
                        
                        // Scanner Animation Laser
                        if (!_isProcessing)
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Positioned(
                                top: _animationController.value * (frameSize - 4),
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.cyanAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.8),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Flashlight & Capture Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 50), // spacer
                        // Capture Button
                        GestureDetector(
                          onTap: _isProcessing ? null : _captureAndAnalyze,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: _isProcessing ? Colors.grey.withOpacity(0.5) : Colors.white.withOpacity(0.3),
                            ),
                            child: const Center(
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // Flashlight Toggle
                        GestureDetector(
                          onTap: _toggleFlash,
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Processing Overlay (แบบกึ่งโปร่งใส ไม่บังกล้องมิด)
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.6), // เปลี่ยนให้เห็นภาพกล้องอยู่บ้าง
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.cyanAccent),
                    SizedBox(height: 20),
                    Text(
                      'กำลังใช้ AI วิเคราะห์...',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white, width: 6),
          left: BorderSide(color: Colors.white, width: 6),
        ),
      ),
    );
  }
}
