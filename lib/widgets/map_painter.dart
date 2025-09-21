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
  final String? selectedStoreId;  // 添加选中店铺ID

  MapPainter({
    required this.floor,
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.highlightedAreas = const [],
    this.onStoreTap,
    this.viewerScale = 1.0, // InteractiveViewer 的缩放值
    this.selectedStoreId,  // 添加参数
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
    
    // 绘制扶梯图标（使用反向缩放）
    _drawEscalatorIcons(canvas, mapScale);
    
    canvas.restore();
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

void _drawStoreLabels(Canvas canvas, double mapScale) {
  // 计算反向缩放因子，使标签保持固定大小
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
        
        // 1. 先绘制图标（根据类型绘制不同图标）
        _drawStoreIcon(canvas, store.type);  // 传入店铺类型
        
        // 2. 再绘制商店名称（在图标右侧，确保在图标之上）
        final textPainter = TextPainter(
          text: TextSpan(
            text: store.name,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        // 文本位置：图标右侧
        final textOffset = Offset(
          15,
          -textPainter.height / 2,
        );
        
        // 绘制文字背景
        final bgPaint = Paint()
          ..color = Colors.white.withOpacity(0.95)
          ..style = PaintingStyle.fill;
        
        final bgRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            textOffset.dx - 2,
            textOffset.dy - 1,
            textPainter.width + 4,
            textPainter.height + 2,
          ),
          const Radius.circular(2),
        );
        
        // 添加阴影
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.1)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        
        canvas.drawRRect(
          bgRect.shift(const Offset(0, 0.5)),
          shadowPaint,
        );
        canvas.drawRRect(bgRect, bgPaint);
        
        // 绘制文本
        textPainter.paint(canvas, textOffset);
        
        // 恢复画布状态
        canvas.restore();
      }
    }
  }
}

void _drawStoreIcon(Canvas canvas, String storeType) {
  // 图标颜色
  final bgPaint = Paint()
    ..color = const Color.fromARGB(141, 255, 97, 179)
    ..style = PaintingStyle.fill;
  
  final borderPaint = Paint()
    ..color = const Color.fromARGB(255, 255, 255, 255)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  
  // 创建水滴形状的路径
  final dropPath = Path();
  
  const radius = 10.0;
  const centerY = -3.0;
  
  // 从顶部开始，顺时针绘制
  dropPath.moveTo(0, centerY - radius);
  
  // 右半圆
  dropPath.arcTo(
    Rect.fromCircle(center: Offset(0, centerY), radius: radius),
    -math.pi / 2,
    math.pi * 0.8,
    false,
  );
  
  // 右侧到尖角
  dropPath.lineTo(0, centerY + radius + 5);
  
  // 尖角到左侧
  dropPath.lineTo(-radius * 0.6-2, centerY + radius * 0.6);
  
  // 左半圆
  dropPath.arcTo(
    Rect.fromCircle(center: Offset(0, centerY), radius: radius),
    math.pi * 0.7,
    math.pi * 0.8,
    false,
  );
  
  dropPath.close();
  
  // 绘制填充的水滴形状
  canvas.drawPath(dropPath, bgPaint);
  
  // 绘制边框
  canvas.drawPath(dropPath, borderPaint);
  
  // 根据店铺类型选择不同的图标
  IconData iconData;
  double fontSize = 12.0;
  
  switch (storeType.toLowerCase()) {
    case 'cosmetics':
      // 使用face或palette图标代表化妆品
      iconData = Icons.brush;
      fontSize = 11.0;
      break;
    case 'food':
      // 使用餐饮图标
      iconData = Icons.restaurant;
      fontSize = 12.0;
      break;
    case 'store':
    default:
      // 默认使用购物袋图标
      iconData = Icons.shopping_bag;
      fontSize = 12.0;
      break;
  }
  
  // 使用TextPainter绘制对应的图标
  final iconPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  
  iconPainter.layout();
  
  // 绘制图标，居中对齐在水滴形状内
  iconPainter.paint(
    canvas,
    Offset(-iconPainter.width / 2, centerY - iconPainter.height / 2),
  );
}


  // 添加绘制扶梯图标的方法
  void _drawEscalatorIcons(Canvas canvas, double mapScale) {
    for (var escalator in GeoJsonData.escalators) {
      if (escalator.floor == floor) {
        // 计算扶梯中心点
        Point? center = _calculatePolygonCenter(escalator.coordinates);
        if (center != null) {
          canvas.save();
          canvas.translate(center.x, center.y);
          
          // 绘制扶梯图标（使用Icons.stairs样式）
          _drawEscalatorIcon(canvas);
          
          canvas.restore();
        }
      }
    }
  }

  // 添加绘制扶梯图标的具体方法
  void _drawEscalatorIcon(Canvas canvas) {
    // 使用TextPainter绘制图标
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.stairs.codePoint),
        style: TextStyle(
          fontSize: 18.0,
          fontFamily: Icons.stairs.fontFamily,
          package: Icons.stairs.fontPackage,
          color: const Color.fromARGB(255, 230, 126, 34),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // 绘制白色背景圆
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color.fromARGB(255, 230, 126, 34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    const radius = 12.0;
    canvas.drawCircle(Offset.zero, radius, bgPaint);
    canvas.drawCircle(Offset.zero, radius, borderPaint);
    
    // 绘制图标，居中对齐
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
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

    // 添加扶梯到边界计算
    for (var escalator in GeoJsonData.escalators) {
      if (escalator.floor == floor) {
        for (var polygon in escalator.coordinates) {
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

  // 修改 _drawStores 方法以高亮显示选中的店铺
  void _drawStores(Canvas canvas) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 132, 194, 244)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final selectedPaint = Paint()
      ..color = Colors.orange.withOpacity(0.8)  // 选中店铺的颜色
      ..style = PaintingStyle.fill;
      
    final selectedStrokePaint = Paint()
      ..color = Colors.orange.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var store in GeoJsonData.stores) {
      if (store.floor == floor) {
        bool isSelected = store.id == selectedStoreId;
        
        for (var polygon in store.coordinates) {
          for (var ring in polygon) {
            final path = Path();
            if (ring.isNotEmpty) {
              path.moveTo(ring[0].x, ring[0].y);
              for (int i = 1; i < ring.length; i++) {
                path.lineTo(ring[i].x, ring[i].y);
              }
              path.close();
              
              // 使用不同的颜色绘制选中的店铺
              if (isSelected) {
                canvas.drawPath(path, selectedPaint);
                canvas.drawPath(path, selectedStrokePaint);
              } else {
                canvas.drawPath(path, paint);
                canvas.drawPath(path, strokePaint);
              }
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.floor != floor ||
           oldDelegate.scale != scale ||
           oldDelegate.offset != offset ||
           oldDelegate.viewerScale != viewerScale ||
           oldDelegate.highlightedAreas != highlightedAreas ||
           oldDelegate.selectedStoreId != selectedStoreId;  // 添加判断
  }
}