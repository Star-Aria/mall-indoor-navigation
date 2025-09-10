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

  // 搜索头部
Widget _buildSearchHeader() {
  return Container(
    padding: const EdgeInsets.all(12), // 减小padding
    child: Row(
      children: [
        // 返回按钮 
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(6), // 减小padding
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6), // 减小圆角
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20, // 缩小图标
            ),
          ),
        ),
        const SizedBox(width: 8), // 减小间距
        
        // 搜索输入框
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8), // 减小padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20), // 减小圆角
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.grey, size: 16), // 缩小图标
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: const TextStyle(fontSize: 14), // 缩小字体
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(fontSize: 14), // 缩小提示文字
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8), // 减小内边距
                      isDense: true, // 使输入框更紧凑
                    ),
                    onChanged: (value) {
                      setState(() {
                        // 可以在这里实现实时搜索
                      });
                    },
                  ),
                ),
                const Icon(Icons.camera_alt, color: Colors.grey, size: 16), // 缩小图标
                const SizedBox(width: 6),
                const Icon(Icons.mic, color: Colors.grey, size: 16), // 缩小图标
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 8), // 减小间距
        
        // 搜索按钮 - 缩小版本
        GestureDetector(
          onTap: () {
            _performSearch();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 减小padding
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16), // 减小圆角
            ),
            child: const Text(
              '搜索',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12, // 缩小字体
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // 执行搜索
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      isSearching = true;
      searchResults = StoreData.searchStores(query);
      
      // 添加到搜索历史
      if (!searchHistory.contains(query)) {
        searchHistory.insert(0, query);
        if (searchHistory.length > 10) {
          searchHistory.removeLast();
        }
      }
    });
  }

  // 在_SearchPageState类中修改搜索结果显示
Widget _buildSearchResults() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '搜索结果 (${searchResults.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  isSearching = false;
                  searchResults.clear();
                });
              },
              child: const Text(
                '返回',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: searchResults.isEmpty
              ? const Center(
                  child: Text(
                    '没有找到相关店铺',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final store = searchResults[index];
                    // 计算最近的可行走区域
                    final nearestArea = WalkableAreaData.findNearestWalkableArea(store.id);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          store.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${store.floor}楼 · 编号: ${store.id}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (nearestArea != null)
                              Text(
                                '最近可行走区域: $nearestArea',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
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
          const Text(
            '搜索历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // 历史记录标签 - 恢复原设计
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: searchHistory.map((item) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.text = item;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchHistory.remove(item);
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}