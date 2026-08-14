import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';

class QuizView extends StatefulWidget {
  final Uint8List imageBytes;
  final Map<String, dynamic> quizData;

  const QuizView({
    Key? key,
    required this.imageBytes,
    required this.quizData,
  }) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int? selectedIndex;
  bool hasAnswered = false;
  Map<String, dynamic>? quizResult;

  @override
  Widget build(BuildContext context) {
    final question = widget.quizData['question'] ?? '';
    final options = List<String>.from(widget.quizData['options'] ?? []);
    final correctIndex = widget.quizData['correctAnswerIndex'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF8EB89F), // โทนเดียวกับหน้า Login
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                      ),
                      child: const Icon(Icons.close, color: Colors.black, size: 24),
                    ),
                  ),
                  const Text(
                    'Quiz Time!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),

              // Image & Question
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Image
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                          image: DecorationImage(
                            image: MemoryImage(widget.imageBytes),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Question Text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                        ),
                        child: Text(
                          question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Options
                      ...List.generate(options.length, (index) {
                        final isSelected = selectedIndex == index;
                        final isCorrect = index == correctIndex;
                        
                        Color bgColor = Colors.white;
                        Color textColor = Colors.black;

                        if (hasAnswered) {
                          if (isCorrect) {
                            bgColor = Colors.greenAccent;
                          } else if (isSelected && !isCorrect) {
                            bgColor = Colors.redAccent;
                            textColor = Colors.white;
                          }
                        } else if (isSelected) {
                          bgColor = Colors.yellow;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: hasAnswered
                                ? null
                                : () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    offset: isSelected && !hasAnswered ? const Offset(2, 2) : const Offset(4, 4),
                                  )
                                ],
                              ),
                              child: Text(
                                options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: (selectedIndex == null || hasAnswered)
                      ? null
                      : () {
                          final isCorrect = selectedIndex == correctIndex;
                          final gameController = Provider.of<GameController>(context, listen: false);
                          
                          setState(() {
                            hasAnswered = true;
                            quizResult = gameController.handleQuizResult(isCorrect);
                          });
                          
                          // หน่วงเวลาเล็กน้อยให้ผู้ใช้เห็นว่าตัวเลือกไหนถูก/ผิด ก่อนที่ Popup จะเด้ง
                          Future.delayed(const Duration(milliseconds: 1000), () {
                            _showRewardPopup(quizResult!);
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Submit Answer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRewardPopup(Map<String, dynamic> result) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        return ScaleTransition(
          scale: scale,
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result['isCorrect'] ? 'AWESOME! 🎉' : 'OOPS! 😢',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: result['isCorrect'] ? Colors.green : Colors.red,
                        shadows: const [Shadow(color: Colors.black12, offset: Offset(2, 2), blurRadius: 2)],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(Icons.monetization_on, Colors.amber, '+${result['coins']} ฿'),
                        _buildStatItem(Icons.people, Colors.black, result['isCorrect'] ? '+${result['change']}' : '-${result['change']}'),
                        _buildStatItem(Icons.cloud, Colors.black, result['isCorrect'] ? '-${result['change']}' : '+${result['change']}'),
                      ],
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(Colors.grey.shade800),
                        ),
                        child: const Text('Finish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, Color iconColor, String text) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}
