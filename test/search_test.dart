import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_2/models/store.dart';
import 'package:flutter_2/models/geojson.dart';

void main() {
  group('Search Functionality Tests', () {
    setUpAll(() async {
      // 确保GeoJSON数据已加载
      await GeoJsonData.loadGeoJsonData();
    });

    test('Search stores by name', () async {
      // 测试搜索功能
      final results = await StoreData.searchStores('星巴克');
      expect(results, isNotEmpty);
      expect(results.first.name, contains('星巴克'));
    });

    test('Search with empty query returns empty list', () async {
      final results = await StoreData.searchStores('');
      expect(results, isEmpty);
    });

    test('Search with non-existent store returns empty list', () async {
      final results = await StoreData.searchStores('不存在的店铺');
      expect(results, isEmpty);
    });

    test('Search is case insensitive', () async {
      final results1 = await StoreData.searchStores('星巴克');
      final results2 = await StoreData.searchStores('星巴克');
      expect(results1.length, equals(results2.length));
    });
  });
}
