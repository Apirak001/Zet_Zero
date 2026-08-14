import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';

class QuizDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final Map<String, dynamic> quizData;

  const QuizDialog({
    Key? key,
    required this.imageBytes,
    required this.quizData,
  }) : super(key: key);

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  int? selectedIndex;
  bool hasAnswered = false;
  Map<String, dynamic>? quizResult;

  @override
  Widget build(BuildContext context) {
    final question = widget.quizData['question'] ?? '';
    final options = List<String>.from(widget.quizData['options'] ?? []);
    final correctIndex = widget.quizData['correctAnswerIndex'] ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Image Preview
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: MemoryImage(widget.imageBytes),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Question Text
            Text(
              'Q1 : $question',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Options
            ...List.generate(options.length, (index) {
              final isSelected = selectedIndex == index;
              final isCorrect = index == correctIndex;
              
              Color buttonColor = const Color(0xFFE8F5E9);
              Color textColor = Colors.black87;

              if (hasAnswered) {
                if (isCorrect) {
                  buttonColor = Colors.green;
                  textColor = Colors.white;
                } else if (isSelected && !isCorrect) {
                  buttonColor = Colors.red;
                  textColor = Colors.white;
                }
              } else if (isSelected) {
                buttonColor = Colors.green[200]!;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasAnswered
                        ? null
                        : () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      options[index],
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            
            // Reward Summary (Show after answering)
            if (hasAnswered && quizResult != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: quizResult!['isCorrect'] ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: quizResult!['isCorrect'] ? Colors.green : Colors.red,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      quizResult!['isCorrect'] ? 'ยอดเยี่ยม! คุณตอบถูก 🎉' : 'เสียใจด้วย คุณตอบผิด 😢',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: quizResult!['isCorrect'] ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                            Text('+${quizResult!['coins']} ฿', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.people, color: quizResult!['isCorrect'] ? Colors.green : Colors.red, size: 24),
                            Text(
                              quizResult!['isCorrect'] ? '+${quizResult!['change']}' : '-${quizResult!['change']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: quizResult!['isCorrect'] ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.cloud, color: quizResult!['isCorrect'] ? Colors.green : Colors.red, size: 24),
                            Text(
                              quizResult!['isCorrect'] ? '-${quizResult!['change']}' : '+${quizResult!['change']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: quizResult!['isCorrect'] ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Submit / Continue Button
            if (!hasAnswered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedIndex == null
                      ? null
                      : () {
                          final isCorrect = selectedIndex == correctIndex;
                          final gameController = Provider.of<GameController>(context, listen: false);
                          
                          setState(() {
                            hasAnswered = true;
                            quizResult = gameController.handleQuizResult(isCorrect);
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue', style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
