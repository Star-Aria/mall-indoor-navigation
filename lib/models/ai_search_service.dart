import 'dart:convert';
import 'package:http/http.dart' as http;
import 'store.dart';

/// DeepSeek API智能搜索服务
class AISearchService {
  // ==================== DeepSeek API 配置 ====================
  static const String apiKey = 'sk-674e1d6a046f4d0ea465a21317a7f77e';  
  static const String apiEndpoint = 'https://api.deepseek.com/v1/chat/completions';
  static const String model = 'deepseek-chat';
  
  // 搜索结果缓存
  static final Map<String, List<Store>> _searchCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 1);
  
  /// 智能搜索（带缓存）
  static Future<List<Store>> intelligentSearch(String query, List<Store> allStores) async {
    print('🔎 intelligentSearch 被调用: query="$query", allStores.length=${allStores.length}');
    
    // 检查缓存
    if (_isCacheValid(query)) {
      print('✅ 使用缓存结果: $query');
      final cachedResults = _searchCache[query]!;
      print('📦 缓存返回 ${cachedResults.length} 个结果');
      if (cachedResults.isNotEmpty) {
        print('📋 缓存结果示例: ${cachedResults.take(3).map((s) => s.name).join(", ")}');
      }
      // 重要：返回缓存的副本，避免外部修改影响缓存
      return List<Store>.from(cachedResults);
    }
    
    print('🔄 缓存未命中，开始新搜索');
    
    List<Store> results;
    
    // 检查API密钥是否配置
    if (apiKey == 'YOUR_DEEPSEEK_API_KEY_HERE' || apiKey.isEmpty) {
      print('⚠️ DeepSeek API密钥未配置，使用本地智能搜索');
      results = _fallbackSearch(query, allStores);
    } else {
      try {
        print('🤖 正在调用DeepSeek API...');
        results = await _aiSearch(query, allStores);
        print('✅ AI搜索成功，返回 ${results.length} 个结果');
      } catch (e) {
        print('❌ AI搜索失败: $e');
        print('🔄 回退到本地智能搜索');
        results = _fallbackSearch(query, allStores);
      }
    }
    
    print('💾 准备缓存结果: ${results.length} 个');
    // 缓存结果
    _cacheResults(query, results);
    
    return results;
  }
  
  /// 调用DeepSeek API进行智能搜索
  static Future<List<Store>> _aiSearch(String query, List<Store> allStores) async {
    // 构建店铺信息摘要
    String storesInfo = _buildStoresContext(allStores);
    
    // 构建提示词
    String prompt = '''
你是一个专业的商场导航助手。用户正在搜索: "$query"

商场中的店铺信息如下：
$storesInfo

请分析用户的查询意图，并返回最相关的店铺ID列表。考虑以下因素：
1. 直接名称匹配
2. 店铺类型匹配（type和type2字段）
3. 语义相关性（例如"化妆品"应匹配化妆品店、美妆店等）
4. 场景匹配（例如"可以安静工作的地方"应匹配咖啡厅、书店等）
5. 按相关度排序，最相关的排在前面

请直接返回JSON格式的店铺ID列表，格式如下：
{"store_ids": ["id1", "id2", "id3"]}

只返回JSON，不要有其他解释。
''';

    try {
      // 调用DeepSeek API
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的商场导航助手，擅长理解用户的搜索意图并提供准确的店铺推荐。',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1024,
          'temperature': 0.3,  // 较低的温度以获得更确定的结果
        }),
      ).timeout(const Duration(seconds: 15)); // 增加超时时间

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 检查API响应格式
        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception('API响应格式错误: 没有choices字段');
        }
        
        final content = data['choices'][0]['message']['content'];
        print('🤖 DeepSeek API 响应: $content');
        
        // 解析返回的店铺ID列表
        String jsonStr = _extractJson(content);
        final result = json.decode(jsonStr);
        final storeIds = List<String>.from(result['store_ids'] ?? []);
        
        // 根据ID筛选店铺并保持顺序
        List<Store> matchedStores = [];
        for (String id in storeIds) {
          try {
            final store = allStores.firstWhere((s) => s.id == id);
            matchedStores.add(store);
          } catch (e) {
            // 店铺不存在，跳过
            print('⚠️ 店铺ID $id 不存在，跳过');
            continue;
          }
        }
        
        return matchedStores;
      } else {
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['error'] != null) {
            errorMsg += ': ${errorData['error']['message'] ?? errorData['error']}';
          }
        } catch (e) {
          errorMsg += ': ${response.body}';
        }
        throw Exception('API调用失败: $errorMsg');
      }
    } catch (e) {
      if (e.toString().contains('Incorrect API key')) {
        throw Exception('API密钥无效，请检查DeepSeek API密钥是否正确');
      } else if (e.toString().contains('timeout')) {
        throw Exception('API请求超时，请检查网络连接');
      } else {
        throw Exception('API调用异常: $e');
      }
    }
  }
  
  /// 提取JSON字符串
  static String _extractJson(String content) {
    // 尝试提取JSON部分
    String jsonStr = content.trim();
    
    // 如果包含markdown代码块，提取其中的内容
    if (jsonStr.contains('```json')) {
      final startIndex = jsonStr.indexOf('```json') + 7;
      final endIndex = jsonStr.indexOf('```', startIndex);
      if (endIndex > startIndex) {
        jsonStr = jsonStr.substring(startIndex, endIndex).trim();
      }
    } else if (jsonStr.contains('```')) {
      final startIndex = jsonStr.indexOf('```') + 3;
      final endIndex = jsonStr.indexOf('```', startIndex);
      if (endIndex > startIndex) {
        jsonStr = jsonStr.substring(startIndex, endIndex).trim();
      }
    }
    
    // 查找JSON对象
    if (jsonStr.contains('{')) {
      int startIndex = jsonStr.indexOf('{');
      int endIndex = jsonStr.lastIndexOf('}') + 1;
      jsonStr = jsonStr.substring(startIndex, endIndex);
    }
    
    return jsonStr;
  }
  
  /// 构建店铺上下文信息
  static String _buildStoresContext(List<Store> stores) {
    StringBuffer context = StringBuffer();
    
    // 限制上下文长度，避免超过token限制
    int maxStores = 100;
    var limitedStores = stores.take(maxStores).toList();
    
    for (var store in limitedStores) {
      context.writeln('ID: ${store.id}, 名称: ${store.name}, 类型: ${store.type}, 具体类型: ${store.type2}, 楼层: ${store.floor}');
    }
    
    if (stores.length > maxStores) {
      context.writeln('... 以及其他 ${stores.length - maxStores} 个店铺');
    }
    
    return context.toString();
  }
  
  /// 本地智能匹配（作为后备方案）
  static List<Store> _fallbackSearch(String query, List<Store> allStores) {
    String lowerQuery = query.toLowerCase();
    
    // 定义类型关键词映射 - 增强版
    Map<String, List<String>> categoryKeywords = {
      '化妆品': ['化妆', '美妆', '护肤', 'beauty', 'cosmetic', '彩妆', 'makeup', 'sephora', '丝芙兰', '娇兰', 'dior', 'chanel', 'lancome', '兰蔻'],
      '女装': ['女装', '服装', 'fashion', '时尚', '衣服', 'women', 'zara', 'h&m', 'uniqlo', 'only', 'vero moda', '优衣库'],
      '男装': ['男装', '服装', 'fashion', '男士', 'men', '男式', 'gxg', 'jack jones'],
      '餐饮': ['餐厅', '美食', '食品', 'restaurant', '吃饭', '餐饮', 'food', '饭店', '中餐', '西餐', '快餐', '火锅', '烧烤'],
      '咖啡': ['咖啡', 'coffee', 'cafe', 'starbucks', '星巴克', 'costa', '瑞幸', 'luckin', '太平洋咖啡'],
      '书店': ['书店', '阅读', '图书', 'book', '书', '书屋', '书吧', '新华书店', '西西弗'],
      '珠宝': ['珠宝', '首饰', 'jewelry', '钻石', '黄金', 'gold', 'tiffany', 'cartier', '卡地亚', '蒂芙尼', '周大福', '周生生'],
      '运动': ['运动', 'sport', '健身', '户外', 'nike', 'adidas', 'puma', 'reebok', '安踏', '李宁', '特步'],
      '数码': ['数码', '电子', '手机', '电脑', 'digital', 'apple', '苹果', '华为', '小米', 'samsung', '三星', 'oppo', 'vivo'],
      '儿童': ['儿童', '玩具', '母婴', 'kids', '童装', 'toy', '宝宝', '婴儿', '孕妇', '亲子'],
      '奢侈品': ['奢侈', 'luxury', 'lv', 'gucci', 'dior', 'chanel', 'hermes', 'prada', 'burberry', '爱马仕', '古驰', '路易威登'],
      '家居': ['家居', '家具', 'home', 'ikea', '宜家', '装饰', '家装', '床上用品'],
      '超市': ['超市', '便利店', 'market', '超级市场', '购物', '7-11', '全家', 'familymart'],
      '电影': ['电影', 'cinema', '影院', '电影院', 'imax', '影城'],
      '银行': ['银行', 'bank', 'atm', '取款机', '建行', '工行', '农行', '中行'],
    };
    
    // 场景匹配 - 增强版
    Map<String, List<String>> scenarioKeywords = {
      '工作': ['咖啡', 'coffee', 'cafe', '书店', 'book', '安静'],
      '安静': ['咖啡', 'coffee', 'cafe', '书店', 'book', '阅读', '图书馆'],
      '学习': ['咖啡', 'coffee', 'cafe', '书店', 'book', '安静', '学习'],
      '约会': ['餐厅', 'restaurant', '咖啡', 'coffee', '电影', 'cinema', '浪漫'],
      '购物': ['服装', '化妆', '珠宝', '数码', '奢侈', '包包', '鞋子'],
      '休闲': ['咖啡', 'coffee', '餐厅', 'restaurant', '书店', '电影', 'cinema'],
      '吃饭': ['餐厅', 'restaurant', '美食', 'food', '餐饮', '快餐', '火锅'],
      '买礼物': ['珠宝', 'jewelry', '奢侈', 'luxury', '化妆', 'cosmetic', '数码'],
      '娱乐': ['电影', 'cinema', 'ktv', '游戏', '娱乐'],
      '取钱': ['银行', 'bank', 'atm', '取款'],
    };
    
    List<Store> results = [];
    Map<Store, int> scoreMap = {}; // 用于评分排序
    
    // 1. 直接名称匹配（最高分：100分）
    for (var store in allStores) {
      if (store.name.toLowerCase().contains(lowerQuery)) {
        scoreMap[store] = (scoreMap[store] ?? 0) + 100;
      }
    }
    
    // 2. 类型关键词匹配（高分：50分）
    for (var entry in categoryKeywords.entries) {
      if (entry.value.any((keyword) => lowerQuery.contains(keyword))) {
        for (var store in allStores) {
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
        for (var store in allStores) {
          String storeInfo = '${store.type} ${store.type2} ${store.name}'.toLowerCase();
          if (entry.value.any((keyword) => storeInfo.contains(keyword))) {
            scoreMap[store] = (scoreMap[store] ?? 0) + 30;
          }
        }
      }
    }
    
    // 4. 模糊匹配type和type2字段（低分：20分）
    for (var store in allStores) {
      String storeInfo = '${store.type} ${store.type2}'.toLowerCase();
      if (storeInfo.contains(lowerQuery) && !scoreMap.containsKey(store)) {
        scoreMap[store] = (scoreMap[store] ?? 0) + 20;
      }
    }
    
    // 按分数排序
    results = scoreMap.keys.toList()
      ..sort((a, b) => scoreMap[b]!.compareTo(scoreMap[a]!));
    
    // 限制返回结果数量
    if (results.length > 50) {
      results = results.take(50).toList();
    }
    
    print('🔍 本地搜索找到 ${results.length} 个结果');
    return results;
  }
  
  /// 获取智能推荐（基于用户查询历史）
  static Future<List<Store>> getRecommendations(List<String> searchHistory, List<Store> allStores) async {
    if (searchHistory.isEmpty) {
      print('📝 搜索历史为空，返回热门店铺');
      return allStores.take(5).toList();
    }
    
    // 如果API不可用，返回基于历史的简单推荐
    if (apiKey == 'YOUR_DEEPSEEK_API_KEY_HERE' || apiKey.isEmpty) {
      return _getLocalRecommendations(searchHistory, allStores);
    }
    
    try {
      String historyText = searchHistory.take(5).join(', ');
      String storesInfo = _buildStoresContext(allStores);
      
      String prompt = '''
用户的最近搜索历史: $historyText

商场中的店铺信息：
$storesInfo

基于用户的搜索历史，推荐5-10个用户可能感兴趣的店铺。
请返回JSON格式：
{"store_ids": ["id1", "id2", "id3"]}

只返回JSON，不要其他内容。
''';

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个商场导航助手。',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1024,
          'temperature': 0.3,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // 提取JSON部分
        String jsonStr = _extractJson(content);
        final result = json.decode(jsonStr);
        final storeIds = List<String>.from(result['store_ids'] ?? []);
        
        List<Store> recommendations = [];
        for (String id in storeIds) {
          try {
            final store = allStores.firstWhere((s) => s.id == id);
            recommendations.add(store);
          } catch (e) {
            continue;
          }
        }
        
        print('🤖 AI推荐成功，返回 ${recommendations.length} 个推荐');
        return recommendations;
      }
    } catch (e) {
      print('❌ AI推荐失败: $e');
    }
    
    return _getLocalRecommendations(searchHistory, allStores);
  }
  
  /// 本地推荐算法
  static List<Store> _getLocalRecommendations(List<String> searchHistory, List<Store> allStores) {
    print('🔄 使用本地推荐算法');
    
    // 基于搜索历史进行本地推荐
    List<Store> recommendations = [];
    
    for (var query in searchHistory.take(3)) {
      var results = _fallbackSearch(query, allStores);
      for (var store in results.take(2)) {
        if (!recommendations.contains(store)) {
          recommendations.add(store);
        }
      }
    }
    
    // 如果推荐不足，添加一些热门店铺
    if (recommendations.length < 5) {
      for (var store in allStores) {
        if (!recommendations.contains(store)) {
          recommendations.add(store);
        }
        if (recommendations.length >= 8) break;
      }
    }
    
    return recommendations.take(8).toList();
  }
  
  // ==================== 缓存管理 ====================
  
  /// 检查缓存是否有效
  static bool _isCacheValid(String query) {
    if (!_searchCache.containsKey(query)) return false;
    
    final timestamp = _cacheTimestamps[query];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }
  
  /// 缓存搜索结果
  static void _cacheResults(String query, List<Store> results) {
    // 不缓存空结果，避免第二次搜索时显示"没有找到相关店铺"
    if (results.isEmpty) {
      print('⚠️ 搜索结果为空，不缓存');
      return;
    }
    
    // 如果缓存已满，删除最旧的条目
    if (_searchCache.length >= 50) {
      String? oldestKey;
      DateTime? oldestTime;
      
      for (var entry in _cacheTimestamps.entries) {
        if (oldestTime == null || entry.value.isBefore(oldestTime)) {
          oldestTime = entry.value;
          oldestKey = entry.key;
        }
      }
      
      if (oldestKey != null) {
        _searchCache.remove(oldestKey);
        _cacheTimestamps.remove(oldestKey);
      }
    }
    
    // 重要：创建列表的副本，避免引用被修改
    _searchCache[query] = List<Store>.from(results);
    _cacheTimestamps[query] = DateTime.now();
    print('✅ 已缓存 ${results.length} 个结果（副本）');
  }

  
  /// 清除缓存
  static void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ 搜索缓存已清除');
  }
  
  /// 清除过期缓存
  static void clearExpiredCache() {
    List<String> expiredKeys = [];
    
    for (var entry in _cacheTimestamps.entries) {
      if (DateTime.now().difference(entry.value) >= _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (var key in expiredKeys) {
      _searchCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      print('🗑️ 清除了 ${expiredKeys.length} 个过期缓存');
    }
  }
  
  /// 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_queries': _searchCache.length,
      'cache_limit': 50,
      'cache_expiry_hours': _cacheExpiry.inHours,
    };
  }
}