import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/floor_navigation.dart';
import '../widgets/map_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../models/floor_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedFloor = 0; // F1层索引
  final List<FloorModel> floors = [
    FloorModel(name: 'B4', level: -4),
    FloorModel(name: 'B3', level: -3),
    FloorModel(name: 'B2', level: -2),
    FloorModel(name: 'B1', level: -1),
    FloorModel(name: 'F1', level: 1),
    FloorModel(name: 'F2', level: 2),
    FloorModel(name: 'F3', level: 3),
    FloorModel(name: 'F4', level: 4),
    FloorModel(name: 'F5', level: 5),
    FloorModel(name: 'F6', level: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 搜索栏
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SearchBarWidget(),
              ),
              // 地图区域
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // 地图组件
                        MapWidget(
                          currentFloor: floors[selectedFloor],
                        ),
                        // 楼层导航
                        Positioned(
                          left: 8,
                          top: 50,
                          child: FloorNavigation(
                            floors: floors,
                            selectedFloor: selectedFloor,
                            onFloorChanged: (index) {
                              setState(() {
                                selectedFloor = index;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 底部导航
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: BottomNavigationWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
