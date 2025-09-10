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
  final Store? targetStore;  // 目标店铺
  final int? targetFloor;    // 目标楼层
  
  const HomePage({
    Key? key,
    this.targetStore,
    this.targetFloor,
  }) : super(key: key);

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
    _loadAllData().then((_) {
      // 数据加载完成后，如果有目标店铺，则显示
      if (widget.targetStore != null && widget.targetFloor != null) {
        // 先切换楼层
        setState(() {
          selectedFloor = _getFloorString(widget.targetFloor!);
          selectedStore = widget.targetStore;  // 设置选中的店铺，显示信息卡片
        });
        // 不需要移动地图，保持默认位置即可
        // 店铺信息卡片会自动显示
      }
    });
  }
  // 添加居中显示店铺的方法
  void _centerOnStore(Store store) {
    if (!mounted) return;
    
    // 设置楼层
    if (widget.targetFloor != null) {
      setState(() {
        selectedFloor = _getFloorString(widget.targetFloor!);
        selectedStore = store;  // 设置选中的店铺
      });
    }
    
    // 计算店铺位置并居中
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerMapOnStore(store);
    });
  }

  // 添加楼层数字转字符串的方法
  String _getFloorString(int floorNumber) {
    switch (floorNumber) {
      case 6: return 'F6';
      case 5: return 'F5';
      case 4: return 'F4';
      case 3: return 'F3';
      case 2: return 'F2';
      case 1: return 'F1';
      case -1: return 'B1';
      case -2: return 'B2';
      default: return 'F1';
    }
  }

  // 添加地图居中方法
  void _centerMapOnStore(Store store) {
    // 查找店铺的GeoJSON数据以获取准确的坐标
    GeoJsonFeature? geoStore;
    try {
      geoStore = GeoJsonData.stores.firstWhere((s) => s.id == store.id);
    } catch (e) {
      print('未找到店铺的地理数据: ${store.id}');
      return;
    }
    
    // 计算店铺中心点
    Point? storeCenter = _calculateStoreCenter(geoStore.coordinates);
    if (storeCenter == null) return;
    
    // 获取地图边界
    final bounds = _calculateMapBounds();
    final boundsWidth = bounds['maxX']! - bounds['minX']!;
    final boundsHeight = bounds['maxY']! - bounds['minY']!;
    
    // 获取当前widget的大小
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final widgetSize = renderBox.size;
    double containerHeight = widgetSize.height;
    double mapAspectRatio = 2.0 / 1.0;
    double mapHeight = containerHeight;
    double mapWidth = mapHeight * mapAspectRatio;
    
    final scaleY = mapHeight / boundsHeight;
    final mapScale = scaleY;
    
    // 计算居中所需的变换
    final centerX = mapWidth / 2;
    final centerY = mapHeight / 2;
    
    // 将店铺坐标转换到屏幕坐标
    double screenX = (storeCenter.x - bounds['minX']!) * mapScale;
    double screenY = (storeCenter.y - bounds['minY']!) * mapScale;
    
    // 计算需要的平移量，使店铺居中
    double translateX = centerX - screenX;
    double translateY = centerY - screenY;
    
    // 创建变换矩阵
    final Matrix4 matrix = Matrix4.identity()
      ..translate(translateX, translateY);
    
    // 应用变换
    _transformationController.value = matrix;
  }



  // 修改 _loadAllData 方法，返回 Future
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
          _isDataLoaded = true;
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
                  // 添加店铺信息弹窗
                  if (selectedStore != null)
                    _buildStoreInfoCard(),
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

