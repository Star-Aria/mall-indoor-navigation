import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2/models/store.dart';

void main() {
  test('简单搜索测试', () {
    // 测试搜索功能是否能返回结果
    final results = StoreData.searchStores('迪奥');
    print('搜索"迪奥"返回 ${results.length} 个结果');
    
    // 遍历所有店铺，检查是否有包含"迪奥"的店铺
    int diorCount = 0;
    for (var store in StoreData.stores) {
      if (store.name.contains('迪奥')) {
        diorCount++;
        print('找到店铺: ${store.name} (ID: ${store.id})');
      }
    }
    print('数据中共有 $diorCount 个包含"迪奥"的店铺');
  });
}
