import 'package:flutter/material.dart';
import 'dart:math';

class ShopItem {
  final String id;
  final String name;
  final int basePrice;
  final int baseReduction;
  final int categoryIndex;

  ShopItem({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.baseReduction,
    required this.categoryIndex,
  });
}

class GameController extends ChangeNotifier {
  int _cityLevel = 1;
  int _money = 5000; // เริ่มต้นมีเงินให้เทสหน่อย
  int _pollution = 50;
  int _population = 50;
  int _pricePenalty = 0;

  // Track purchases for diminishing returns
  final Map<String, int> _itemPurchaseCount = {};
  
  // Track inventory (0: Bins, 1: Stations, 2: Workers, 3: Trucks)
  final List<int> _inventoryCounts = [0, 0, 0, 0];

  final List<int> _maxCapacities = [100, 500, 1000, 1300, 1500];

  int get cityLevel => _cityLevel;
  int get money => _money;
  int get pollution => _pollution;
  int get population => _population;
  int get pricePenalty => _pricePenalty;
  int get maxCapacity => _maxCapacities[_cityLevel - 1];
  List<int> get inventoryCounts => _inventoryCounts;

  // Item Definitions
  final List<List<ShopItem>> _shopItems = [
    // Level 1
    [
      ShopItem(id: 'lv1_1', name: 'ถังขยะธรรมดา', basePrice: 100, baseReduction: 5, categoryIndex: 0),
      ShopItem(id: 'lv1_2', name: 'ถังขยะแยกประเภท', basePrice: 500, baseReduction: 10, categoryIndex: 0),
      ShopItem(id: 'lv1_3', name: 'เจ้าหน้าที่จัดการขยะ', basePrice: 1000, baseReduction: 12, categoryIndex: 2),
      ShopItem(id: 'lv1_4', name: 'รถเก็บขยะ', basePrice: 1500, baseReduction: 15, categoryIndex: 3),
    ],
    // Level 2 (Base reduction + 5 from LV1)
    [
      ShopItem(id: 'lv2_1', name: 'ถังขยะขนาดใหญ่', basePrice: 100, baseReduction: 10, categoryIndex: 0),
      ShopItem(id: 'lv2_2', name: 'จุดคัดแยกขยะชุมชน', basePrice: 500, baseReduction: 15, categoryIndex: 1),
      ShopItem(id: 'lv2_3', name: 'ทีมทำความสะอาด', basePrice: 1000, baseReduction: 17, categoryIndex: 2),
      ShopItem(id: 'lv2_4', name: 'รถบีบอัดขยะ', basePrice: 1500, baseReduction: 20, categoryIndex: 3),
    ],
    // Level 3 (Base reduction + 10 from LV1)
    [
      ShopItem(id: 'lv3_1', name: 'ถังขยะบีบอัด', basePrice: 100, baseReduction: 15, categoryIndex: 0),
      ShopItem(id: 'lv3_2', name: 'ตู้รับแลกขวด', basePrice: 500, baseReduction: 20, categoryIndex: 1),
      ShopItem(id: 'lv3_3', name: 'ผู้เชี่ยวชาญ', basePrice: 1000, baseReduction: 22, categoryIndex: 2),
      ShopItem(id: 'lv3_4', name: 'รถเก็บขยะไฟฟ้า', basePrice: 1500, baseReduction: 25, categoryIndex: 3),
    ],
    // Level 4 (Base reduction + 15 from LV1)
    [
      ShopItem(id: 'lv4_1', name: 'ถังขยะอัจฉริยะ', basePrice: 100, baseReduction: 20, categoryIndex: 0),
      ShopItem(id: 'lv4_2', name: 'ถังขยะ AI', basePrice: 500, baseReduction: 25, categoryIndex: 0),
      ShopItem(id: 'lv4_3', name: 'หุ่นยนต์เก็บขยะ', basePrice: 1000, baseReduction: 27, categoryIndex: 2),
      ShopItem(id: 'lv4_4', name: 'รถเก็บขยะไร้คนขับ', basePrice: 1500, baseReduction: 30, categoryIndex: 3),
    ],
    // Level 5 (Base reduction + 20 from LV1)
    [
      ShopItem(id: 'lv5_1', name: 'ถังขยะโซลาร์เซลล์', basePrice: 100, baseReduction: 25, categoryIndex: 0),
      ShopItem(id: 'lv5_2', name: 'ศูนย์รีไซเคิลขนาดย่อม', basePrice: 500, baseReduction: 30, categoryIndex: 1),
      ShopItem(id: 'lv5_3', name: 'ฝูงโดรนเก็บขยะ', basePrice: 1000, baseReduction: 32, categoryIndex: 2),
      ShopItem(id: 'lv5_4', name: 'รถแปรรูปขยะเคลื่อนที่', basePrice: 1500, baseReduction: 35, categoryIndex: 3),
    ]
  ];

  List<ShopItem> getItemsForLevel(int level) {
    if (level < 1 || level > 5) return [];
    return _shopItems[level - 1];
  }

  int getPrice(ShopItem item) {
    return item.basePrice + _pricePenalty;
  }