// 添加店铺信息卡片组件
Widget _buildStoreInfoCard() {
  return Positioned(
    left: 16,
    right: 16,
    bottom: 16,  // 在底部导航栏上方
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    selectedStore = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '楼层: ${selectedStore!.floor}楼',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '店铺编号: ${selectedStore!.id}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '类型: ${selectedStore!.type}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 实现导航功能
                    print('导航到: ${selectedStore!.name}');
                  },
                  icon: const Icon(Icons.navigation, size: 16),
                  label: const Text('导航'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 实现详情功能
                    print('查看详情: ${selectedStore!.name}');
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('详情'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

    //点击店铺显示信息
  Store? selectedStore;  // 当前选中的店铺
  
  // 添加获取点击位置对应店铺的方法
  Store? _getStoreAtPosition(Offset localPosition, Size widgetSize) {
    // 获取当前变换矩阵
    final Matrix4 transform = _transformationController.value;
    
    // 计算地图边界
    final bounds = _calculateMapBounds();
    final boundsWidth = bounds['maxX']! - bounds['minX']!;
    final boundsHeight = bounds['maxY']! - bounds['minY']!;
    
    // 计算地图缩放比例
    double containerHeight = widgetSize.height;
    double mapAspectRatio = 2.0 / 1.0;
    double mapHeight = containerHeight;
    double mapWidth = mapHeight * mapAspectRatio;
    
    final scaleY = mapHeight / boundsHeight;
    final mapScale = scaleY;
    
    // 逆变换：从屏幕坐标到地图坐标
    final Matrix4 inverseTransform = Matrix4.inverted(transform);
    final transformedPoint = MatrixUtils.transformPoint(
      inverseTransform, 
      localPosition
    );
    
    // 转换到地图坐标系
    final centerX = mapWidth / 2;
    final centerY = mapHeight / 2;
    
    double mapX = (transformedPoint.dx - (centerX - (boundsWidth * mapScale / 2))) / mapScale + bounds['minX']!;
    double mapY = (transformedPoint.dy - (centerY - (boundsHeight * mapScale / 2))) / mapScale + bounds['minY']!;
    
    // 查找点击位置的店铺
    for (var geoStore in GeoJsonData.stores) {
      if (geoStore.floor == _getFloorNumber(selectedFloor)) {
        // 检查点是否在店铺多边形内
        if (_isPointInStore(Point(mapX, mapY), geoStore.coordinates)) {
          // 从StoreData中找到对应的Store对象
          try {
            return StoreData.stores.firstWhere((s) => s.id == geoStore.id);
          } catch (e) {
            // 如果找不到，创建一个临时的Store对象
            return Store(
              id: geoStore.id,
              name: geoStore.name ?? '未知店铺',
              floor: geoStore.floor,
              type: geoStore.type,
              location: _calculateStoreCenter(geoStore.coordinates),
            );
          }
        }
      }
    }
    return null;
  }
  
  // 判断点是否在店铺多边形内
  bool _isPointInStore(Point point, List<List<List<Point>>> coordinates) {
    for (var polygon in coordinates) {
      for (var ring in polygon) {
        if (_isPointInPolygon(point, ring)) {
          return true;
        }
      }
    }
    return false;
  }
  
  // 射线法判断点是否在多边形内
  bool _isPointInPolygon(Point point, List<Point> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      Point p1 = polygon[i];
      Point p2 = polygon[(i + 1) % polygon.length];
      
      if ((p1.y > point.y) != (p2.y > point.y)) {
        double xIntersection = (p2.x - p1.x) * (point.y - p1.y) / (p2.y - p1.y) + p1.x;
        if (point.x < xIntersection) {
          intersections++;
        }
      }
    }
    return intersections % 2 == 1;
  }
  
  // 计算店铺中心点
  Point? _calculateStoreCenter(List<List<List<Point>>> coordinates) {
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
  
  // 计算地图边界
  Map<String, double> _calculateMapBounds() {
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    int currentFloor = _getFloorNumber(selectedFloor);
    
    for (var barrier in GeoJsonData.barriers) {
      if (barrier.floor == currentFloor) {
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
      if (store.floor == currentFloor) {
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
              child: GestureDetector(
                onTapUp: (TapUpDetails details) {
                  // 获取点击位置对应的店铺
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                  final store = _getStoreAtPosition(localPosition, renderBox.size);
                  
                  if (store != null) {
                    setState(() {
                      selectedStore = store;
                    });
                  }
                },
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 3.0,
                  boundaryMargin: EdgeInsets.zero,
                  panEnabled: true,
                  scaleEnabled: true,
                  constrained: false,
                  onInteractionUpdate: (details) {
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
                        viewerScale: _currentScale,
                        selectedStoreId: selectedStore?.id,  // 传递选中的店铺ID
                      ),
                      size: Size(mapWidth, mapHeight),
                    ),
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