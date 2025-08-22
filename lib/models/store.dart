import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'point.dart';

// 数据模型类
class Store {
  final String id;
  final String name;
  final int floor;
  final String type;
  final Point? location; // 添加位置信息

  Store({
    required this.id,
    required this.name,
    required this.floor,
    required this.type,
    this.location,
  });
}

class StoreData {
  static List<Store> stores = [
    Store(id: "S1", name: "蔚来汽车", floor: 1, type: "Store", location: Point(121.065, -239.109)),
    Store(id: "S2", name: "HARMAY", floor: 1, type: "Store", location: Point(168.456, -138.683)),
    Store(id: "S3", name: "GUCCI beauty", floor: 1, type: "Store", location: Point(298.394, -123.513)),
    Store(id: "S4", name: "ZARA HOME", floor: 1, type: "Store", location: Point(375.981, -77.893)),
    Store(id: "S5", name: "CHANEL", floor: 1, type: "Store", location: Point(437.651, -108.326)),
    Store(id: "S6", name: "Jmoon极萌/ulike", floor: 1, type: "Store", location: Point(495.194, -104.225)),
    Store(id: "S7", name: "LANCASTER", floor: 1, type: "Store", location: Point(525.335, -90.373)),
    Store(id: "S8", name: "", floor: 1, type: "Store", location: Point(563.557, -92.368)),
    Store(id: "S9", name: "COACH", floor: 1, type: "Store", location: Point(588.835, -130.926)),
    Store(id: "S10", name: "Abercrombie&Fitch", floor: 1, type: "Store", location: Point(736.563, -119.098)),
    Store(id: "S11", name: "Ciao Panificio by B&C", floor: 1, type: "Store", location: Point(806.176, -159.914)),
    Store(id: "S12", name: "", floor: 1, type: "Store", location: Point(847.077, -160.340)),
    Store(id: "S13", name: "", floor: 1, type: "Store", location: Point(799.512, -278.997)),
    Store(id: "S14", name: "Venchi", floor: 1, type: "Store", location: Point(801.530, -245.441)),
    Store(id: "S15", name: "SHAKE SHACK", floor: 1, type: "Store", location: Point(844.326, -378.062)),
    Store(id: "S16", name: "SHAKE SHACK", floor: 1, type: "Store", location: Point(841.540, -330.041)),
    Store(id: "S17", name: "SEPHORA", floor: 1, type: "Store", location: Point(698.965, -339.268)),
    Store(id: "S18", name: "HOKA", floor: 1, type: "Store", location: Point(753.616, -334.220)),
    Store(id: "S19", name: "gaga鲜语", floor: 1, type: "Store", location: Point(764.888, -394.968)),
    Store(id: "S20", name: "星巴克臻选", floor: 1, type: "Store", location: Point(527.830, -373.583)),
    Store(id: "S21", name: "KLATTER MUSEN", floor: 1, type: "Store", location: Point(573.377, -370.001)),
    Store(id: "S22", name: "HELLY HANSEN", floor: 1, type: "Store", location: Point(622.073, -346.291)),
    Store(id: "S23", name: "Massimo Dutti", floor: 1, type: "Store", location: Point(449.351, -380.205)),
    Store(id: "S24", name: "i.t(含Fred Perry)", floor: 1, type: "Store", location: Point(219.112, -341.495)),
    Store(id: "S25", name: "APM Monaco", floor: 1, type: "Store", location: Point(296.019, -361.610)),
    Store(id: "S26", name: "Mardi Mercredi", floor: 1, type: "Store", location: Point(329.641, -367.177)),
    Store(id: "S27", name: "Mardi Mercredi", floor: 1, type: "Store", location: Point(360.432, -371.425)),
    Store(id: "S28", name: "DESCENTE迪桑特", floor: 1, type: "Store", location: Point(543.081, -298.102)),
    Store(id: "S29", name: "DESCENTE迪桑特", floor: 1, type: "Store", location: Point(542.116, -256.927)),
    Store(id: "S30", name: "YSL", floor: 1, type: "Store", location: Point(539.876, -213.241)),
    Store(id: "S31", name: "Shu uemura", floor: 1, type: "Store", location: Point(561.698, -168.956)),
    Store(id: "S32", name: "DESCENTE迪桑特", floor: 1, type: "Store", location: Point(579.3, -286.9)), 
    Store(id: "S33", name: "GIVENCHY纪梵希", floor: 1, type: "Store", location: Point(579.9, -225.8)), 
    Store(id: "S34", name: "ON昂跑", floor: 1, type: "Store", location: Point(613.9, -281.6)), 
    Store(id: "S35", name: "LANCOME", floor: 1, type: "Store", location: Point(613.9, -230.6)), 
    Store(id: "S36", name: "ON昂跑", floor: 1, type: "Store", location: Point(658.2, -274.5)),
    Store(id: "S37", name: "悦木之源ORIGINS", floor: 1, type: "Store", location: Point(643.7, -242.3)), 
    Store(id: "S38", name: "MAC", floor: 1, type: "Store", location: Point(671.1, -242.3)), 
    Store(id: "S39", name: "AAPE", floor: 1, type: "Store", location: Point(312.0, -278.5)), 
    Store(id: "S40", name: "GROTTO", floor: 1, type: "Store", location: Point(373.1, -279.1)), 
    Store(id: "S41", name: "DIOR", floor: 1, type: "Store", location: Point(282.3, -240.1)), 
    Store(id: "S42", name: "DIOR", floor: 1, type: "Store", location: Point(309.2, -230.1)), 
    Store(id: "S43", name: "娇韵诗CLARINS", floor: 1, type: "Store", location: Point(339.1, -228.5)), 
    Store(id: "S44", name: "Guerlain娇兰", floor: 1, type: "Store", location: Point(356.2, -228.5)), 
    Store(id: "S45", name: "SMFK", floor: 1, type: "Store", location: Point(409.940, -290.196)),
    Store(id: "S46", name: "Estée Lauder雅诗兰黛", floor: 1, type: "Store", location: Point(421.528, -214.582)),
    Store(id: "S47", name: "JO MALONE", floor: 1, type: "Store", location: Point(405.611, -204.042)),
    Store(id: "S48", name: "lululemon", floor: 1, type: "Store", location: Point(655.823, -133.652)),
    Store(id: "S49", name: "Chloé", floor: 1, type: "Store", location: Point(332.591, -132.079)),
  ];

  static List<Store> searchStores(String query) {
    if (query.isEmpty) return [];
    
    return stores.where((store) {
      if (store.name.isEmpty) return false;
      return store.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
