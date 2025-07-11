import 'package:flutter/material.dart';
import '../models/floor_model.dart';

class MapWidget extends StatefulWidget {
  final FloorModel currentFloor;

  const MapWidget({
    super.key,
    required this.currentFloor,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final TransformationController _transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 3.0,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8EAF6),
              Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 地图背景
            _buildMapBackground(),
            // 商店标记
            ..._buildStoreMarkers(),
            // 控制按钮
            Positioned(
              right: 16,
              top: 16,
              child: _buildControlButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: MapPainter(floor: widget.currentFloor),
    );
  }

  List<Widget> _buildStoreMarkers() {
    return _getStoresForFloor(widget.currentFloor.name).map((store) {
      return Positioned(
        left: store.x,
        top: store.y,
        child: _buildStoreMarker(store),
      );
    }).toList();
  }

  Widget _buildStoreMarker(Store store) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: store.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStoreIcon(store.category),
              size: 8,
              color: store.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            store.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        _buildControlButton(Icons.fullscreen, () {}),
        const SizedBox(height: 8),
        _buildControlButton(Icons.add, () {
          _transformationController.value = Matrix4.identity()..scale(2.0);
        }),
        const SizedBox(height: 8),
        _buildControlButton(Icons.remove, () {
          _transformationController.value = Matrix4.identity()..scale(0.8);
        }),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  List<Store> _getStoresForFloor(String floorName) {
    // 根据楼层返回不同的商店数据
    switch (floorName) {
      case 'F1':
        return [
          Store(name: 'Clarins', category: 'beauty', x: 300, y: 200, color: Colors.purple),
          Store(name: 'Aape', category: 'fashion', x: 350, y: 250, color: Colors.purple),
          Store(name: '两点见下午茶', category: 'food', x: 250, y: 300, color: Colors.orange),
          Store(name: 'chocolate', category: 'food', x: 200, y: 150, color: Colors.purple),
        ];
      case 'F2':
        return [
          Store(name: 'Zara', category: 'fashion', x: 200, y: 200, color: Colors.blue),
          Store(name: 'H&M', category: 'fashion', x: 300, y: 250, color: Colors.green),
        ];
      case 'B1':
        return [
          Store(name: '星巴克', category: 'food', x: 150, y: 200, color: Colors.green),
          Store(name: '超市', category: 'shopping', x: 250, y: 300, color: Colors.red),
        ];
      default:
        return [];
    }
  }

  IconData _getStoreIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'fashion':
        return Icons.shopping_bag;
      case 'beauty':
        return Icons.face;
      case 'shopping':
        return Icons.shopping_cart;
      default:
        return Icons.store;
    }
  }
}

class MapPainter extends CustomPainter {
  final FloorModel floor;

  MapPainter({required this.floor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 绘制地图轮廓
    final path = Path();
    path.moveTo(100, 100);
    path.lineTo(400, 100);
    path.lineTo(400, 150);
    path.lineTo(450, 150);
    path.lineTo(450, 400);
    path.lineTo(100, 400);
    path.close();

    canvas.drawPath(path, paint);

    // 绘制走廊
    final corridorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final corridorPath = Path();
    corridorPath.moveTo(200, 150);
    corridorPath.lineTo(350, 150);
    corridorPath.lineTo(350, 350);
    corridorPath.lineTo(200, 350);
    corridorPath.close();

    canvas.drawPath(corridorPath, corridorPaint);

    // 绘制门
    _drawDoor(canvas, 180, 100, '北门');
    _drawDoor(canvas, 100, 250, '西南门');
  }

  void _drawDoor(Canvas canvas, double x, double y, String label) {
    final doorPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 15, doorPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 20, y - 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
