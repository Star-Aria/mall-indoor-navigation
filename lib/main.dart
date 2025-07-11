import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 用于检测平台

void main() {
  runApp(const MallNavigationApp());
}

class MallNavigationApp extends StatelessWidget {
  const MallNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '商场导航',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFloor = 'F1'; // 默认选中F1
  bool isFullScreen = false; // 添加全屏状态

  // 楼层列表：从下到上为 B2、B1、F1~F6
  final List<String> floors = ['F6', 'F5', 'F4', 'F3', 'F2', 'F1', 'B1', 'B2'];

  @override
  Widget build(BuildContext context) {
    // 如果是全屏模式，只显示地图
    if (isFullScreen) {
      return Scaffold(
        body: Stack(
          children: [
            // 全屏地图
            _buildFullScreenMap(),
            // 右上角缩小按钮
            _buildExitFullScreenButton(),
          ],
        ),
      );
    }
    
    // 正常模式
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // 浅蓝色
              Color(0xFF9B59B6), // 紫色
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部搜索栏
              _buildSearchBar(),
              
              // 主体内容区域
              Expanded(
                child: Stack(
                  children: [
                    // 地图区域 - 占满整个屏幕宽度
                    _buildMapArea(),
                    
                    // 左侧楼层导航 - 浮在地图上
                    _buildFloorNavigation(),
                    
                    // 右侧功能按钮 - 浮在地图上
                    _buildRightSideButtons(),
                  ],
                ),
              ),
              
              // 底部导航栏
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  // 全屏地图
  Widget _buildFullScreenMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: LayoutBuilder(
        builder: (context, constraints) {
          double containerHeight = constraints.maxHeight;
          double containerWidth = constraints.maxWidth;
          
          // 地图宽高比 2:1 (长:短)
          double mapAspectRatio = 2.0 / 1.0;
          
          // 横屏：短边固定为屏幕宽度，长边按比例计算（会超出屏幕高度）
          double mapWidth = containerWidth;  // 短边固定
          double mapHeight = mapWidth * mapAspectRatio;  // 长边自适应，会超出
          
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            boundaryMargin: EdgeInsets.zero,
            panEnabled: true,
            scaleEnabled: true,
            constrained: false,
            child: SizedBox(
              width: mapHeight,  // 给旋转后的地图足够宽度
              height: mapHeight, // 给足够高度
              child: Transform.rotate(
                angle: 1.5708,
                child: Container(
                  width: mapWidth,
                  height: mapHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Image.asset(
                    'assets/maps/$selectedFloor.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            '👆👇 上下拖拽查看地图长边',
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 退出全屏按钮
  Widget _buildExitFullScreenButton() {
    return Positioned(
      right: 16,
      top: 50, // 稍微下移一点，避免被状态栏遮挡
      child: GestureDetector(
        onTap: () {
          _exitFullScreen();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.fullscreen_exit,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // 修改原来的全屏按钮
  Widget _buildRightSideButtons() {
    return Positioned(
      right: 16,
      top: 20,
      child: GestureDetector(
        onTap: () {
          _enterFullScreen();
        },
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.fullscreen,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
      ),
    );
  }

  // 进入全屏模式 - 移除了SystemChrome相关代码
  void _enterFullScreen() {
    setState(() {
      isFullScreen = true;
    });
    // 注意：在Web环境中，屏幕方向和系统UI控制不可用
    // 只是通过UI状态切换来模拟全屏效果
  }

  // 退出全屏模式 - 移除了SystemChrome相关代码
  void _exitFullScreen() {
    setState(() {
      isFullScreen = false;
    });
  }

  // 搜索栏 - 修改为可点击跳转
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 搜索图标
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // 搜索输入框 - 改为可点击的容器
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 跳转到搜索页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(Icons.camera_alt, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Icon(Icons.mic, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 地图区域 - 支持拖拽和缩放
  Widget _buildMapArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 获取容器的实际高度
          double containerHeight = constraints.maxHeight;
          double containerWidth = constraints.maxWidth;
          
          // 假设地图原始宽高比是 2:1
          double mapAspectRatio = 2.0 / 1.0;
          
          // 计算地图尺寸：高度等于容器高度，宽度按比例计算
          double mapHeight = containerHeight;
          double mapWidth = mapHeight * mapAspectRatio;
          
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            // 关键：设置为EdgeInsets.zero，不允许露出容器白边
            boundaryMargin: EdgeInsets.zero,
            panEnabled: true,
            scaleEnabled: true,
            constrained: false,
            child: Container(
              width: mapWidth,
              height: mapHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Image.asset(
                'assets/maps/$selectedFloor.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$selectedFloor 楼层地图',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '容器: ${containerWidth.toInt()}x${containerHeight.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '地图: ${mapWidth.toInt()}x${mapHeight.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '👈👉 左右拖拽查看更多区域',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 左侧楼层导航
  Widget _buildFloorNavigation() {
    return Positioned(
      left: 16,
      top: 20,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 指南针图标
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            // 楼层按钮
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: floors.length,
                itemBuilder: (context, index) {
                  final floor = floors[index];
                  final isSelected = floor == selectedFloor;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFloor = floor;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        floor,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 底部导航栏
  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.location_on, '您所在的位置', Colors.red),
          _buildBottomNavItem(Icons.shopping_bag, '商铺', Colors.grey),
          _buildBottomNavItem(Icons.stairs, '扶梯', Colors.grey),
          _buildBottomNavItem(Icons.wc, '洗手间', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, Color iconColor) {
    return GestureDetector(
      onTap: () {
        // 处理底部导航点击事件
        print('点击了: $label');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// 新增搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // 搜索历史记录
  List<String> searchHistory = ['星巴克', '优衣库', '名创优品'];

  @override
  void initState() {
    super.initState();
    // 页面加载完成后自动聚焦到搜索框
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
              Color(0xFF87CEEB), // 浅蓝色
              Color(0xFF2E86AB), // 深蓝色
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部搜索栏
              _buildSearchHeader(),
              
              // 搜索历史区域
              Expanded(
                child: _buildSearchHistory(),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 搜索输入框
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          // 可以在这里实现实时搜索
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  const Icon(Icons.mic, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 搜索按钮
          GestureDetector(
            onTap: () {
              // 执行搜索
              _performSearch();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '搜索',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 搜索历史区域
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
          
          // 历史记录标签
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

  // 执行搜索
  void _performSearch() {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      // 添加到搜索历史
      setState(() {
        if (!searchHistory.contains(searchText)) {
          searchHistory.insert(0, searchText);
          if (searchHistory.length > 10) {
            searchHistory.removeLast();
          }
        }
      });
      
      // 这里可以添加搜索逻辑
      print('搜索: $searchText');
      
      // 可以跳转到搜索结果页面或者返回主页面
      Navigator.pop(context);
    }
  }
}
