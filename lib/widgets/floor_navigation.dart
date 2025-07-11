import 'package:flutter/material.dart';
import '../models/floor_model.dart';

class FloorNavigation extends StatelessWidget {
  final List<FloorModel> floors;
  final int selectedFloor;
  final Function(int) onFloorChanged;

  const FloorNavigation({
    super.key,
    required this.floors,
    required this.selectedFloor,
    required this.onFloorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // 指南针图标
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          // 楼层按钮
          Expanded(
            child: ListView.builder(
              itemCount: floors.length,
              itemBuilder: (context, index) {
                final floor = floors[index];
                final isSelected = index == selectedFloor;
                
                return GestureDetector(
                  onTap: () => onFloorChanged(index),
                  child: Container(
                    height: 35,
                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        floor.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
