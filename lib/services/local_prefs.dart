import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';

/// Helper class สำหรับเก็บข้อมูล "จดจำฉัน" ลงไฟล์ธรรมดา
/// ใช้แทน shared_preferences เพราะ shared_preferences มีปัญหา
/// Kotlin compile ข้ามไดรฟ์บน Windows
class LocalPrefs {
  static const String _fileName = 'app_prefs.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<Map<String, dynamic>> _readAll() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  /// บันทึกสถานะ "จดจำฉัน" พร้อม timestamp
  static Future<void> setRememberMe(bool value) async {
    if (kIsWeb) return;
    final data = await _readAll();
    data['rememberMe'] = value;
    if (value) {
      data['loginTimestamp'] = DateTime.now().millisecondsSinceEpoch;
    } else {
      data.remove('loginTimestamp');
    }
    await _writeAll(data);
  }

  /// ดึงสถานะ "จดจำฉัน"
  static Future<bool> getRememberMe() async {
    if (kIsWeb) return false;
    final data = await _readAll();
    return data['rememberMe'] == true;
  }

  /// ดึง timestamp ตอนล็อกอิน
  static Future<int?> getLoginTimestamp() async {
    if (kIsWeb) return null;
    final data = await _readAll();
    return data['loginTimestamp'] as int?;
  }

  /// ลบข้อมูลทั้งหมด
  static Future<void> clear() async {
    if (kIsWeb) return;
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
