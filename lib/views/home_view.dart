import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'login_view.dart';

import 'scan_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. ภาพพื้นหลังเมือง
          Container(
            color: const Color(0xFF8EB89F),
            width: double.infinity,
            height: double.infinity,
          ),

          // 2. แถบสถานะด้านบน (HUD)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // หลอดมลพิษ (Pollution)
                      _buildProgressBar(
                        label: 'POLLUTION',
                        icon: Icons.coronavirus,
                        iconColor: Colors.red,
                        barColor: Colors.red,
                        progress: game.pollution / game.maxCapacity,
                      ),
                      
                      // เหรียญและเลเวล
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.money, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text('${game.money}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('LV. ${game.cityLevel}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      // หลอดประชากร (Population)
                      _buildProgressBar(
                        label: 'POPULATION',
                        icon: Icons.people,
                        iconColor: Colors.green,
                        barColor: Colors.green,
                        progress: game.population / game.maxCapacity,
                      ),
                    ],
                  ),
                  
                  // Text แสดงสถานะ
                  const SizedBox(height: 8),
                  Text('Pollution: ${game.pollution} / ${game.maxCapacity}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('Population: ${game.population} / ${game.maxCapacity}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  if (game.pricePenalty > 0)
                    Text('Penalty: +${game.pricePenalty} บาท', style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // ปุ่ม อัปเกรดเมือง
          if (game.population == game.maxCapacity && game.cityLevel < 5)
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<GameController>().upgradeCity(context);
                  },
                  icon: const Icon(Icons.upgrade, size: 28),
                  label: const Text('อัปเกรดเมือง!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ),

          // 3. เมนูด้านขวา
          Positioned(
            right: 16,
            top: 200,
            child: Column(
              children: [
                _buildSideButton(Icons.calendar_today, () {}),
                const SizedBox(height: 16),
                _buildSideButton(Icons.settings, () => _showSettingsPopup(context)),
                const SizedBox(height: 16),
                _buildSideButton(Icons.inventory, () => _showInventoryPopup(context)), // ปุ่มคลังอุปกรณ์
              ],
            ),
          ),

          // ปุ่มทดสอบระบบ
          Positioned(
            left: 16,
            top: 200,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => context.read<GameController>().addMoney(1000),
                  child: const Text('+1000฿'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<GameController>().addMoney(-500),
                  child: const Text('-500฿'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => context.read<GameController>().increasePollution(50, context),
                  child: const Text('+มลพิษ 50', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // 4. ปุ่ม Scan
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanView()),
                  );
                },
                icon: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                label: const Text(
                  'Scan...',
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AC4F3),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE8ECD6),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: (index) {
          if (index == 0) {
            _showShopPopup(context);
          } else if (index == 2) {
            _showRankPopup(context);
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront, size: 30), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 30), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard, size: 30), label: 'Rank'),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color barColor,
    required double progress,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F4E6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF5A4D4D)),
        onPressed: onPressed,
      ),
    );
  }
}

void _showSettingsPopup(BuildContext context) {
  bool isSoundOn = true;
  bool isMusicOn = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1EC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'การตั้งค่า',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2)],
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 2, height: 20),
                  const SizedBox(height: 10),

                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.volume_up, color: Colors.black),
                            SizedBox(width: 8),
                            Text('เสียงประกอบ', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Switch(
                          value: isSoundOn,
                          onChanged: (val) {
                            setState(() {
                              isSoundOn = val;
                            });
                          },
                          activeColor: Colors.black,
                          activeTrackColor: Colors.green,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.music_note, color: Colors.black),
                            SizedBox(width: 8),
                            Text('ดนตรี', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Switch(
                          value: isMusicOn,
                          onChanged: (val) {
                            setState(() {
                              isMusicOn = val;
                            });
                          },
                          activeColor: Colors.black,
                          inactiveThumbColor: Colors.black,
                          inactiveTrackColor: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginView()),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('ออกจากระบบ', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      );
    },
  );
}

