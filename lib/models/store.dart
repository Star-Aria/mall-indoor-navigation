import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'point.dart';
import 'ai_search_service.dart';  // 导入AI搜索服务

// 数据模型类
class Store {
  final String id;
  final String name;
  final int floor;
  final String type;
  final String type2;  // 具体类型
  final Point? location;

  Store({
    required this.id,
    required this.name,
    required this.floor,
    required this.type,
    required this.type2,  
    this.location,
  });
}

class StoreData {
  static List<Store> stores = [];
  static bool isLoaded = false;

  // 从GeoJSON文件加载数据
  static Future<void> loadStoreData() async {
    if (isLoaded) return;

    try {
      // 加载Store数据
      final String response = await rootBundle.loadString('assets/geojson/Store1.geojson');
      final Map<String, dynamic> data = json.decode(response);
      
      stores.clear();
      
      for (var feature in data['features']) {
        final String id = feature['properties']['id'] ?? '';
        final String name = feature['properties']['name'] ?? '';
        final int floor = feature['properties']['floor'] ?? 1;
        final String type = feature['properties']['type'] ?? 'Store';
        final String type2 = feature['properties']['type2'] ?? '';  // 新增：读取type2
        
        // 计算商店的中心点位置
        Point? location;
        if (feature['geometry'] != null && feature['geometry']['coordinates'] != null) {
          final coords = feature['geometry']['coordinates'];
          
          // 处理Polygon格式
          if (feature['geometry']['type'] == 'Polygon' && coords.isNotEmpty) {
            final ring = coords[0] as List;
            if (ring.isNotEmpty) {
              double sumX = 0;
              double sumY = 0;
              int count = 0;
              
              for (var coord in ring) {
                sumX += coord[0].toDouble();
                sumY += coord[1].toDouble();
                count++;
              }
              
              if (count > 0) {
                // 修复上下颠倒：将Y坐标取负值
                location = Point(sumX / count, -(sumY / count));
              }
            }
          }
          // 处理MultiPolygon格式
          else if (feature['geometry']['type'] == 'MultiPolygon' && coords.isNotEmpty) {
            final polygon = coords[0] as List;
            if (polygon.isNotEmpty) {
              final ring = polygon[0] as List;
              if (ring.isNotEmpty) {
                double sumX = 0;
                double sumY = 0;
                int count = 0;
                
                for (var coord in ring) {
                  sumX += coord[0].toDouble();
                  sumY += coord[1].toDouble();
                  count++;
                }
                
                if (count > 0) {
                  // 修复上下颠倒：将Y坐标取负值
                  location = Point(sumX / count, -(sumY / count));
                }
              }
            }
          }
        }
        
        stores.add(Store(
          id: id,
          name: name,
          floor: floor,
          type: type,
          type2: type2,  
          location: location,
        ));
      }
      
      isLoaded = true;
    } catch (e) {
      print('Error loading Store data: $e');
      // 如果加载失败，使用空列表
      stores = [];
    }
  }

