import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_prefs.dart';
import 'welcome_view.dart';
import 'main_navigation.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  int _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // เพิ่มค่า progress ทุกๆ 30 มิลลิวินาที
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progress < 100) {
          _progress++;
        } else {
          _timer?.cancel();
          // เปลี่ยนหน้าไปตามสถานะ Login เมื่อครบ 100%
          _checkLoginStatusAndNavigate();
        }
      });
    });
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final bool rememberMe = await LocalPrefs.getRememberMe();
      final int? loginTimestamp = await LocalPrefs.getLoginTimestamp();
      
      bool shouldLogout = false;

      if (!rememberMe) {
        shouldLogout = true;
      } else if (loginTimestamp != null) {
        final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
        final now = DateTime.now();
        final difference = now.difference(loginTime);
        if (difference.inHours >= 24) { // พ้น 1 วันให้ Logout
          shouldLogout = true;
        }
      }

      if (shouldLogout) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeView()),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeView()),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // สีพื้นหลังขาวอมเทานิดๆ
      body: SafeArea(
        child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // วงกลมโลโก้
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade900, width: 3),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.delete_outline_rounded, // ไอคอนจำลองแทนถังขยะ
                    size: 80,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ข้อความ ZET ZERO
              const Text(
                'ZET ZERO',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // โทนสีเขียว
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              // แถบสถานะการโหลด
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'INITIALISING...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$_progress%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // หลอดโหลด (Progress Bar)
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade900, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: _progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 100 - _progress,
                      child: Container(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
