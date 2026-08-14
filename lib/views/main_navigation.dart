import 'package:flutter/material.dart';
import 'home_view.dart';
import 'store_view.dart';
import 'rank_view.dart';
import 'profile_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeView(), // หน้าเมือง
    StoreView(),
    RankView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EB89F), // เผื่อไว้เวลากลืนกัน
      body: Stack(
        children: [
          // หน้าเนื้อหา สลับไปมาสมูทๆ
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _pages[_currentIndex], // widget.key จำเป็นถ้าชนิด widget ซ้ำกัน แต่เรามีคนละ class
          ),

          // แถบเมนูด้านล่างแบบแคปซูลลอย
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black, // สีแคปซูลตามเรฟเฟอเรนซ์
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated sliding background
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment(-1.0 + (_currentIndex * (2.0 / 3.0)), 0),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(icon: Icons.home_rounded, index: 0),
                      _buildNavItem(icon: Icons.storefront_rounded, index: 1),
                      _buildNavItem(icon: Icons.emoji_events_rounded, index: 2),
                      _buildNavItem(icon: Icons.person_rounded, index: 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey.shade400,
            size: 28,
          ),
        ),
      ),
    );
  }
}
