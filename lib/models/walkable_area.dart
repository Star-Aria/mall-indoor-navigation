import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'point.dart';
import 'store.dart';

class WalkableArea {
  final String id;
  final int floor;
  final List<List<Point>> coordinates; // 多边形坐标
  
  WalkableArea({
    required this.id,
    required this.floor,
    required this.coordinates,
  });
}

class WalkableAreaData {
  static List<WalkableArea> areas = [];
  static bool isLoaded = false;

  // 从GeoJSON文件加载数据
  static Future<void> loadWalkableAreaData() async {
    if (isLoaded) return;

    try {
      // 加载WalkableArea数据
      final String response = await rootBundle.loadString('assets/geojson/WalkableArea.geojson');
      final Map<String, dynamic> data = json.decode(response);
      
      areas.clear();
      
      for (var feature in data['features']) {
        final String id = feature['properties']['id'] ?? '';
        final int floor = feature['properties']['floor'] ?? 1;
        final coords = feature['geometry']['coordinates'] as List;
        
        List<List<Point>> parsedCoords = [];
        
        // 处理Polygon或MultiPolygon格式
        if (feature['geometry']['type'] == 'Polygon') {
          for (var ring in coords) {
            List<Point> ringPoints = [];
            for (var coord in ring) {
              // 修复上下颠倒：将Y坐标取负值
              ringPoints.add(Point(coord[0].toDouble(), -coord[1].toDouble()));
            }
            parsedCoords.add(ringPoints);
          }
        } else if (feature['geometry']['type'] == 'MultiPolygon') {
          // 对于MultiPolygon，取第一个polygon
          for (var ring in coords[0]) {
            List<Point> ringPoints = [];
            for (var coord in ring) {
              // 修复上下颠倒：将Y坐标取负值
              ringPoints.add(Point(coord[0].toDouble(), -coord[1].toDouble()));
            }
            parsedCoords.add(ringPoints);
          }
        }
        
        areas.add(WalkableArea(
          id: id,
          floor: floor,
          coordinates: parsedCoords,
        ));
      }
      
      isLoaded = true;
    } catch (e) {
      print('Error loading WalkableArea data: $e');
      // 如果加载失败，使用空列表
      areas = [];
    }
  }

  // 计算两点之间的距离
  static double distance(Point p1, Point p2) {
    double dx = p1.x - p2.x;
    double dy = p1.y - p2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  // 计算点到线段的最短距离
  static double pointToLineSegment(Point point, Point lineStart, Point lineEnd) {
    double A = point.x - lineStart.x;
    double B = point.y - lineStart.y;
    double C = lineEnd.x - lineStart.x;
    double D = lineEnd.y - lineStart.y;

    double dot = A * C + B * D;
    double lenSq = C * C + D * D;
    
    if (lenSq < 1e-10) {
      return distance(point, lineStart);
    }
    
    double param = dot / lenSq;

    Point closest;
    if (param < 0) {
      closest = lineStart;
    } else if (param > 1) {
      closest = lineEnd;
    } else {
      closest = Point(lineStart.x + param * C, lineStart.y + param * D);
    }

    return distance(point, closest);
  }

  // 计算点到多边形的最短距离
  static double distanceToPolygon(Point point, List<Point> polygon) {
    if (polygon.isEmpty) return double.infinity;
    
    double minDistance = double.infinity;
    
    for (int i = 0; i < polygon.length; i++) {
      Point p1 = polygon[i];
      Point p2 = polygon[(i + 1) % polygon.length];
      double dist = pointToLineSegment(point, p1, p2);
      minDistance = math.min(minDistance, dist);
    }
    
    return minDistance;
  }

  // 查找最近的可行走区域
  static String? findNearestWalkableArea(String storeId) {
    Store? store;
    try {
      store = StoreData.stores.firstWhere((s) => s.id == storeId);
    } catch (e) {
      return null;
    }
    
    if (store?.location == null) return null;
    Point storeLocation = store!.location!;

    double minDistance = double.infinity;
    String? nearestAreaId;

    for (WalkableArea area in areas) {
      if (area.coordinates.isNotEmpty) {
        double dist = distanceToPolygon(storeLocation, area.coordinates[0]);
        if (dist < minDistance) {
          minDistance = dist;
          nearestAreaId = area.id;
        }
      }
    }

    return nearestAreaId;
  }

  // 获取店铺周围的可行走区域
  static List<String> getNearbyWalkableAreas(String storeId, {double radius = 100.0}) {
    Store? store;
    try {
      store = StoreData.stores.firstWhere((s) => s.id == storeId);
    } catch (e) {
      return [];
    }
    
    if (store?.location == null) return [];
    Point storeLocation = store!.location!;

    List<String> nearbyAreas = [];
    
    for (WalkableArea area in areas) {
      if (area.coordinates.isNotEmpty) {
        double dist = distanceToPolygon(storeLocation, area.coordinates[0]);
        if (dist <= radius) {
          nearbyAreas.add(area.id);
        }
      }
    }
    
    // 按距离排序
    nearbyAreas.sort((a, b) {
      WalkableArea? areaA = getAreaById(a);
      WalkableArea? areaB = getAreaById(b);
      if (areaA == null || areaB == null) return 0;
      
      double distA = distanceToPolygon(storeLocation, areaA.coordinates[0]);
      double distB = distanceToPolygon(storeLocation, areaB.coordinates[0]);
      return distA.compareTo(distB);
    });
    
    return nearbyAreas;
  }

  // 获取区域统计信息
  static Map<String, int> getAreaStatistics() {
    Map<int, int> floorCounts = {};
    for (WalkableArea area in areas) {
      floorCounts[area.floor] = (floorCounts[area.floor] ?? 0) + 1;
    }
    
    return {
      'totalAreas': areas.length,
      'floor1Areas': floorCounts[1] ?? 0,
      'totalStores': StoreData.stores.length,
    };
  }

  // 获取指定楼层的可行走区域
  static List<WalkableArea> getAreasForFloor(int floor) {
    return areas.where((area) => area.floor == floor).toList();
  }

  // 根据ID获取可行走区域
  static WalkableArea? getAreaById(String id) {
    try {
      return areas.firstWhere((area) => area.id == id);
    } catch (e) {
      return null;
    }
  }

  // 计算可行走区域的中心点
  static Point? getAreaCenter(String areaId) {
    WalkableArea? area = getAreaById(areaId);
    if (area == null || area.coordinates.isEmpty) return null;

    List<Point> polygon = area.coordinates[0];
    if (polygon.isEmpty) return null;

    double sumX = 0;
    double sumY = 0;
    for (Point p in polygon) {
      sumX += p.x;
      sumY += p.y;
    }

    return Point(sumX / polygon.length, sumY / polygon.length);
  }

  // 检查点是否在多边形内部
  static bool isPointInPolygon(Point point, List<Point> polygon) {
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
}