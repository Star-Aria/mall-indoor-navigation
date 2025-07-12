import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// 数据模型类
class Store {
  final String id;
  final String name;
  final int floor;
  final String type;

  Store({
    required this.id,
    required this.name,
    required this.floor,
    required this.type,
  });
}

class StoreData {
  static List<Store> stores = [
    Store(id: "S1", name: "蔚来汽车", floor: 1, type: "Store"),
    Store(id: "S2", name: "HARMAY", floor: 1, type: "Store"),
    Store(id: "S3", name: "GUCCI beauty", floor: 1, type: "Store"),
    Store(id: "S4", name: "ZARA HOME", floor: 1, type: "Store"),
    Store(id: "S5", name: "CHANEL", floor: 1, type: "Store"),
    Store(id: "S6", name: "Jmoon极萌/ulike", floor: 1, type: "Store"),
    Store(id: "S7", name: "LANCASTER", floor: 1, type: "Store"),
    Store(id: "S8", name: "", floor: 1, type: "Store"),
    Store(id: "S9", name: "COACH", floor: 1, type: "Store"),
    Store(id: "S10", name: "Abercrombie&Fitch", floor: 1, type: "Store"),
    Store(id: "S11", name: "Ciao Panificio by B&C", floor: 1, type: "Store"),
    Store(id: "S12", name: "", floor: 1, type: "Store"),
    Store(id: "S13", name: "", floor: 1, type: "Store"),
    Store(id: "S14", name: "Venchi", floor: 1, type: "Store"),
    Store(id: "S15", name: "SHAKE SHACK", floor: 1, type: "Store"),
    Store(id: "S16", name: "SHAKE SHACK", floor: 1, type: "Store"),
    Store(id: "S17", name: "SEPHORA", floor: 1, type: "Store"),
    Store(id: "S18", name: "HOKA", floor: 1, type: "Store"),
    Store(id: "S19", name: "gaga鲜语", floor: 1, type: "Store"),
    Store(id: "S20", name: "星巴克臻选", floor: 1, type: "Store"),
    Store(id: "S21", name: "KLATTER MUSEN", floor: 1, type: "Store"),
    Store(id: "S22", name: "HELLY HANSEN", floor: 1, type: "Store"),
    Store(id: "S23", name: "Massimo Dutti", floor: 1, type: "Store"),
    Store(id: "S24", name: "i.t(含Fred Perry)", floor: 1, type: "Store"),
    Store(id: "S25", name: "APM Monaco", floor: 1, type: "Store"),
    Store(id: "S26", name: "Mardi Mercredi", floor: 1, type: "Store"),
    Store(id: "S27", name: "Mardi Mercredi", floor: 1, type: "Store"),
    Store(id: "S28", name: "DESCENTE迪桑特", floor: 1, type: "Store"),
    Store(id: "S29", name: "DESCENTE迪桑特", floor: 1, type: "Store"),
    Store(id: "S30", name: "YSL", floor: 1, type: "Store"),
    Store(id: "S31", name: "Shu uemura", floor: 1, type: "Store"),
    Store(id: "S32", name: "DESCENTE迪桑特", floor: 1, type: "Store"),
    Store(id: "S33", name: "GIVENCHY纪梵希", floor: 1, type: "Store"),
    Store(id: "S34", name: "ON昂跑", floor: 1, type: "Store"),
    Store(id: "S35", name: "LANCOME", floor: 1, type: "Store"),
    Store(id: "S36", name: "ON昂跑", floor: 1, type: "Store"),
    Store(id: "S37", name: "悦木之源ORIGINS", floor: 1, type: "Store"),
    Store(id: "S38", name: "MAC", floor: 1, type: "Store"),
    Store(id: "S39", name: "AAPE", floor: 1, type: "Store"),
    Store(id: "S40", name: "GROTTO", floor: 1, type: "Store"),
    Store(id: "S41", name: "DIOR", floor: 1, type: "Store"),
    Store(id: "S42", name: "DIOR", floor: 1, type: "Store"),
    Store(id: "S43", name: "娇韵诗CLARINS", floor: 1, type: "Store"),
    Store(id: "S44", name: "Guerlain娇兰", floor: 1, type: "Store"),
    Store(id: "S45", name: "SMFK", floor: 1, type: "Store"),
    Store(id: "S46", name: "Estée Lauder雅诗兰黛", floor: 1, type: "Store"),
    Store(id: "S47", name: "JO MALONE", floor: 1, type: "Store"),
    Store(id: "S48", name: "lululemon", floor: 1, type: "Store"),
    Store(id: "S49", name: "Chloé", floor: 1, type: "Store"),
  ];

