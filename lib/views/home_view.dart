import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'scan_view.dart';
import '../services/audio_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    AudioService().playBGM();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. ภาพพื้นหลังเมือง (GIF)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/boomerang.gif',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // เผื่อโหลดภาพไม่ขึ้น จะได้โชว์สีเขียวแทน ไม่ให้แอปพัง
                return Container(color: const Color(0xFF8EB89F));
              },
            ),
          ),

          // 2. HUD ด้านบนสไตล์ Pop-Art
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // แถวบน: Level และ Money
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                        ),
                        child: Text(
                          'LV. ${game.cityLevel}', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                      
                      // Money Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.black, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              '${game.money}', 
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // แถวที่สอง: หลอดสถานะต่างๆ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pollution Bar
                      Expanded(
                        child: _buildPopArtProgressBar(
                          label: 'POLLUTION',
                          icon: Icons.coronavirus,
                          barColor: Colors.redAccent,
                          current: game.pollution,
                          max: game.maxCapacity,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Population Bar
                      Expanded(
                        child: _buildPopArtProgressBar(
                          label: 'POPULATION',
                          icon: Icons.people,
                          barColor: Colors.greenAccent,
                          current: game.population,
                          max: game.maxCapacity,
                        ),
                      ),
                    ],
                  ),
                  
                  // แจ้งเตือน Penalty (ถ้ามี)
                  if (game.pricePenalty > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Text(
                        'WARNING: โดนปรับ +${game.pricePenalty} บาท/ชิ้น!', 
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. ปุ่ม อัปเกรดเมือง (โผล่มาเมื่อครบเงื่อนไข)
          if (game.population == game.maxCapacity && game.cityLevel < 5)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<GameController>().upgradeCity(context);
                    },
                    icon: const Icon(Icons.upgrade, size: 32),
                    label: const Text('UPGRADE CITY!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      side: const BorderSide(color: Colors.black, width: 4),
                      elevation: 0,
                      shadowColor: Colors.black,
                    ).copyWith(
                      elevation: WidgetStateProperty.all(8), // ให้มีเงาลอยๆ
                    ),
                  ),
                ),
              ),
            ),

          // 4. ปุ่ม Scan (ขยับขึ้นหนี Nav Bar แบบ Responsive สำหรับจอยาวๆ)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 110,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanView()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // สีขาวเด่นๆ
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 3), // ขอบดำบางลงนิดนึง
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black, // เงาดำคมๆ สไตล์ Pop-Art
                        offset: Offset(3, 4),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.black, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'SCAN NOW',
                        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopArtProgressBar({
    required String label,
    required IconData icon,
    required Color barColor,
    required int current,
    required int max,
  }) {
    double progress = current / max;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black, size: 16),
              const SizedBox(width: 4),
              Text(
                label, 
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // หลอดพลัง
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(6), // เล็กกว่าขอบนอกนิดนึง
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$current / $max',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}