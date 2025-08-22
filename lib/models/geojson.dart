import 'package:flutter/services.dart';
import 'dart:convert';
import 'point.dart';

// GeoJSON数据模型
class GeoJsonFeature {
  final String id;
  final String type;
  final int floor;
  final String? name;
  final List<List<List<Point>>> coordinates; // 支持MultiPolygon和Polygon

  GeoJsonFeature({
    required this.id,
    required this.type,
    required this.floor,
    this.name,
    required this.coordinates,
  });
}

class GeoJsonData {
  static List<GeoJsonFeature> barriers = [];
  static List<GeoJsonFeature> stores = [];
  static bool isLoaded = false;

  static Future<void> loadGeoJsonData() async {
    if (isLoaded) return;

    try {
      // 加载Barrier数据
      final barrierString = await rootBundle.loadString('assets/geojson/Barrier.geojson');
      final barrierJson = json.decode(barrierString);
      
      for (var feature in barrierJson['features']) {
        final coords = feature['geometry']['coordinates'] as List;
        List<List<List<Point>>> parsedCoords = [];
        
        // 处理MultiPolygon格式 - 修复上下颠倒问题
        for (var polygon in coords) {
          List<List<Point>> polygonRings = [];
          for (var ring in polygon) {
            List<Point> ringPoints = [];
            for (var coord in ring) {
              // 修复上下颠倒：将Y坐标取负值
              ringPoints.add(Point(coord[0].toDouble(), -coord[1].toDouble()));
            }
            polygonRings.add(ringPoints);
          }
          parsedCoords.add(polygonRings);
        }
        
        barriers.add(GeoJsonFeature(
          id: feature['properties']['id'],
          type: feature['properties']['type'],
          floor: int.parse(feature['properties']['floor']),
          coordinates: parsedCoords,
        ));
      }

      // 加载Store数据
      final storeString = await rootBundle.loadString('assets/geojson/Store1.geojson');
      final storeJson = json.decode(storeString);
      
      for (var feature in storeJson['features']) {
        final coords = feature['geometry']['coordinates'][0] as List; // Polygon格式
        List<Point> ringPoints = [];
        for (var coord in coords) {
          // 修复上下颠倒：将Y坐标取负值
          ringPoints.add(Point(coord[0].toDouble(), -coord[1].toDouble()));
        }
        
        stores.add(GeoJsonFeature(
          id: feature['properties']['id'],
          type: feature['properties']['type'],
          floor: feature['properties']['floor'],
          name: feature['properties']['name'],
          coordinates: [[ringPoints]], // 包装成MultiPolygon格式
        ));
      }
      
      isLoaded = true;
    } catch (e) {
      // 在实际应用中，你可能想要更好地处理这个错误
      print('Error loading GeoJSON data: $e');
    }
  }
}
