import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Analyze waste image to get object name and class
  Future<Map<String, dynamic>> analyzeWaste(Uint8List imageBytes) async {
    if (ApiKeys.geminiApiKey == 'your_api_key_here') {
      throw Exception('กรุณาใส่ Gemini API Key ในไฟล์ lib/config/api_keys.dart ก่อนใช้งานครับ');
    }

    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: ApiKeys.geminiApiKey,
    );

    final prompt = '''คุณคือผู้เชี่ยวชาญด้านการคัดแยกขยะ
    จงวิเคราะห์รูปภาพนี้แล้วบอกว่ามันคือขยะประเภทใด โดยให้ตอบกลับมาเป็น JSON FORMAT เท่านั้น ห้ามมีข้อความอื่นๆ ปนมาเด็ดขาด (ห้ามมี markdown ```json)
    
    รูปแบบ JSON ที่ต้องการ:
    {
      "objectName": "<ชื่อของสิ่งของที่เห็นในภาพ เป็นภาษาไทย>",
      "className": "ขยะอันตราย" | "ขยะทั่วไป" | "ขยะอินทรีย์" | "ขยะรีไซเคิล" | "ไม่ทราบ",
      "description": "<คำอธิบายสั้นๆ ว่ามันคืออะไร และมีข้อแนะนำเบื้องต้นในการทิ้งอย่างไร 1-2 ประโยค>",
      "probability": <ความมั่นใจของตัวเลขระหว่าง 0 ถึง 1>
    }
    
    เกณฑ์การแยกประเภท (ให้ตอบ className เป็นภาษาไทยตามนี้เท่านั้น):
    - ขยะอินทรีย์ (Organic): เศษอาหาร, ใบไม้, ผักผลไม้
    - ขยะรีไซเคิล (Recyclable): ขวดพลาสติกสะอาด, แก้ว, กระดาษ, กระดาษลัง, กระป๋อง
    - ขยะอันตราย (Hazardous): ถ่านไฟฉาย, อุปกรณ์อิเล็กทรอนิกส์, สารเคมี, หลอดไฟ, กระป๋องสเปรย์
    - ขยะทั่วไป (Non-Recyclable): ถุงพลาสติกเปื้อน, กล่องโฟมเปื้อนอาหาร, ทิชชู่ใช้แล้ว, หลอดพลาสติก, เศษขยะทั่วไปที่ไม่สามารถรีไซเคิลได้
    - ไม่ทราบ (Unknown): หากรูปภาพมองไม่ออกว่าเป็นขยะอะไรเลย
    ''';

    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      String text = response.text ?? '{}';
      
      // Clean up markdown if any
      text = text.replaceAll(RegExp(r'```json', caseSensitive: false), '');
      text = text.replaceAll('```', '');
      text = text.trim();

      return jsonDecode(text);
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Generate 1 quiz question based on the object
  Future<Map<String, dynamic>> generateQuiz(String objectName, String className) async {
    if (ApiKeys.geminiApiKey == 'your_api_key_here') {
      throw Exception('กรุณาใส่ Gemini API Key ในไฟล์ lib/config/api_keys.dart ก่อนใช้งานครับ');
    }

    final model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: ApiKeys.geminiApiKey,
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prompt = '''คุณคือผู้สร้างเกมตอบคำถาม (Quiz Master) เกี่ยวกับการจัดการขยะและสิ่งแวดล้อม
    
    ผู้ใช้งานเพิ่งสแกนขยะชิ้นนี้:
    - ชื่อสิ่งของ: "$objectName"
    - หมวดหมู่ขยะ: "$className"
    
    จงสร้างคำถามแบบปรนัย (Multiple Choice) จำนวน 1 ข้อ โดยต้องเจาะจงและเกี่ยวข้องกับสิ่งของชิ้นนี้ ($objectName) เป็นหลัก เช่น วิธีการทิ้งที่ถูกต้อง, การนำมารีไซเคิล, ผลกระทบหากทิ้งผิดวิธี
    
    *คำสั่งสำคัญมาก*: 
    1. ต้องสุ่มคำถามให้ไม่ซ้ำกันเลย (Seed: $timestamp)
    2. คำถามต้องสั้นกระชับที่สุด ไม่เกิน 1-2 ประโยค
    3. ตัวเลือก ก ข ค ง ต้องสั้นกระชับที่สุด (เช่น 1-4 คำ) ห้ามมีคำอธิบายยาวๆ
    
    จงตอบกลับมาเป็น JSON FORMAT เท่านั้น เป็น Object เดียว ห้ามมีข้อความอื่นๆ หรือ markdown ```json ปนมาเด็ดขาด
    
    รูปแบบ JSON ที่ต้องการ:
    {
      "id": 1,
      "question": "<คำถาม>",
      "options": ["<ตัวเลือก ก>", "<ตัวเลือก ข>", "<ตัวเลือก ค>", "<ตัวเลือก ง>"],
      "correctAnswerIndex": <ตัวเลข 0 ถึง 3 ที่เป็นคำตอบที่ถูกต้อง>
    }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      String text = response.text ?? '{}';
      
      // Clean up markdown if any
      text = text.replaceAll(RegExp(r'```json', caseSensitive: false), '');
      text = text.replaceAll('```', '');
      text = text.trim();

      return jsonDecode(text);
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }
}
