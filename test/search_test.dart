import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2/models/store.dart';

void main() {
  test('搜索功能测试', () {
    // 测试搜索"星巴克"
    final results = StoreData.searchStores('星巴克');
    expect(results.length, greaterThan(0));
    expect(results[0].name, contains('星巴克'));
    
    // 测试搜索"DIOR"
    final diorResults = StoreData.searchStores('DIOR');
    expect(diorResults.length, greaterThan(0));
    expect(diorResults[0].name, contains('DIOR'));
    
    // 测试搜索不存在的店铺
    final emptyResults = StoreData.searchStores('不存在的店铺');
    expect(emptyResults.length, 0);
  });
}
