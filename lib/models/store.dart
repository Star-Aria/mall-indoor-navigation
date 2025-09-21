import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'point.dart';

// 数据模型类
class Store {
  final String id;
  final String name;
  final int floor;
  final String type;
  final String type2;  // 新增：具体类型
  final Point? location;

  Store({
    required this.id,
    required this.name,
    required this.floor,
    required this.type,
    required this.type2,  // 新增参数
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
          type2: type2,  // 新增
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

  static List<Store> searchStores(String query) {
    if (query.isEmpty) return [];
    
    return stores.where((store) {
      if (store.name.isEmpty) return false;
      return store.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}