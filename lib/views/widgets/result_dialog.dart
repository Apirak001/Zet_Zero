import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final Uint8List imageBytes;
  final String objectName;
  final String className;
  final String description;
  final int scanCoins;
  final VoidCallback onCollect;

  const ResultDialog({
    Key? key,
    required this.imageBytes,
    required this.objectName,
    required this.className,
    required this.description,
    required this.scanCoins,
    required this.onCollect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กำหนดสีพื้นหลังและสีข้อความตามประเภทขยะ
    Color headerColor;
    switch (className) {
      case 'ขยะอินทรีย์':
        headerColor = Colors.green;
        break;
      case 'ขยะรีไซเคิล':
        headerColor = Colors.yellow[700]!;
        break;
      case 'ขยะอันตราย':
        headerColor = Colors.red;
        break;
      case 'ขยะทั่วไป':
        headerColor = Colors.blue;
        break;
      default:
        headerColor = Colors.grey;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
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
                  radius: 14,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Image Preview 
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                image: DecorationImage(
                  image: MemoryImage(imageBytes),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // ข้อมูลการสแกน (หัวข้อที่จัดเรียงอ่านง่าย)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ประเภท:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          className, 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: headerColor),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('รายละเอียด:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          objectName,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Reward Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('รางวัลสแกนสำเร็จ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                      Text('+$scanCoins บาท', style: const TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Button (ตอบแบบสอบถาม)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCollect();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), // สีน้ำเงินเข้มดูเป็นทางการ
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  'ตอบแบบสอบถาม', 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
