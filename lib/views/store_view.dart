import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';

class StoreView extends StatefulWidget {
  const StoreView({Key? key}) : super(key: key);

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  int _selectedTab = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedTab = context.read<GameController>().cityLevel;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();

    return Scaffold(
      backgroundColor: const Color(0xFF8EB89F), // สีพื้นเขียวพาสเทล
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber, 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))]
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, size: 20, color: Colors.black),
                          const SizedBox(width: 6),
                          Text('${game.money}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    ),
                    const Text('STORE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 24),
                
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
                            SnackBar(
                              content: Text('ต้องอัปเกรดเมืองเป็นเลเวล $level ก่อน!', style: const TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : (isUnlocked ? Colors.white : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            if (isSelected) const BoxShadow(color: Colors.black26, offset: Offset(2, 2))
                          ],
                        ),
                        child: Text('LV. $level', style: TextStyle(
                          color: isSelected ? Colors.white : (isUnlocked ? Colors.black : Colors.grey), 
                          fontSize: 14, fontWeight: FontWeight.w900
                        )),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

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
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100, 
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: _getIconForCategory(item.categoryIndex),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('ลดมลพิษ -$reduction', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on, size: 16, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text('$price ฿', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: canAfford ? () => context.read<GameController>().buyItem(_selectedTab, index, context) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? Colors.black : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                elevation: 0,
                              ),
                              child: const Text('ซื้อ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
        ),
      ),
    );
  }

  Widget _getIconForCategory(int category) {
    switch (category) {
      case 0: return const Icon(Icons.delete_outline, color: Colors.brown, size: 32);
      case 1: return const Icon(Icons.recycling, color: Colors.orange, size: 32);
      case 2: return const Icon(Icons.person, color: Colors.green, size: 32);
      case 3: return const Icon(Icons.local_shipping, color: Colors.blue, size: 32);
      default: return const Icon(Icons.star, size: 32);
    }
  }
}
