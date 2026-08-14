import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../controllers/game_controller.dart';
import 'result_view.dart';

class ScanView extends StatefulWidget {
  const ScanView({Key? key}) : super(key: key);

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
      // ถ่ายรูปก่อน
      final XFile file = await _controller!.takePicture();
      // จากนั้นสั่งหยุดภาพให้ค้างไว้
      await _controller!.pausePreview();
      
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

      if (mounted) {
        // นำไปสู่หน้า ResultView ใหม่เต็มจอ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultView(
              imageBytes: imageBytes,
              objectName: result['objectName'] ?? 'Unknown Object',
              className: result['className'] ?? 'Unknown Type',
              description: result['description'] ?? 'No description found.',
              scanCoins: scanCoins,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.resumePreview();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    
    // Fill the square container
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.previewSize?.height ?? 1,
        height: _controller!.value.previewSize?.width ?? 1,
        child: CameraPreview(_controller!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EB89F), // พื้นหลังสีเขียวพาสเทล
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                    ),
                  ),
                  const Text(
                    'Scan Object',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance
                ],
              ),
              const Spacer(flex: 2),
              
              // กล่องกล้องสี่เหลี่ยมสไตล์ Flat Art
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // กล้อง
                      _buildCameraPreview(),
                      
                      // Overlay โหลด
                      if (_isProcessing)
                        Container(
                          color: Colors.white.withOpacity(0.85),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.black, strokeWidth: 4),
                              SizedBox(height: 16),
                              Text(
                                'Processing...',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              const Text(
                'Point the camera at any object to analyze and earn coins!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)],
                ),
              ),
              
              const Spacer(flex: 2),
              
              // แถบปุ่มด้านล่าง
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flashlight
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                      ),
                      child: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  
                  // Capture Button
                  GestureDetector(
                    onTap: _isProcessing ? null : _captureAndAnalyze,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isProcessing ? Colors.grey : const Color(0xFFFF5722), // สีส้มแบบรูปเรฟเฟอเรนซ์
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: _isProcessing ? const Offset(0, 0) : const Offset(4, 4),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  
                  // Empty space for balance (or could be gallery in future)
                  const SizedBox(width: 56), 
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