  // 简单搜索方法（保留作为后备）
  static List<Store> searchStores(String query) {
    if (query.isEmpty) return [];
    
    return stores.where((store) {
      if (store.name.isEmpty) return false;
      return store.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // 智能搜索方法（使用AI）
  static Future<List<Store>> intelligentSearch(String query, {bool useAI = true}) async {
    if (query.isEmpty) return [];
    
    // 判断是否为店铺名称查询
    bool isStoreNameQuery = _isStoreNameQuery(query);
    
    if (useAI && !isStoreNameQuery) {
      // 对于自然语言查询，使用AI进行智能搜索
      try {
        return await AISearchService.intelligentSearch(query, stores);
      } catch (e) {
        print('AI搜索失败，使用本地搜索: $e');
        // AI搜索失败时，降级到本地搜索
        return _localIntelligentSearch(query);
      }
    } else {
      // 对于店铺名称查询或不使用AI的情况，使用本地智能搜索
      return _localIntelligentSearch(query);
    }
  }

  // 判断是否为店铺名称查询
  static bool _isStoreNameQuery(String query) {
    String lowerQuery = query.toLowerCase().trim();
    
    // 检查是否直接匹配任何店铺名称
    for (var store in stores) {
      if (store.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }
    }
    
    // 定义常见的自然语言关键词
    List<String> naturalLanguageKeywords = [
      // 中文关键词
      '化妆', '美妆', '护肤', '女装', '男装', '服装', '时尚', '餐厅', '美食', 
      '咖啡', '书店', '阅读', '珠宝', '首饰', '运动', '健身', '数码', '电子',
      '儿童', '玩具', '奢侈', '家居', '超市', '电影', '银行',
      // 场景词汇
      '工作', '安静', '学习', '约会', '购物', '休闲', '吃饭', '买礼物', '娱乐', '取钱',
      '可以', '哪里', '想要', '需要', '推荐', '找', '买', '去',
      // 英文关键词
      'beauty', 'cosmetic', 'fashion', 'restaurant', 'coffee', 'cafe', 'book',
      'jewelry', 'sport', 'digital', 'luxury', 'home', 'cinema', 'bank'
    ];
    
    // 如果查询包含自然语言关键词，则不是店铺名称查询
    for (String keyword in naturalLanguageKeywords) {
      if (lowerQuery.contains(keyword)) {
        return false;
      }
    }
    
    // 检查是否为纯品牌名称（通常较短且不包含描述性词汇）
    if (lowerQuery.length <= 10 && !lowerQuery.contains(' ')) {
      return true;
    }
    
    // 默认认为是店铺名称查询
    return true;
  }

  // 本地智能搜索（不依赖AI API）
  static List<Store> _localIntelligentSearch(String query) {
    String lowerQuery = query.toLowerCase();
    
    // 定义类型关键词映射
    Map<String, List<String>> categoryKeywords = {
      '化妆品': ['化妆', '美妆', '护肤', 'beauty', 'cosmetic', '彩妆', 'makeup'],
      '女装': ['女装', '服装', 'fashion', '时尚', '衣服', 'women'],
      '男装': ['男装', '服装', 'fashion', '男士', 'men'],
      '餐饮': ['餐厅', '美食', '食品', 'restaurant', '吃饭', '餐饮', 'food'],
      '咖啡': ['咖啡', 'coffee', 'cafe', 'starbucks', '星巴克'],
      '书店': ['书店', '阅读', '图书', 'book', '书'],
      '珠宝': ['珠宝', '首饰', 'jewelry', '钻石', '黄金', 'gold'],
      '运动': ['运动', 'sport', '健身', '户外', 'nike', 'adidas'],
      '数码': ['数码', '电子', '手机', '电脑', 'digital', 'apple', '苹果'],
      '儿童': ['儿童', '玩具', '母婴', 'kids', '童装', 'toy'],
      '奢侈品': ['奢侈', 'luxury', 'lv', 'gucci', 'dior', 'chanel', 'hermes'],
    };
    
    // 场景匹配
    Map<String, List<String>> scenarioKeywords = {
      '工作': ['咖啡', 'coffee', 'cafe', '书店', 'book'],
      '安静': ['咖啡', 'coffee', 'cafe', '书店', 'book', '阅读'],
      '学习': ['咖啡', 'coffee', 'cafe', '书店', 'book'],
      '约会': ['餐厅', 'restaurant', '咖啡', 'coffee', '浪漫'],
      '购物': ['服装', '化妆', '珠宝', '数码', '奢侈'],
      '休闲': ['咖啡', 'coffee', '餐厅', 'restaurant', '书店'],
    };
    
    List<Store> results = [];
    Map<Store, int> scoreMap = {}; // 用于评分排序
    
    // 1. 直接名称匹配（最高分：100分）
    for (var store in stores) {
      if (store.name.toLowerCase().contains(lowerQuery)) {
        scoreMap[store] = (scoreMap[store] ?? 0) + 100;
      }
    }
    
    // 2. 类型关键词匹配（高分：50分）
    for (var entry in categoryKeywords.entries) {
      if (entry.value.any((keyword) => lowerQuery.contains(keyword))) {
        for (var store in stores) {
          String storeType = '${store.type} ${store.type2} ${store.name}'.toLowerCase();
          if (entry.value.any((keyword) => storeType.contains(keyword))) {
            scoreMap[store] = (scoreMap[store] ?? 0) + 50;
          }
        }
      }
    }
    
    // 3. 场景关键词匹配（中等分：30分）
    for (var entry in scenarioKeywords.entries) {
      if (lowerQuery.contains(entry.key)) {
        for (var store in stores) {
          String storeInfo = '${store.type} ${store.type2} ${store.name}'.toLowerCase();
          if (entry.value.any((keyword) => storeInfo.contains(keyword))) {
            scoreMap[store] = (scoreMap[store] ?? 0) + 30;
          }
        }
      }
    }
    
    // 4. 模糊匹配type和type2字段（低分：20分）
    for (var store in stores) {
      String storeInfo = '${store.type} ${store.type2}'.toLowerCase();
      if (storeInfo.contains(lowerQuery) && !scoreMap.containsKey(store)) {
        scoreMap[store] = (scoreMap[store] ?? 0) + 20;
      }
    }
    
    // 按分数排序
    results = scoreMap.keys.toList()
      ..sort((a, b) => scoreMap[b]!.compareTo(scoreMap[a]!));
    
    return results;
  }

  // 获取智能推荐
  static Future<List<Store>> getRecommendations(List<String> searchHistory) async {
    try {
      return await AISearchService.getRecommendations(searchHistory, stores);
    } catch (e) {
      print('获取推荐失败: $e');
      // 返回热门店铺作为默认推荐
      return stores.take(5).toList();
    }
  }
}