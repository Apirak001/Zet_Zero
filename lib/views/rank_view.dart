import 'package:flutter/material.dart';

class RankView extends StatelessWidget {
  const RankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EB89F), // สีเดียวกับธีมหลัก
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: MediaQuery.of(context).padding.bottom + 110),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.emoji_events, color: Colors.black, size: 28),
                    ),
                    const Text('LEADERBOARD', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 24),

                // Rank List
                Expanded(
                  child: ListView(
                    children: [
                      _buildRankItem(1, 'สมชาย ใจดี', 10, 15400, Colors.yellow.shade400, Colors.black),
                      _buildRankItem(2, 'มานะ มานี', 10, 12200, Colors.grey.shade300, Colors.black),
                      _buildRankItem(3, 'ก้องเกียรติ', 9, 10800, Colors.orange.shade300, Colors.black),
                      _buildRankItem(4, 'น้ำแข็งใส', 6, 9500, Colors.white, Colors.black),
                      _buildRankItem(5, 'พริกแกง', 5, 8900, Colors.white, Colors.black),
                      _buildRankItem(6, 'น้ำชา', 3, 7500, Colors.white, Colors.black),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current User Rank
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: const [
                          Text('RANK', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('100', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.green.shade600,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('คุณ (YOU)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                            Text('Level 1', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Text('1,240', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankItem(int rank, String name, int level, int pts, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36, 
            child: Text('#$rank', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18))
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 18, 
              backgroundColor: Colors.white, 
              child: Icon(Icons.face, color: Colors.grey.shade800)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16)),
                Text('Level $level', style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pts.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18)),
              Text('PTS', style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
