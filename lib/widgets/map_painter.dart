// 新的 map_painter.dart - 使用简单的反向缩放方法
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
  final List<String> highlightedAreas;
  final Function(Store)? onStoreTap;
  final double viewerScale; // 添加 InteractiveViewer 的缩放值

  MapPainter({
    required this.floor,
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.highlightedAreas = const [],
    this.onStoreTap,
    this.viewerScale = 1.0, // InteractiveViewer 的缩放值
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
    final mapScale = scaleY * scale; // 使用高度作为基准
    
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
    
    // 绘制标签（使用反向缩放）
    _drawStoreLabels(canvas, mapScale);
    
    canvas.restore();
  }

  void _drawStoreLabels(Canvas canvas, double mapScale) {
    // 计算反向缩放因子，使标签保持固定大小
    // 总缩放 = mapScale * viewerScale
    // 要保持固定大小，需要除以总缩放
    final totalScale = mapScale * viewerScale;
    final labelScale = 1.0 / totalScale;
    
    for (var store in GeoJsonData.stores) {
      if (store.floor == floor && store.name != null && store.name!.isNotEmpty) {
        // 计算商店中心点
        Point? center = _calculatePolygonCenter(store.coordinates);
        if (center != null) {
          // 保存当前画布状态
          canvas.save();
          
          // 移动到标签位置
          canvas.translate(center.x, center.y);
          
          // 应用反向缩放，使标签保持固定大小
          canvas.scale(labelScale);
          
          // 绘制商店名称
          final textPainter = TextPainter(
            text: TextSpan(
              text: store.name,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12.0, // 固定字体大小
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          // 计算文本偏移（居中）
          final textOffset = Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          );
          
          // 绘制文字背景
          final bgPaint = Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.fill;
          
          // 背景边框
          final borderPaint = Paint()
            ..color = Colors.grey.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5;
          
          final bgRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              textOffset.dx - 3,
              textOffset.dy - 2,
              textPainter.width + 6,
              textPainter.height + 4,
            ),
            const Radius.circular(3),
          );
          
          // 添加阴影效果
          final shadowPaint = Paint()
            ..color = Colors.black.withOpacity(0.1)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
          
          canvas.drawRRect(
            bgRect.shift(const Offset(0, 1)),
            shadowPaint,
          );
          canvas.drawRRect(bgRect, bgPaint);
          canvas.drawRRect(bgRect, borderPaint);
          
          // 绘制文本
          textPainter.paint(canvas, textOffset);
          
          // 恢复画布状态
          canvas.restore();
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
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.floor != floor ||
           oldDelegate.scale != scale ||
           oldDelegate.offset != offset ||
           oldDelegate.viewerScale != viewerScale ||
           oldDelegate.highlightedAreas != highlightedAreas;
  }
}