  static List<Store> searchStores(String query) {
    if (query.isEmpty) return [];
    
    return stores.where((store) {
      if (store.name.isEmpty) return false;
      return store.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

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
  String selectedFloor = 'F1';
  bool isFullScreen = false;
  final List<String> floors = ['F6', 'F5', 'F4', 'F3', 'F2', 'F1', 'B1', 'B2'];

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return Scaffold(
        body: Stack(
          children: [
            _buildFullScreenMap(),
            _buildExitFullScreenButton(),
          ],
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF9B59B6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildMapArea(),
                    _buildFloorNavigation(),
                    _buildRightSideButtons(),
                  ],
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  // 左侧楼层导航
  // 左侧楼层导航 - 缩小版本
Widget _buildFloorNavigation() {
  return Positioned(
    left: 16,
    top: 20,
    child: Container(
      width: 45, // 缩小宽度
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
          // 指南针图标 - 缩小
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.navigation,
              color: Colors.white,
              size: 16, // 缩小图标
            ),
          ),
          
          // 楼层按钮 - 缩小版本
          Container(
            constraints: const BoxConstraints(maxHeight: 320), // 减小高度
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
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
                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 6), // 减小padding
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
                        fontSize: 11, // 缩小字体
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
    margin: const EdgeInsets.all(12), // 减小margin
    padding: const EdgeInsets.symmetric(vertical: 12), // 减小padding
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
      print('点击了: $label');
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6), // 减小padding
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18, // 缩小图标
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9, // 缩小字体
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}


// 顶部搜索栏
Widget _buildSearchBar() {
  return Container(
    margin: const EdgeInsets.all(12), 
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 20, // 缩小图标
          ),
        ),
        const SizedBox(width: 8), 
        
        // 搜索输入框
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 减小padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20), // 稍微减小圆角
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.grey, size: 18), // 缩小图标
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Search...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // 缩小字体
                      ),
                    ),
                  ),
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 18), // 缩小图标
                  const SizedBox(width: 6),
                  const Icon(Icons.mic, color: Colors.grey, size: 18), // 缩小图标
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  // 地图区域
  Widget _buildMapArea() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double containerHeight = constraints.maxHeight;
          double containerWidth = constraints.maxWidth;
          
          double mapAspectRatio = 2.0 / 1.0;
          double mapHeight = containerHeight;
          double mapWidth = mapHeight * mapAspectRatio;
          
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
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

  // 右侧功能按钮
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
          
          double mapAspectRatio = 2.0 / 1.0;
          double mapWidth = containerWidth;
          double mapHeight = mapWidth * mapAspectRatio;
          
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            boundaryMargin: EdgeInsets.zero,
            panEnabled: true,
            scaleEnabled: true,
            constrained: false,
            child: SizedBox(
              width: mapHeight,
              height: mapHeight,
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
      top: 50,
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

  // 进入全屏模式
  void _enterFullScreen() {
    setState(() {
      isFullScreen = true;
    });
  }

  // 退出全屏模式
  void _exitFullScreen() {
    setState(() {
      isFullScreen = false;
    });
  }
}

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
        
        // 搜索输入框 - 缩小版本
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

  // 搜索结果
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
                          subtitle: Text(
                            '${store.floor}楼 · 编号: ${store.id}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('选择了店铺: ${store.name} (${store.id})'),
                              ),
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