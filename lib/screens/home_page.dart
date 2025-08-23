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
  Store? selectedStore; // 选中的店铺
  List<String> highlightedAreas = []; // 高亮区域列表

  // 添加这两个变量来跟踪缩放和平移
  double _currentScale = 1.0;
  late TransformationController _transformationController;
  

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
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
              if (selectedStore != null) _buildStoreInfo(),
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
  return SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: FutureBuilder<void>(
      future: GeoJsonData.loadGeoJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('加载地图数据失败: ${snapshot.error}'),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            double containerHeight = constraints.maxHeight;
            double containerWidth = constraints.maxWidth;
            
            double mapAspectRatio = 2.0 / 1.0;
            double mapHeight = containerHeight;
            double mapWidth = mapHeight * mapAspectRatio;
            
            return GestureDetector(
              onTapUp: (details) {
                // 处理地图点击事件
                _handleMapTap(details.localPosition, mapWidth, mapHeight, containerWidth, containerHeight);
              },
              child: InteractiveViewer(
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
                  child: CustomPaint(
                    painter: MapPainter(
                      floor: _getFloorNumber(selectedFloor),
                      scale: _currentScale,
                      highlightedAreas: highlightedAreas,
                      onStoreTap: (store) {
                        setState(() {
                          selectedStore = store;
                          // 获取店铺所在的可行走区域
                          final areaId = WalkableAreaData.findNearestWalkableArea(store.id);
                          if (areaId != null) {
                            highlightedAreas = [areaId];
                          } else {
                            highlightedAreas = [];
                          }
                        });
                      },
                    ),
                    size: Size(mapWidth, mapHeight),
                  ),
                ),
              ),
            );
          },
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

  // 处理地图点击事件
  void _handleMapTap(Offset localPosition, double mapWidth, double mapHeight, double containerWidth, double containerHeight) {
    // 计算地图边界
    final bounds = _calculateMapBounds();
    final boundsWidth = bounds['maxX']! - bounds['minX']!;
    final boundsHeight = bounds['maxY']! - bounds['minY']!;
    
    // 计算缩放比例
    final scaleX = mapWidth / boundsWidth;
    final scaleY = mapHeight / boundsHeight;
    final mapScale = math.min(scaleX, scaleY);
    
    // 获取InteractiveViewer的变换矩阵
    final matrix = _transformationController.value;
    
    // 应用变换矩阵的逆矩阵来转换点击坐标
    final double translateX = matrix[12];
    final double translateY = matrix[13];
    final double scale = matrix[0]; // 假设x和y方向的缩放相同
    
    // 转换为地图坐标系中的点 (考虑InteractiveViewer的变换)
    final double transformedX = (localPosition.dx - translateX) / scale;
    final double transformedY = (localPosition.dy - translateY) / scale;
    
    // 转换为地图坐标
    final mapX = transformedX / mapScale + bounds['minX']!;
    final mapY = transformedY / mapScale + bounds['minY']!;
    
    // 检查是否点击了某个店铺
    _checkStoreTap(Point(mapX, mapY));
  }
  
  // 计算地图边界
  Map<String, double> _calculateMapBounds() {
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // 计算所有特征的边界
    for (var barrier in GeoJsonData.barriers) {
      if (barrier.floor == _getFloorNumber(selectedFloor)) {
        for (var polygon in barrier.coordinates) {
          for (var ring in polygon) {
            for (var point in ring) {
              minX = math.min(minX, point.x);
              maxX = math.max(maxX, point.x);
              minY = math.min(minY, point.y);
              maxY = math.max(maxY, point.y);
            }
          }
        }
      }
    }

    for (var store in GeoJsonData.stores) {
      if (store.floor == _getFloorNumber(selectedFloor)) {
        for (var polygon in store.coordinates) {
          for (var ring in polygon) {
            for (var point in ring) {
              minX = math.min(minX, point.x);
              maxX = math.max(maxX, point.x);
              minY = math.min(minY, point.y);
              maxY = math.max(maxY, point.y);
            }
          }
        }
      }
    }

    return {
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
    };
  }
  
  // 检查是否点击了店铺
  void _checkStoreTap(Point tapPoint) {
    Store? newSelectedStore;
    String? newHighlightedAreaId;
    
    for (var geoStore in GeoJsonData.stores) {
      if (geoStore.floor == _getFloorNumber(selectedFloor) && geoStore.name != null && geoStore.name!.isNotEmpty) {
        // 检查点击点是否在店铺多边形内
        bool isInside = false;
        for (var polygon in geoStore.coordinates) {
          for (var ring in polygon) {
            if (WalkableAreaData.isPointInPolygon(tapPoint, ring)) {
              isInside = true;
              break;
            }
          }
          if (isInside) break;
        }
        
        if (isInside) {
          // 创建Store对象
          newSelectedStore = Store(
            id: geoStore.id,
            name: geoStore.name ?? '',
            floor: geoStore.floor,
            type: geoStore.type,
            location: _calculatePolygonCenter(geoStore.coordinates),
          );
          // 获取店铺所在的可行走区域
          newHighlightedAreaId = WalkableAreaData.findNearestWalkableArea(geoStore.id);
          break;
        }
      }
    }
    
    // 更新状态
    setState(() {
      selectedStore = newSelectedStore;
      if (newHighlightedAreaId != null) {
        highlightedAreas = [newHighlightedAreaId];
      } else {
        highlightedAreas = [];
      }
    });
  }

  // 计算多边形中心点
  Point? _calculatePolygonCenter(List<List<List<Point>>> coordinates) {
    double totalX = 0;
    double totalY = 0;
    int pointCount = 0;

    for (var polygon in coordinates) {
      for (var ring in polygon) {
        for (var point in ring) {
          totalX += point.x;
          totalY += point.y;
          pointCount++;
        }
      }
    }

    if (pointCount == 0) return null;
    return Point(totalX / pointCount, totalY / pointCount);
  }

  // 退出全屏模式
  void _exitFullScreen() {
    setState(() {
      isFullScreen = false;
    });
  }

  // 构建店铺信息显示区域
  Widget _buildStoreInfo() {
    if (selectedStore == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedStore!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStore = null;
                    highlightedAreas = [];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedStore!.floor}楼 · 编号: ${selectedStore!.id}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (highlightedAreas.isNotEmpty)
            Text(
              '最近可行走区域: ${highlightedAreas.first}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}
