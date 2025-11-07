import 'package:flutter/material.dart';
import '../models/store.dart';
import '../models/walkable_area.dart';
import 'home_page.dart'; 

// 搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<String> searchHistory = ['星巴克', 'DIOR', 'CHANEL'];
  List<Store> searchResults = [];
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF2E86AB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: isSearching ? _buildSearchResults() : _buildSearchHistory(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 搜索头部 - 修复布局溢出问题
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 返回按钮 
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 32, // 固定宽度
              height: 32, // 固定高度
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 搜索输入框 - 使用Flexible避免溢出
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.grey, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          // 可以在这里实现实时搜索
                        });
                      },
                      onSubmitted: (value) {
                        _performSearch();
                      },
                    ),
                  ),
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 16),
                  const SizedBox(width: 6),
                  const Icon(Icons.mic, color: Colors.grey, size: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 搜索按钮 
          GestureDetector(
            onTap: _performSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '搜索',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 执行搜索 - 增强错误处理和用户反馈
  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showSnackBar('请输入搜索内容');
      return;
    }
    
    print('🔍 开始搜索: "$query"');
    
    setState(() {
      isSearching = true;
      isLoading = true;
      searchResults = [];  // 恢复清空逻辑，配合不缓存空结果使用
      print('📝 搜索状态已更新: isSearching=true, isLoading=true, searchResults已清空');
    });
    
    try {
      // 使用智能搜索（优先使用AI，失败则降级到本地智能搜索）
      print('🤖 调用 StoreData.intelligentSearch...');
      final results = await StoreData.intelligentSearch(query, useAI: true);
      print('✅ 搜索返回 ${results.length} 个结果');
      print('📋 结果列表: ${results.map((s) => s.name).take(3).join(", ")}${results.length > 3 ? "..." : ""}');
      
      setState(() {
        searchResults = List<Store>.from(results);  // 创建副本，避免引用问题
        isLoading = false;
        print('📝 UI已更新: searchResults.length=${searchResults.length}, isLoading=false');
        
        // 添加到搜索历史
        if (!searchHistory.contains(query)) {
          searchHistory.insert(0, query);
          if (searchHistory.length > 10) {
            searchHistory.removeLast();
          }
        }
      });
      
      // 显示搜索结果反馈
      if (results.isEmpty) {
        print('⚠️ 结果为空，显示提示');
        _showSnackBar('没有找到相关店铺，试试其他关键词吧');
      } else {
        print('✅ 显示成功消息');
        _showSnackBar('找到 ${results.length} 个相关店铺');
      }
      
    } catch (e) {
      print('❌ 搜索错误: $e');
      setState(() {
        isLoading = false;
        // 出错时使用原有的简单搜索作为最后的后备
        searchResults = StoreData.searchStores(query);
      });
      _showSnackBar('搜索出现问题，已为您显示基础搜索结果');
    }
  }

  // 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.black54,
      ),
    );
  }

  // 搜索结果 
  Widget _buildSearchResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索结果头部
          Row(
            children: [
              Expanded(
                child: Text(
                  isLoading ? '正在搜索...' : '搜索结果 (${searchResults.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSearching = false;
                    searchResults.clear();
                    isLoading = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '返回',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 搜索结果列表
          Expanded(
            child: isLoading 
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '智能搜索中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '没有找到相关店铺',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '试试其他关键词，或者浏览搜索历史',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final store = searchResults[index];
                          // 计算最近的可行走区域
                          final nearestArea = WalkableAreaData.findNearestWalkableArea(store.id);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 117, 117, 117).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    '${store.floor}F',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                store.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    '${store.floor}楼 · 编号: ${store.id}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(203, 255, 255, 255),
                                      fontSize: 11,
                                    ),
                                  ),
                                  // 显示店铺类型信息
                                  if (store.type2.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          store.type2,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (nearestArea != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 11,
                                            color: Colors.greenAccent.withOpacity(0.8),
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              '可行走区域: $nearestArea',
                                              style: TextStyle(
                                                color: Colors.greenAccent.withOpacity(0.8),
                                                fontSize: 10,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              onTap: () {
                                // 使用 pushAndRemoveUntil 确保正确的导航栈
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      targetStore: store,
                                      targetFloor: store.floor,
                                    ),
                                  ),
                                  (route) => false,  // 清除所有之前的路由
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 搜索历史
  Widget _buildSearchHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (searchHistory.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      searchHistory.clear();
                    });
                  },
                  child: Text(
                    '清空',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 历史记录标签
          if (searchHistory.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchHistory.map((item) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.text = item;
                    });
                    _performSearch();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        // 使用 Flexible 避免文本溢出
                        Flexible(
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              searchHistory.remove(item);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.7),
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.search,
                    size: 48,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无搜索历史',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '试试搜索"星巴克"、"化妆品"或"女装"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}