void _showInventoryPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final game = context.watch<GameController>();
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1EC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('คลังอุปกรณ์', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black, thickness: 2, height: 20),
              
              _buildInventoryItem(Icons.delete_outline, Colors.brown, 'ถังขยะ', 'x${game.inventoryCounts[0]}', Colors.red.shade900),
              _buildInventoryItem(Icons.local_shipping, Colors.blue.shade800, 'รถขนส่ง', 'x${game.inventoryCounts[3]}', Colors.blue.shade900),
              _buildInventoryItem(Icons.person, Colors.green.shade800, 'คนงาน', 'x${game.inventoryCounts[2]}', Colors.greenAccent.shade700),
              _buildInventoryItem(Icons.recycling, Colors.orange.shade800, 'จุดคัดแยก', 'x${game.inventoryCounts[1]}', Colors.orange),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildInventoryItem(IconData icon, Color iconColor, String title, String countText, Color countBgColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black, width: 2),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: countBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(countText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

void _showShopPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ShopDialog();
    },
  );
}

class ShopDialog extends StatefulWidget {
  const ShopDialog({Key? key}) : super(key: key);

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> {
  int _selectedTab = 1;

  @override
  void initState() {
    super.initState();
    _selectedTab = context.read<GameController>().cityLevel;
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1B1B5C), width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text('${game.money}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Text('SHOP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Level Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                int level = index + 1;
                bool isUnlocked = level <= game.cityLevel;
                bool isSelected = _selectedTab == level;
                return GestureDetector(
                  onTap: () {
                    if (isUnlocked) {
                      setState(() {
                        _selectedTab = level;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ต้องอัปเกรดเมืองเป็นเลเวล $level ก่อน!')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade900 : (isUnlocked ? Colors.red.shade300 : Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('LV. $level', style: TextStyle(
                      color: isSelected ? Colors.white : (isUnlocked ? Colors.white70 : Colors.white30), 
                      fontSize: 12, fontWeight: FontWeight.bold
                    )),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Items List
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  var item = game.getItemsForLevel(_selectedTab)[index];
                  int price = game.getPrice(item);
                  int reduction = game.getActualReduction(item);
                  bool canAfford = game.money >= price;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                          child: _getIconForCategory(item.categoryIndex),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('ลดมลพิษ -$reduction', style: const TextStyle(fontSize: 10, color: Colors.blue)),
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text('$price', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canAfford ? () => context.read<GameController>().buyItem(_selectedTab, index, context) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canAfford ? Colors.green.shade800 : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('ซื้อ', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForCategory(int category) {
    switch (category) {
      case 0: return const Icon(Icons.delete_outline, color: Colors.brown);
      case 1: return const Icon(Icons.recycling, color: Colors.orange);
      case 2: return const Icon(Icons.person, color: Colors.green);
      case 3: return const Icon(Icons.local_shipping, color: Colors.blue);
      default: return const Icon(Icons.star);
    }
  }
}

void _showRankPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF00FF00), width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  const Text('LEADER BOARD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildRankItem(1, 'สมชาย ใจดี', 10, 15400, Colors.greenAccent.shade400, Colors.black),
                    _buildRankItem(2, 'มานะ มานี', 10, 12200, Colors.green.shade400, Colors.black),
                    _buildRankItem(3, 'ก้องเกียรติ', 9, 10800, Colors.pink.shade100, Colors.black),
                    _buildRankItem(4, 'น้ำแข็งใส', 6, 9500, Colors.grey.shade200, Colors.black87),
                    _buildRankItem(5, 'พริกแกง', 5, 8900, Colors.grey.shade200, Colors.black87),
                    _buildRankItem(6, 'น้ำชา', 3, 7500, Colors.grey.shade200, Colors.black87),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Column(
                      children: const [
                        Text('RANK', style: TextStyle(color: Colors.white, fontSize: 10)),
                        Text('100', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green.shade600,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('คุณ (YOU)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Level 1', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Text('1,240', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRankItem(int rank, String name, int level, int pts, Color bgColor, Color textColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        SizedBox(width: 30, child: Text(rank.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))),
        CircleAvatar(radius: 18, backgroundColor: Colors.white54, child: Icon(Icons.face, color: Colors.grey.shade600)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Level $level', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(pts.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('PTS', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ],
    ),
  );
}