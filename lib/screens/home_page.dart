import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../widgets/map_painter.dart';
import '../models/store.dart';
import '../models/walkable_area.dart';
import '../models/geojson.dart';
import '../models/point.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  String selectedFloor = 'F1';
  bool isFullScreen = false;
  final List<String> floors = ['F6', 'F5', 'F4', 'F3', 'F2', 'F1', 'B1', 'B2'];
  bool _isDataLoaded = false; // 添加数据加载标志

  // 添加这两个变量来跟踪缩放和平移
  double _currentScale = 1.0;
  late TransformationController _transformationController;
  

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
    _loadAllData(); // 添加数据加载
  }

  // 添加数据加载方法
  Future<void> _loadAllData() async {
    try {
      await Future.wait([
        GeoJsonData.loadGeoJsonData(),
        StoreData.loadStoreData(),
        WalkableAreaData.loadWalkableAreaData(),
      ]);
      
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isDataLoaded = true; // 即使失败也设置为true，让用户看到错误信息
        });
      }
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final matrix = _transformationController.value;
    // 移除类型转换，直接使用matrix对象
    // 增加阈值，减少更新频率
    if ((_currentScale - 1.0).abs() > 0.3) { 
      setState(() {
        _currentScale = 1.0;
      });
    }
  }

  int _getFloorNumber(String floor) {
    switch (floor) {
      case 'F6': return 6;
      case 'F5': return 5;
      case 'F4': return 4;
      case 'F3': return 3;
      case 'F2': return 2;
      case 'F1': return 1;
      case 'B1': return -1;
      case 'B2': return -2;
      default: return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 数据加载中显示加载界面
    if (!_isDataLoaded) {
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  '正在加载地图数据...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
              Color.fromARGB(255, 83, 186, 255),  
              Color.fromARGB(255, 197, 127, 250),  
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
  Widget _buildFloorNavigation() {
    return Positioned(
      left: 16,
      top: 20,
      child: Container(
        width: 45, 
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
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 16,
              ),
            ),
            
            // 楼层按钮
            Container(
              constraints: const BoxConstraints(maxHeight: 320), 
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
                      padding: const EdgeInsets.symmetric(vertical: 6), 
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
                          fontSize: 11, 
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
      margin: const EdgeInsets.all(12), 
      padding: const EdgeInsets.symmetric(vertical: 12), 
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
            padding: const EdgeInsets.all(6), 
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18, 
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9, 
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
              size: 20, 
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20), 
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.grey, size: 18), 
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Search...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14, 
                        ),
                      ),
                    ),
                    const Icon(Icons.camera_alt, color: Colors.grey, size: 18), 
                    const SizedBox(width: 6),
                    const Icon(Icons.mic, color: Colors.grey, size: 18), 
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double containerHeight = constraints.maxHeight;
          double mapAspectRatio = 2.0 / 1.0;
          double mapHeight = containerHeight;
          double mapWidth = mapHeight * mapAspectRatio;
          
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 3.0,
                boundaryMargin: EdgeInsets.zero,
                panEnabled: true,
                scaleEnabled: true,
                constrained: false,
                onInteractionUpdate: (details) {
                  // 获取当前缩放值
                  setState(() {
                    _currentScale = _transformationController.value.getMaxScaleOnAxis();
                  });
                },
                child: Container(
                  width: mapWidth,
                  height: mapHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: MapPainter(
                      floor: _getFloorNumber(selectedFloor),
                      scale: 1.0,
                      viewerScale: _currentScale, // 传递 InteractiveViewer 的缩放值
                    ),
                    size: Size(mapWidth, mapHeight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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