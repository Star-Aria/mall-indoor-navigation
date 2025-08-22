import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' show PointMode, Path, Canvas, Offset, Size, Rect, RRect, Radius, PathFillType, TileMode, Gradient, Color, TextDirection, Image, Vertices, BlendMode, FilterQuality, StrokeCap, StrokeJoin, PaintingStyle, TextAlign, TextBaseline, TextBox, Shadow, MaskFilter, ColorFilter, ImageFilter, Shader, Paint, TextStyle, TextPainter;
import '../models/point.dart';
import '../models/geojson.dart';
import '../models/store.dart';
import '../models/walkable_area.dart';

// 自定义地图画板
class MapPainter extends CustomPainter {
  final int floor;
  final double scale;
  final Offset offset;
  final List<String> highlightedAreas; // 添加高亮区域参数
  final Function(Store)? onStoreTap; // 添加店铺点击回调

  MapPainter({
    required this.floor,
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.highlightedAreas = const [], // 初始化高亮区域
    this.onStoreTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算坐标转换参数
    final bounds = _calculateBounds();
    final boundsWidth = bounds['maxX']! - bounds['minX']!;
    final boundsHeight = bounds['maxY']! - bounds['minY']!;
    
    // 计算缩放比例，使地图高度撑满容器
    final scaleX = size.width / boundsWidth;
    final scaleY = size.height / boundsHeight;
    final mapScale = scaleY * scale; // 使用高度作为基准，让地图高度填满容器
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.save();
    canvas.translate(
      centerX - (boundsWidth * mapScale / 2) + offset.dx,
      centerY - (boundsHeight * mapScale / 2) + offset.dy,
    );
    canvas.scale(mapScale);
    canvas.translate(-bounds['minX']!, -bounds['minY']!);

    // 绘制背景（可行走区域）
    _drawWalkableArea(canvas, size, bounds);
    
    // 绘制障碍物
    _drawBarriers(canvas);
    
    // 绘制商店
    _drawStores(canvas);
    
    // 智能绘制商店标签
    _drawStoreLabelsIntelligent(canvas, size, mapScale, offset);
    
    canvas.restore();
  }

  void _drawStoreLabelsIntelligent(Canvas canvas, Size size, double mapScale, Offset offset) {
    for (var store in GeoJsonData.stores) {
      if (store.floor == floor && store.name != null && store.name!.isNotEmpty) {
        // 计算商店中心点
        Point? center = _calculatePolygonCenter(store.coordinates);
        if (center != null) {
          // 绘制商店名称
          final textPainter = TextPainter(
            text: TextSpan(
              text: store.name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          final textOffset = Offset(
            center.x - textPainter.width / 2,
            center.y - textPainter.height / 2,
          );
          
          // 绘制文字背景
          final bgPaint = Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.fill;
          
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                textOffset.dx - 2,
                textOffset.dy - 1,
                textPainter.width + 4,
                textPainter.height + 2,
              ),
              const Radius.circular(2),
            ),
            bgPaint,
          );
          
          textPainter.paint(canvas, textOffset);
        }
      }
    }
  }

  Map<String, double> _calculateBounds() {
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // 计算所有特征的边界
    for (var barrier in GeoJsonData.barriers) {
      if (barrier.floor == floor) {
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
      if (store.floor == floor) {
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

  void _drawWalkableArea(Canvas canvas, Size size, Map<String, double> bounds) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 225, 246, 215)
      ..style = PaintingStyle.fill;

    // 绘制整个区域作为可行走区域背景
    final rect = Rect.fromLTRB(
      bounds['minX']!,
      bounds['minY']!,
      bounds['maxX']!,
      bounds['maxY']!,
    );
    canvas.drawRect(rect, paint);

    // 绘制高亮区域
    if (highlightedAreas.isNotEmpty) {
      final highlightPaint = Paint()
        ..color = const Color.fromARGB(100, 0, 100, 255) // 半透明蓝色
        ..style = PaintingStyle.fill;

      for (var area in WalkableAreaData.areas) {
        if (area.floor == floor && highlightedAreas.contains(area.id)) {
          for (var polygon in area.coordinates) {
            final path = Path();
            if (polygon.isNotEmpty) {
              path.moveTo(polygon[0].x, polygon[0].y);
              for (int i = 1; i < polygon.length; i++) {
                path.lineTo(polygon[i].x, polygon[i].y);
              }
              path.close();
              canvas.drawPath(path, highlightPaint);
            }
          }
        }
      }
    }
  }

  void _drawBarriers(Canvas canvas) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 235, 235, 235) // 暗灰色
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color.fromARGB(255, 102, 102, 102) // 深灰色边框
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var barrier in GeoJsonData.barriers) {
      if (barrier.floor == floor) {
        for (var polygon in barrier.coordinates) {
          for (var ring in polygon) {
            final path = Path();
            if (ring.isNotEmpty) {
              path.moveTo(ring[0].x, ring[0].y);
              for (int i = 1; i < ring.length; i++) {
                path.lineTo(ring[i].x, ring[i].y);
              }
              path.close();
              canvas.drawPath(path, paint);
              canvas.drawPath(path, strokePaint);
            }
          }
        }
      }
    }
  }

  void _drawStores(Canvas canvas) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 132, 194, 244)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var store in GeoJsonData.stores) {
      if (store.floor == floor) {
        for (var polygon in store.coordinates) {
          for (var ring in polygon) {
            final path = Path();
            if (ring.isNotEmpty) {
              path.moveTo(ring[0].x, ring[0].y);
              for (int i = 1; i < ring.length; i++) {
                path.lineTo(ring[i].x, ring[i].y);
              }
              path.close();
              canvas.drawPath(path, paint);
              canvas.drawPath(path, strokePaint);
            }
          }
        }
      }
    }
  }

  void _drawStoreLabels(Canvas canvas, double currentScale) {
    for (var store in GeoJsonData.stores) {
      if (store.floor == floor && store.name != null && store.name!.isNotEmpty) {
        // 计算商店中心点
        Point? center = _calculatePolygonCenter(store.coordinates);
        if (center != null) {
          // 绘制商店名称
          final textPainter = TextPainter(
            text: TextSpan(
              text: store.name,
              style: TextStyle(
                color: Colors.black87,
                fontSize: math.max(8.0, 12.0 / currentScale),
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          final textOffset = Offset(
            center.x - textPainter.width / 2,
            center.y - textPainter.height / 2,
          );
          
          // 绘制文字背景
          final bgPaint = Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.fill;
          
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                textOffset.dx - 2,
                textOffset.dy - 1,
                textPainter.width + 4,
                textPainter.height + 2,
              ),
              const Radius.circular(2),
            ),
            bgPaint,
          );
          
          textPainter.paint(canvas, textOffset);
        }
      }
    }
  }

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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