  int getActualReduction(ShopItem item) {
    int count = _itemPurchaseCount[item.id] ?? 0;
    int reduction = item.baseReduction;
    
    // Diminishing returns: 
    // -2 after 10 purchases, another -2 after 20 purchases.
    if (count >= 20) {
      reduction -= 4;
    } else if (count >= 10) {
      reduction -= 2;
    }
    
    return reduction < 1 ? 1 : reduction;
  }

  void buyItem(int levelIndex, int itemIndex, BuildContext context) {
    if (levelIndex > _cityLevel) return; // Cannot buy from future levels
    
    ShopItem item = _shopItems[levelIndex - 1][itemIndex];
    int price = getPrice(item);
    
    if (_money >= price) {
      if (_pollution == 0) {
        // ประชากรเต็มแล้ว ซื้อไปมลพิษก็ไม่ลดลง แต่หักเงินนะ ให้แจ้งเตือนก่อนก็ได้
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ประชากรเต็มแล้ว! กรุณาอัปเกรดเมืองก่อน')),
        );
        return;
      }

      _money -= price;
      
      // Update Purchase Count
      _itemPurchaseCount[item.id] = (_itemPurchaseCount[item.id] ?? 0) + 1;
      
      // Update Inventory Category Count
      _inventoryCounts[item.categoryIndex]++;

      // Calculate reduction
      int reduction = getActualReduction(item);
      
      // Update Pollution & Population
      _pollution -= reduction;
      if (_pollution < 0) _pollution = 0;
      
      _population = maxCapacity - _pollution;
      
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เงินไม่พอ!')),
      );
    }
  }

  void upgradeCity(BuildContext context) {
    if (_population == maxCapacity && _cityLevel < 5) {
      // 1. Calculate totals for the summary
      int binsUsed = _inventoryCounts[0];
      int stationsUsed = _inventoryCounts[1];
      int workersUsed = _inventoryCounts[2];
      int trucksUsed = _inventoryCounts[3];
      int totalItemsUsed = binsUsed + stationsUsed + workersUsed + trucksUsed;
      
      int totalInflation = _pricePenalty;
      int oldLevel = _cityLevel;

      // 2. Show Summary Popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ยินดีด้วย! เมืองเลเวล $oldLevel สำเร็จแล้ว 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('สรุปผลงานในเลเวล $oldLevel:', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('📦 ไอเทมที่ใช้ไปทั้งหมด: $totalItemsUsed ชิ้น'),
                if (binsUsed > 0) Text('  - ถังขยะ: $binsUsed ชิ้น', style: const TextStyle(color: Colors.brown)),
                if (stationsUsed > 0) Text('  - จุดคัดแยก: $stationsUsed ชิ้น', style: const TextStyle(color: Colors.orange)),
                if (workersUsed > 0) Text('  - พนักงาน/หุ่นยนต์: $workersUsed ชิ้น', style: const TextStyle(color: Colors.green)),
                if (trucksUsed > 0) Text('  - รถเก็บขยะ: $trucksUsed ชิ้น', style: const TextStyle(color: Colors.blue)),
                const SizedBox(height: 10),
                Text('💸 เงินเฟ้อสะสม (มลพิษเต็ม): $totalInflation บาท', style: TextStyle(color: totalInflation > 0 ? Colors.red : Colors.black)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                child: const Text('ลุยเลเวลต่อไป!'),
              ),
            ],
          );
        },
      );

      // 3. Upgrade and Reset Stats
      _cityLevel++;
      _pollution = maxCapacity ~/ 2;
      _population = maxCapacity - _pollution;
      _pricePenalty = 0; // Reset inflation
      for (int i = 0; i < _inventoryCounts.length; i++) {
        _inventoryCounts[i] = 0; // Reset inventory for the new level
      }
      
      // Optionally reset item purchase count for diminishing returns?
      // User said "เรื่องของไอเทมสะสมให้คิดเฉพาะเลเวลต่อเลเวล...และจะรีใหม่ทุกเวลนะ" 
      // This implies everything resets.
      _itemPurchaseCount.clear();

      notifyListeners();
    }
  }

  // --- Testing Methods ---
  void addMoney(int amount) {
    _money += amount;
    notifyListeners();
  }

  void increasePollution(int amount, BuildContext context) {
    _pollution += amount;
    if (_pollution >= maxCapacity) {
      _pollution = maxCapacity;
      // Penalty applies
      _pricePenalty += 100;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('มลพิษเต็มหลอด! ราคาสินค้าเพิ่มขึ้น 100 บาท (ปัจจุบัน +$_pricePenalty)'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _population = maxCapacity - _pollution;
    notifyListeners();
  }

  // --- Gamification Methods ---
  int addRandomCoins() {
    final int amount = (Random().nextInt(10) + 1) * 10;
    _money += amount;
    notifyListeners();
    return amount;
  }

  Map<String, dynamic> handleQuizResult(bool isCorrect) {
    int coinsEarned = addRandomCoins();
    int change = 50 * _cityLevel;
    
    if (isCorrect) {
      _pollution -= change;
      if (_pollution < 0) _pollution = 0;
    } else {
      _pollution += change;
      if (_pollution > maxCapacity) {
        _pollution = maxCapacity;
      }
    }
    
    _population = maxCapacity - _pollution;
    notifyListeners();
    
    return {
      'coins': coinsEarned,
      'change': change,
      'isCorrect': isCorrect,
    };
  }
}