import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/services.dart';


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

class Point {
  final double x;
  final double y;
  
  Point(this.x, this.y);
}

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
  static List<WalkableArea> areas = [
    // W1
    WalkableArea(
      id: "W1",
      floor: 1,
      coordinates: [[
        Point(178.460095752560278, -330.63971148360389),
        Point(160.45884, -351.27192),
        Point(160.06068, -357.04524),
        Point(128.0088, -320.81268),
        Point(136.121310000000335, -317.179469999999867),
        Point(151.130806873001603, -303.376093411436216),
      ]],
    ),
    
    // W2
    WalkableArea(
      id: "W2",
      floor: 1,
      coordinates: [[
        Point(401.426686079271178, -360.192776470767285),
        Point(400.94748, -406.7157),
        Point(374.3703000000001, -406.51662),
        Point(375.008187248861134, -355.724847809432902),
      ]],
    ),
    
    // W3
    WalkableArea(
      id: "W3",
      floor: 1,
      coordinates: [[
        Point(200.660482838580862, -305.194652438857247),
        Point(178.460095752560278, -330.63971148360389),
        Point(151.130806873001603, -303.376093411436216),
        Point(173.103859728055653, -283.168732303663319),
      ]],
    ),
    
    // W4
    WalkableArea(
      id: "W4",
      floor: 1,
      coordinates: [[
        Point(221.801930746704755, -216.761224372483866),
        Point(212.169870000000486, -220.824749999999739),
        Point(202.016790000000498, -229.186109999999729),
        Point(193.854510000000488, -242.723549999999733),
        Point(192.261870000000499, -254.071109999999749),
        Point(192.262288760394028, -254.076763265312451),
        Point(179.71154830054698, -253.618676097599831),
        Point(180.914310000000341, -242.225849999999895),
        Point(190.071990000000312, -223.26348),
        Point(203.808510000000297, -208.33248),
        Point(213.503361196685319, -201.796273870621945),
      ]],
    ),
    
    // W5
    WalkableArea(
      id: "W5",
      floor: 1,
      coordinates: [[
        Point(288.314973297888855, -277.235921811604669),
        Point(290.109690000000796, -278.458409999999731),
        Point(333.166511831629919, -295.913878310119514),
        Point(323.018040921497629, -321.826228034993562),
        Point(311.95872, -318.02556),
        Point(276.734574661698161, -299.785978803444607),
      ]],
    ),
    
    // W6
    WalkableArea(
      id: "W6",
      floor: 1,
      coordinates: [[
        Point(192.262288760394028, -254.076763265312451),
        Point(193.058190000000479, -264.821429999999737),
        Point(197.039790000000494, -272.983709999999746),
        Point(206.595630000000483, -278.757029999999759),
        Point(216.35055000000051, -280.747829999999738),
        Point(228.096270000000487, -278.557949999999721),
        Point(228.140012671759365, -278.525984201406686),
        Point(228.951861504954564, -287.535673016342798),
        Point(225.95616, -287.36724),
        Point(212.21964, -291.94608),
        Point(200.660482838580862, -305.194652438857247),
        Point(173.103859728055653, -283.168732303663319),
        Point(180.715230000000332, -276.168989999999894),
        Point(179.122590000000343, -259.19742),
        Point(179.71154830054698, -253.618676097599831),
      ]],
    ),
    
    // W7
    WalkableArea(
      id: "W7",
      floor: 1,
      coordinates: [[
        Point(228.140012671759365, -278.525984201406686),
        Point(243.624510000000498, -267.210389999999734),
        Point(249.795990000000472, -255.265589999999747),
        Point(250.95620496944386, -247.054837908554276),
        Point(267.769691539335156, -251.178717639939094),
        Point(267.613650000000803, -260.541209999999694),
        Point(276.373170000000812, -269.101649999999722),
        Point(288.314973297888855, -277.235921811604669),
        Point(276.734574661698161, -299.785978803444607),
        Point(270.05238, -296.32584),
        Point(250.74162, -288.7608),
        Point(228.951861504954564, -287.535673016342798),
      ]],
    ),
    
    // W8
    WalkableArea(
      id: "W8",
      floor: 1,
      coordinates: [[
        Point(254.39866525552651, -86.838784419987874),
        Point(253.926900000000359, -50.984625),
        Point(275.825700000000325, -51.780945),
        Point(275.502567201359113, -86.517720853927685),
      ]],
    ),
    
    // W9
    WalkableArea(
      id: "W9",
      floor: 1,
      coordinates: [[
        Point(275.159613026113618, -123.385294692818363),
        Point(274.864934131937332, -155.063275816770414),
        Point(255.403518682498856, -163.207644869885542),
        Point(254.872420228822676, -122.844162390496962),
      ]],
    ),
    
    // W10
    WalkableArea(
      id: "W10",
      floor: 1,
      coordinates: [[
        Point(270.315433463715294, -198.524828701001326),
        Point(248.344034055629834, -225.55617301635067),
        Point(239.244750000000494, -217.241309999999714),
        Point(224.910990000000481, -215.449589999999716),
        Point(221.801930746704755, -216.761224372483866),
        Point(213.503361196685319, -201.796273870621945),
        Point(219.237210000000289, -197.93055),
        Point(252.151153040550582, -178.46065165493107),
      ]],
    ),
    
    // W11
    WalkableArea(
      id: "W11",
      floor: 1,
      coordinates: [[
        Point(275.339502533731661, -199.003863253452039),
        Point(274.979610000000889, -210.970289999999636),
        Point(281.350170000000901, -219.928889999999626),
        Point(289.313370000000873, -219.729809999999617),
        Point(300.66093000000086, -211.766609999999616),
        Point(302.54530134424698, -210.903885770103813),
        Point(306.39772631010635, -222.200140135236012),
        Point(296.08209000000079, -226.896689999999523),
        Point(271.794330000000798, -241.031369999999725),
        Point(267.812730000000784, -248.596409999999707),
        Point(267.769691539335156, -251.178717639939094),
        Point(250.95620496944386, -247.054837908554276),
        Point(252.384030000000507, -236.950229999999721),
        Point(250.79139000000049, -227.792549999999721),
        Point(248.344034055629834, -225.55617301635067),
      ]],
    ),
    
    // W12
    WalkableArea(
      id: "W12",
      floor: 1,
      coordinates: [[
        Point(450.587015722467356, -135.312453213055221),
        Point(448.378290000000902, -135.31988999999956),
        Point(441.21141000000091, -136.912529999999578),
        Point(438.026130000000876, -140.495969999999573),
        Point(438.026130000000876, -158.442204010761145),
        Point(403.020707441565605, -156.194119473782621),
        Point(388.73610288220118, -129.02738759973019),
        Point(411.399180000000115, -124.445145),
        Point(445.262881023454952, -121.845244729485259),
      ]],
    ),
    
    // W13
    WalkableArea(
      id: "W13",
      floor: 1,
      coordinates: [[
        Point(355.473287160669429, -155.243386905128489),
        Point(353.8152900000008, -153.436169999999692),
        Point(345.852090000000828, -152.440769999999702),
        Point(306.828321533427584, -169.023107875314111),
        Point(301.123134418483176, -154.232094098519497),
        Point(343.214280000000201, -138.231435),
        Point(359.570314131116447, -134.924412040642949),
      ]],
    ),
    
    // W14
    WalkableArea(
      id: "W14",
      floor: 1,
      coordinates: [[
        Point(306.828321533427584, -169.023107875314111),
        Point(275.576850000000888, -182.302769999999668),
        Point(275.775930000000869, -184.492649999999657),
        Point(275.339502533731661, -199.003863253452039),
        Point(270.315433463715294, -198.524828701001326),
        Point(252.151153040550582, -178.46065165493107),
        Point(255.121380000000357, -176.703645),
        Point(255.519540000000347, -172.025265),
        Point(255.403518682498856, -163.207644869885542),
        Point(274.864934131937332, -155.063275816770414),
        Point(274.830300000000307, -158.786445),
        Point(287.571420000000273, -159.383685),
        Point(301.123134418483176, -154.232094098519497),
      ]],
    ),
    
    // W15
    WalkableArea(
      id: "W15",
      floor: 1,
      coordinates: [[
        Point(275.502567201359113, -86.517720853927685),
        Point(275.159613026113618, -123.385294692818363),
        Point(254.872420228822676, -122.844162390496962),
        Point(254.39866525552651, -86.838784419987874),
      ]],
    ),
    
    // W16
    WalkableArea(
      id: "W16",
      floor: 1,
      coordinates: [[
        Point(373.856875232603898, -198.795299202645253),
        Point(356.00517000000076, -203.604329999999578),
        Point(320.568930000000762, -215.748209999999546),
        Point(306.39772631010635, -222.200140135236012),
        Point(302.54530134424698, -210.903885770103813),
        Point(333.708210000000804, -196.636529999999652),
        Point(363.432169439772679, -188.194221993437253),
      ]],
    ),
    
    // W17
    WalkableArea(
      id: "W17",
      floor: 1,
      coordinates: [[
        Point(477.775716831101079, -219.963115329259097),
        Point(473.601966315582956, -257.898411778643606),
        Point(429.489677885146364, -259.159546709029712),
        Point(429.664770000000772, -251.980769999999552),
        Point(432.25281000000075, -228.29024999999956),
        Point(435.126020064770728, -212.727028815828817),
      ]],
    ),
    
    // W18
    WalkableArea(
      id: "W18",
      floor: 1,
      coordinates: [[
        Point(359.570314131116447, -134.924412040642949),
        Point(388.73610288220118, -129.02738759973019),
        Point(403.020707441565605, -156.194119473782621),
        Point(389.277611536641302, -194.641141667680074),
        Point(373.856875232603898, -198.795299202645253),
        Point(363.432169439772679, -188.194221993437253),
        Point(367.352730000000804, -187.080689999999663),
        Point(371.931570000000761, -183.099089999999649),
        Point(373.723290000000816, -175.135889999999677),
        Point(355.473287160669429, -155.243386905128489),
      ]],
    ),
    
    // W19
    WalkableArea(
      id: "W19",
      floor: 1,
      coordinates: [[
        Point(333.166511831629919, -295.913878310119514),
        Point(356.403330000000778, -305.33420999999953),
        Point(378.538623362567876, -311.785066922804788),
        Point(368.899945223498094, -336.170697006527234),
        Point(347.29542, -330.16944),
        Point(323.018040921497629, -321.826228034993562),
      ]],
    ),
    
    // W20
    WalkableArea(
      id: "W20",
      floor: 1,
      coordinates: [[
        Point(426.97833977872466, -343.341575587659747),
        Point(415.28124, -341.36769),
        Point(407.31804000000011, -341.96493),
        Point(401.54472, -348.73365),
        Point(401.426686079271178, -360.192776470767285),
        Point(375.008187248861134, -355.724847809432902),
        Point(375.16662, -343.10964),
        Point(372.3795, -337.13724),
        Point(368.899945223498094, -336.170697006527234),
        Point(378.538623362567876, -311.785066922804788),
        Point(391.24233000000072, -315.487289999999518),
        Point(421.900650000000724, -320.862449999999512),
        Point(423.195211327655727, -319.767051953522241),
      ]],
    ),
    
    // W21
    WalkableArea(
      id: "W21",
      floor: 1,
      coordinates: [[
        Point(826.419567960483505, -373.37340769390795),
        Point(842.307839999999715, -405.7203),
        Point(854.252639999999701, -414.47982),
        Point(808.26515999999981, -414.47982),
        Point(807.667919999999754, -404.92398),
        Point(799.304853065638554, -389.43595380591762),
      ]],
    ),
    
    // W22
    WalkableArea(
      id: "W22",
      floor: 1,
      coordinates: [[
        Point(473.112223428580421, -302.422839926922563),
        Point(484.507779418255382, -317.700607522370547),
        Point(475.833375717852505, -347.612526839934901),
        Point(447.13404, -346.74285),
        Point(426.97833977872466, -343.341575587659747),
        Point(423.195211327655727, -319.767051953522241),
        Point(432.25281000000075, -312.10292999999956),
        Point(431.3719643389868, -302.248469167406199),
      ]],
    ),
    
    // W23
    WalkableArea(
      id: "W23",
      floor: 1,
      coordinates: [[
        Point(403.020707441565605, -156.194119473782621),
        Point(438.026130000000876, -158.442204010761145),
        Point(438.026130000000876, -159.408569999999543),
        Point(445.392090000000906, -170.955209999999568),
        Point(445.837628116999269, -170.956638006784829),
        Point(435.619600348379436, -191.911304715405237),
        Point(431.456490000000713, -188.673329999999567),
        Point(404.779770000000724, -190.465049999999565),
        Point(389.277611536641302, -194.641141667680074),
      ]],
    ),
    
    // W24
    WalkableArea(
      id: "W24",
      floor: 1,
      coordinates: [[
        Point(482.468436569342089, -216.175115006959061),
        Point(477.775716831101079, -219.963115329259097),
        Point(435.126020064770728, -212.727028815828817),
        Point(437.030730000000744, -202.409849999999579),
        Point(436.831650000000707, -192.854009999999562),
        Point(435.619600348379436, -191.911304715405237),
        Point(445.837628116999269, -170.956638006784829),
        Point(479.254035538625089, -171.063741876725913),
      ]],
    ),
    
    // W25
    WalkableArea(
      id: "W25",
      floor: 1,
      coordinates: [[
        Point(463.263245466518697, -120.262059352454031),
        Point(481.875095614575116, -119.741448159501402),
        Point(481.8735, -119.866305),
        Point(484.06338, -119.79165),
        Point(508.163615992596135, -120.165297069652709),
        Point(500.878524509568592, -135.143121533637384),
        Point(450.587015722467356, -135.312453213055221),
        Point(445.262881023454952, -121.845244729485259),
        Point(463.259520000000123, -120.463545),
      ]],
    ),
    
    // W26
    WalkableArea(
      id: "W26",
      floor: 1,
      coordinates: [[
        Point(481.875095614575116, -119.741448159501402),
        Point(463.263245466518697, -120.262059352454031),
        Point(463.856760000000122, -88.162815),
        Point(482.27166, -88.710285),
      ]],
    ),
    
    // W27
    WalkableArea(
      id: "W27",
      floor: 1,
      coordinates: [[
        Point(482.468436569342089, -216.175115006959061),
        Point(519.625721668319898, -218.708256914722654),
        Point(522.635130000000913, -236.850689999999787),
        Point(524.039849558889387, -265.366497045437598),
        Point(481.505656158046747, -267.322168828253211),
        Point(473.601966315582956, -257.898411778643606),
        Point(477.775716831101079, -219.963115329259097),
      ]],
    ),
    
    // W28
    WalkableArea(
      id: "W28",
      floor: 1,
      coordinates: [[
        Point(473.601966315582956, -257.898411778643606),
        Point(481.505656158046747, -267.322168828253211),
        Point(473.112223428580421, -302.422839926922563),
        Point(431.3719643389868, -302.248469167406199),
        Point(429.067530000000716, -276.467609999999524),
        Point(429.489677885146364, -259.159546709029712),
      ]],
    ),
    
    // W29
    WalkableArea(
      id: "W29",
      floor: 1,
      coordinates: [[
        Point(492.990209688003745, -348.132430899636404),
        Point(510.322706845692608, -346.617352476761539),
        Point(506.16126, -351.76962),
        Point(505.96218, -404.32674),
        Point(498.59622, -403.7295),
        Point(498.99438, -352.91433),
        Point(493.12152, -348.13641),
      ]],
    ),
    
    // W30
    WalkableArea(
      id: "W30",
      floor: 1,
      coordinates: [[
        Point(510.322706845692608, -346.617352476761539),
        Point(492.990209688003745, -348.132430899636404),
        Point(475.833375717852505, -347.612526839934901),
        Point(484.507779418255382, -317.700607522370547),
        Point(524.413540118976471, -312.997306216277593),
        Point(530.001090000000886, -319.070729999999799),
        Point(535.519912707274784, -318.556553971371784),
        Point(541.488307564811066, -343.234618007716449),
        Point(510.34194, -346.59354),
      ]],
    ),
    
    // W31
    WalkableArea(
      id: "W31",
      floor: 1,
      coordinates: [[
        Point(612.555460196729769, -131.680643707246844),
        Point(612.37044, -81.17013),
        Point(627.40097999999989, -81.17013),
        Point(627.79914, -103.91502),
        Point(627.914966248051655, -128.267488652881724),
      ]],
    ),
    
    // W32
    WalkableArea(
      id: "W32",
      floor: 1,
      coordinates: [[
        Point(554.176782268517172, -152.440599820557878),
        Point(527.348860387265972, -174.984315268496204),
        Point(512.114253376245756, -166.009479203705581),
        Point(514.47285000000079, -137.509769999999577),
        Point(507.505050000000892, -135.12080999999958),
        Point(500.878524509568592, -135.143121533637384),
        Point(508.163615992596135, -120.165297069652709),
        Point(509.7447, -120.18981),
        Point(542.69244, -124.56957),
        Point(555.193833919735653, -126.316489674373585),
      ]],
    ),
    
    // W33
    WalkableArea(
      id: "W33",
      floor: 1,
      coordinates: [[
        Point(554.176782268517172, -152.440599820557878),
        Point(583.085543087880978, -171.369721626942123),
        Point(579.372930000000906, -175.932209999999543),
        Point(580.169250000000829, -184.492649999999571),
        Point(589.856692070623012, -187.62682243461262),
        Point(584.80736041793682, -199.317923449901684),
        Point(578.576610000000869, -197.233769999999765),
        Point(537.964290000000915, -189.668729999999755),
        Point(531.055882527628341, -189.361689667894325),
        Point(527.348860387265972, -174.984315268496204),
      ]],
    ),
    
    // W34
    WalkableArea(
      id: "W34",
      floor: 1,
      coordinates: [[
        Point(482.468436569342089, -216.175115006959061),
        Point(479.254035538625089, -171.063741876725913),
        Point(507.505050000000892, -171.154289999999548),
        Point(512.083890000000792, -166.376369999999554),
        Point(512.114253376245756, -166.009479203705581),
        Point(527.348860387265972, -174.984315268496204),
        Point(531.055882527628341, -189.361689667894325),
        Point(520.047090000000935, -188.872409999999832),
        Point(515.667330000000902, -194.844809999999825),
        Point(519.625721668319898, -218.708256914722654),
      ]],
    ),
    
    // W35
    WalkableArea(
      id: "W35",
      floor: 1,
      coordinates: [[
        Point(524.039849558889387, -265.366497045437598),
        Point(524.625930000000835, -277.263929999999789),
        Point(520.843410000000858, -309.116729999999791),
        Point(524.413540118976471, -312.997306216277593),
        Point(484.507779418255382, -317.700607522370547),
        Point(473.112223428580421, -302.422839926922563),
        Point(481.505656158046747, -267.322168828253211),
      ]],
    ),
    
    // W36
    WalkableArea(
      id: "W36",
      floor: 1,
      coordinates: [[
        Point(606.673996489471165, -328.216209643259504),
        Point(596.44404, -331.61277),
        Point(550.95426, -342.21378),
        Point(541.488307564811066, -343.234618007716449),
        Point(535.519912707274784, -318.556553971371784),
        Point(562.052970000000869, -316.084529999999745),
        Point(596.891970000000811, -305.533289999999738),
        Point(599.976071974962565, -304.294058692839883),
      ]],
    ),
    
    // W37
    WalkableArea(
      id: "W37",
      floor: 1,
      coordinates: [[
        Point(661.32285581799249, -320.18858682163193),
        Point(663.733079999999859, -337.18701),
        Point(663.733079999999859, -373.22049),
        Point(647.508059999999887, -373.02141),
        Point(647.508059999999887, -336.54),
        Point(644.781599980393821, -328.165872796924418),
      ]],
    ),
    
    // W38
    WalkableArea(
      id: "W38",
      floor: 1,
      coordinates: [[
        Point(603.747085677085124, -155.189910240161566),
        Point(595.896570000000906, -155.626049999999566),
        Point(583.085543087880978, -171.369721626942123),
        Point(554.176782268517172, -152.440599820557878),
        Point(555.193833919735653, -126.316489674373585),
        Point(588.28176, -130.94013),
        Point(606.189473704326815, -134.316174386881329),
      ]],
    ),
    
    // W39
    WalkableArea(
      id: "W39",
      floor: 1,
      coordinates: [[
        Point(647.544770263627811, -222.341138922824172),
        Point(635.712570000000824, -216.345449999999744),
        Point(584.80736041793682, -199.317923449901684),
        Point(589.856692070623012, -187.62682243461262),
        Point(614.012850000000867, -195.44204999999954),
        Point(637.106130000000803, -202.409849999999551),
        Point(652.155915434377903, -209.62120552063854),
      ]],
    ),
    
    // W40
    WalkableArea(
      id: "W40",
      floor: 1,
      coordinates: [[
        Point(694.707118843129592, -205.709184383442505),
        Point(705.049326044861346, -223.954934260054955),
        Point(701.40897000000075, -231.077369999999576),
        Point(700.811730000000807, -246.008369999999559),
        Point(702.749204806402872, -252.534600926827693),
        Point(685.163795954805437, -253.5904884802531),
        Point(684.487170000000788, -245.809289999999777),
        Point(680.107410000000755, -238.841489999999737),
        Point(647.544770263627811, -222.341138922824172),
        Point(652.155915434377903, -209.62120552063854),
        Point(665.773650000000885, -216.146369999999536),
        Point(674.931330000000798, -216.146369999999536),
        Point(678.116610000000833, -210.572129999999561),
        Point(678.035959656387945, -204.52335422903289),
      ]],
    ),
    // W41
    WalkableArea(
      id: "W41",
      floor: 1,
      coordinates: [[
        Point(627.914966248051655, -128.267488652881724),
        Point(627.99822, -145.77159),
        Point(662.496596869892187, -158.471541924630685),
        Point(654.566597682168208, -172.344334624648241),
        Point(606.646890000000894, -155.028809999999567),
        Point(603.747085677085124, -155.189910240161566),
        Point(606.189473704326815, -134.316174386881329),
        Point(612.569519999999898, -135.51897),
        Point(612.555460196729769, -131.680643707246844),
      ]],
    ),
    
    // W42
    WalkableArea(
      id: "W42",
      floor: 1,
      coordinates: [[
        Point(694.707118843129592, -205.709184383442505),
        Point(678.035959656387945, -204.52335422903289),
        Point(677.718450000000871, -180.710129999999538),
        Point(654.566597682168208, -172.344334624648241),
        Point(662.496596869892187, -158.471541924630685),
        Point(664.23078, -159.10995),
        Point(707.530679999999847, -180.85944),
        Point(709.498578634011437, -182.131278295528517),
      ]],
    ),
    
    // W43
    WalkableArea(
      id: "W43",
      floor: 1,
      coordinates: [[
        Point(665.019932699573246, -303.853199763817315),
        Point(662.93676, -304.73697),
        Point(659.950559999999882, -310.51029),
        Point(661.32285581799249, -320.18858682163193),
        Point(644.781599980393821, -328.165872796924418),
        Point(641.933819999999855, -319.41912),
        Point(634.368779999999788, -319.02096),
        Point(606.673996489471165, -328.216209643259504),
        Point(599.976071974962565, -304.294058692839883),
        Point(653.920391923502507, -282.618546447656229),
      ]],
    ),
    
    // W44
    WalkableArea(
      id: "W44",
      floor: 1,
      coordinates: [[
        Point(709.498578634011437, -182.131278295528517),
        Point(750.208695474145657, -208.441924950725507),
        Point(744.553762759324854, -223.234077219562778),
        Point(743.215770000000816, -221.720609999999567),
        Point(730.474650000000793, -215.748209999999574),
        Point(716.33997000000079, -216.544529999999554),
        Point(705.987810000000763, -222.118769999999557),
        Point(705.049326044861346, -223.954934260054955),
        Point(694.707118843129592, -205.709184383442505),
      ]],
    ),
    
    // W45
    WalkableArea(
      id: "W45",
      floor: 1,
      coordinates: [[
        Point(702.749204806402872, -252.534600926827693),
        Point(704.594250000000784, -258.749489999999582),
        Point(707.544131058922517, -262.175158326489338),
        Point(699.400411718989858, -302.027902249919009),
        Point(669.506399999999871, -301.94985),
        Point(665.019932699573246, -303.853199763817315),
        Point(653.920391923502507, -282.618546447656229),
        Point(662.787450000000831, -279.055649999999787),
        Point(677.718450000000757, -269.499809999999798),
        Point(685.681650000000786, -259.545809999999733),
        Point(685.163795954805437, -253.5904884802531),
      ]],
    ),
    
    // W46
    WalkableArea(
      id: "W46",
      floor: 1,
      coordinates: [[
        Point(806.843637363466883, -213.300816243719197),
        Point(873.563399999999774, -213.75741),
        Point(873.36431999999968, -228.29025),
        Point(808.091123157851712, -228.29025),
      ]],
    ),
    
    // W47
    WalkableArea(
      id: "W47",
      floor: 1,
      coordinates: [[
        Point(741.67046890773463, -302.138267934484929),
        Point(699.400411718989858, -302.027902249919009),
        Point(707.544131058922517, -262.175158326489338),
        Point(716.937210000000732, -273.083249999999566),
        Point(730.076490000000831, -279.85196999999954),
        Point(745.352016860741855, -280.040556751366751),
      ]],
    ),
    
    // W48
    WalkableArea(
      id: "W48",
      floor: 1,
      coordinates: [[
        Point(785.687188447255039, -245.90698294679143),
        Point(784.076939999999809, -248.09871),
        Point(783.479699999999866, -271.39107),
        Point(785.18792273524582, -282.095932474208269),
        Point(750.97537927165763, -276.060166838450357),
        Point(758.345850000000723, -269.897969999999532),
        Point(761.332050000000777, -258.152249999999526),
        Point(760.933890000000815, -246.406529999999577),
        Point(759.160856443648527, -242.923785514307582),
      ]],
    ),
    
    // W49
    WalkableArea(
      id: "W49",
      floor: 1,
      coordinates: [[
        Point(791.880877494365677, -301.742041632628286),
        Point(803.487239999999815, -326.68554),
        Point(809.657502044938838, -339.24756067610673),
        Point(779.813260880955909, -353.338396212496889),
        Point(762.129318551484744, -320.588525362107589),
      ]],
    ),
    
    // W50
    WalkableArea(
      id: "W50",
      floor: 1,
      coordinates: [[
        Point(785.18792273524582, -282.095932474208269),
        Point(786.465899999999806, -290.10459),
        Point(791.880877494365677, -301.742041632628286),
        Point(762.129318551484744, -320.588525362107589),
        Point(754.214939999999842, -305.93145),
        Point(745.754039999999804, -302.14893),
        Point(741.67046890773463, -302.138267934484929),
        Point(745.352016860741855, -280.040556751366751),
        Point(746.201970000000756, -280.051049999999577),
        Point(750.97537927165763, -276.060166838450357),
      ]],
    ),
    
    // W51
    WalkableArea(
      id: "W51",
      floor: 1,
      coordinates: [[
        Point(808.091123157851712, -228.29025),
        Point(805.97573999999986, -228.29025),
        Point(793.035539999999855, -235.90506),
        Point(785.687188447255039, -245.90698294679143),
        Point(759.160856443648527, -242.923785514307582),
        Point(755.359650000000784, -235.457129999999552),
        Point(744.553762759324854, -223.234077219562778),
        Point(750.208695474145657, -208.441924950725507),
        Point(757.201139999999782, -212.96109),
        Point(806.843637363466883, -213.300816243719197),
      ]],
    ),
    
    // W52
    WalkableArea(
      id: "W52",
      floor: 1,
      coordinates: [[
        Point(799.304853065638554, -389.43595380591762),
        Point(779.813260880955909, -353.338396212496889),
        Point(809.657502044938838, -339.24756067610673),
        Point(826.419567960483505, -373.37340769390795),
      ]],
    ),
  ];
  


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

  // 修改获取店铺周围的可行走区域方法
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

  // 修改获取区域统计信息
  static Map<String, int> getAreaStatistics() {
    Map<int, int> floorCounts = {};
    for (WalkableArea area in areas) {
      floorCounts[area.floor] = (floorCounts[area.floor] ?? 0) + 1;
    }
    
    return {
      'totalAreas': areas.length,
      'floor1Areas': floorCounts[1] ?? 0,
      'totalStores': StoreData.stores.length, // 改为从StoreData获取
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
      if (kDebugMode) {
        print('Error loading GeoJSON data: $e');
      }
    }
  }
}

// 自定义地图画板
class MapPainter extends CustomPainter {
  final int floor;
  final double scale;
  final Offset offset;

  MapPainter({
    required this.floor,
    this.scale = 1.0,
    this.offset = Offset.zero,
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



void main() {
  runApp(const MallNavigationApp());
}

class MallNavigationApp extends StatelessWidget {
  const MallNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '商场导航',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFloor = 'F1';
  bool isFullScreen = false;
  final List<String> floors = ['F6', 'F5', 'F4', 'F3', 'F2', 'F1', 'B1', 'B2'];


  // 添加这两个变量来跟踪缩放和平移
  double _currentScale = 1.0;
  late TransformationController _transformationController;
  

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
  final Matrix4 matrix = _transformationController.value;
  final double scale = matrix.getMaxScaleOnAxis();
  // 增加阈值，减少更新频率
  if ((_currentScale - scale).abs() > 0.3) { 
    setState(() {
      _currentScale = scale;
    });
  }
}


  int _getFloorNumber(String floor) {
    switch (floor) {
      case 'F6': return 6;
      case 'F5': return 5;
      case 'F4': return 4;
      case 'F3': return 3;
      case 'F2': return 2;
      case 'F1': return 1;
      case 'B1': return -1;
      case 'B2': return -2;
      default: return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
      return Scaffold(
        body: Stack(
          children: [
            _buildFullScreenMap(),
            _buildExitFullScreenButton(),
          ],
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF9B59B6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildMapArea(),
                    _buildFloorNavigation(),
                    _buildRightSideButtons(),
                  ],
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  // 左侧楼层导航
Widget _buildFloorNavigation() {
  return Positioned(
    left: 16,
    top: 20,
    child: Container(
      width: 45, // 缩小宽度
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 指南针图标 - 缩小
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.navigation,
              color: Colors.white,
              size: 16, // 缩小图标
            ),
          ),
          
          // 楼层按钮 - 缩小版本
          Container(
            constraints: const BoxConstraints(maxHeight: 320), // 减小高度
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: floors.length,
              itemBuilder: (context, index) {
                final floor = floors[index];
                final isSelected = floor == selectedFloor;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFloor = floor;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 6), // 减小padding
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      floor,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11, // 缩小字体
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}



  // 底部导航栏
Widget _buildBottomNavigation() {
  return Container(
    margin: const EdgeInsets.all(12), // 减小margin
    padding: const EdgeInsets.symmetric(vertical: 12), 
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomNavItem(Icons.location_on, '您所在的位置', Colors.red),
        _buildBottomNavItem(Icons.shopping_bag, '商铺', Colors.grey),
        _buildBottomNavItem(Icons.stairs, '扶梯', Colors.grey),
        _buildBottomNavItem(Icons.wc, '洗手间', Colors.grey),
      ],
    ),
  );
}

  Widget _buildBottomNavItem(IconData icon, String label, Color iconColor) {
  return GestureDetector(
    onTap: () {
      print('点击了: $label');
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6), // 减小padding
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18, // 缩小图标
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9, // 缩小字体
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}


// 顶部搜索栏
Widget _buildSearchBar() {
  return Container(
    margin: const EdgeInsets.all(12), 
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 20, // 缩小图标
          ),
        ),
        const SizedBox(width: 8), 
        
        // 搜索输入框
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 减小padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20), // 稍微减小圆角
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.grey, size: 18), // 缩小图标
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Search...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // 缩小字体
                      ),
                    ),
                  ),
                  const Icon(Icons.camera_alt, color: Colors.grey, size: 18), // 缩小图标
                  const SizedBox(width: 6),
                  const Icon(Icons.mic, color: Colors.grey, size: 18), // 缩小图标
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  // 地图区域
Widget _buildMapArea() {
  return SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: FutureBuilder<void>(
      future: GeoJsonData.loadGeoJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('加载地图数据失败: ${snapshot.error}'),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            double containerHeight = constraints.maxHeight;
            double containerWidth = constraints.maxWidth;
            
            double mapAspectRatio = 2.0 / 1.0;
            double mapHeight = containerHeight;
            double mapWidth = mapHeight * mapAspectRatio;
            
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              boundaryMargin: EdgeInsets.zero,
              panEnabled: true,
              scaleEnabled: true,
              constrained: false,
              child: Container(
                width: mapWidth,
                height: mapHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: CustomPaint(
                  painter: MapPainter(
                    floor: _getFloorNumber(selectedFloor),
                    scale: _currentScale,
                  ),
                  size: Size(mapWidth, mapHeight),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}



  // 右侧功能按钮
  Widget _buildRightSideButtons() {
    return Positioned(
      right: 16,
      top: 20,
      child: GestureDetector(
        onTap: () {
          _enterFullScreen();
        },
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.fullscreen,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
      ),
    );
  }

  // 全屏地图
  Widget _buildFullScreenMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: LayoutBuilder(
        builder: (context, constraints) {
          double containerHeight = constraints.maxHeight;
          double containerWidth = constraints.maxWidth;
          
          double mapAspectRatio = 2.0 / 1.0;
          double mapWidth = containerWidth;
          double mapHeight = mapWidth * mapAspectRatio;
          
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            boundaryMargin: EdgeInsets.zero,
            panEnabled: true,
            scaleEnabled: true,
            constrained: false,
            child: SizedBox(
              width: mapHeight,
              height: mapHeight,
              child: Transform.rotate(
                angle: 1.5708,
                child: Container(
                  width: mapWidth,
                  height: mapHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Image.asset(
                    'assets/maps/$selectedFloor.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Text(
                            '👆👇 上下拖拽查看地图长边',
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 退出全屏按钮
  Widget _buildExitFullScreenButton() {
    return Positioned(
      right: 16,
      top: 50,
      child: GestureDetector(
        onTap: () {
          _exitFullScreen();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.fullscreen_exit,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // 进入全屏模式
  void _enterFullScreen() {
    setState(() {
      isFullScreen = true;
    });
  }

  // 退出全屏模式
  void _exitFullScreen() {
    setState(() {
      isFullScreen = false;
    });
  }
}

// 搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<String> searchHistory = ['星巴克', 'DIOR', 'CHANEL'];
  List<Store> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF2E86AB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: isSearching ? _buildSearchResults() : _buildSearchHistory(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 搜索头部
Widget _buildSearchHeader() {
  return Container(
    padding: const EdgeInsets.all(12), // 减小padding
    child: Row(
      children: [
        // 返回按钮 
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(6), // 减小padding
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6), // 减小圆角
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20, // 缩小图标
            ),
          ),
        ),
        const SizedBox(width: 8), // 减小间距
        
        // 搜索输入框
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8), // 减小padding
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20), // 减小圆角
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.grey, size: 16), // 缩小图标
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: const TextStyle(fontSize: 14), // 缩小字体
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(fontSize: 14), // 缩小提示文字
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8), // 减小内边距
                      isDense: true, // 使输入框更紧凑
                    ),
                    onChanged: (value) {
                      setState(() {
                        // 可以在这里实现实时搜索
                      });
                    },
                  ),
                ),
                const Icon(Icons.camera_alt, color: Colors.grey, size: 16), // 缩小图标
                const SizedBox(width: 6),
                const Icon(Icons.mic, color: Colors.grey, size: 16), // 缩小图标
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 8), // 减小间距
        
        // 搜索按钮 - 缩小版本
        GestureDetector(
          onTap: () {
            _performSearch();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 减小padding
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16), // 减小圆角
            ),
            child: const Text(
              '搜索',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12, // 缩小字体
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



  // 执行搜索
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      isSearching = true;
      searchResults = StoreData.searchStores(query);
      
      // 添加到搜索历史
      if (!searchHistory.contains(query)) {
        searchHistory.insert(0, query);
        if (searchHistory.length > 10) {
          searchHistory.removeLast();
        }
      }
    });
  }

  // 在_SearchPageState类中修改搜索结果显示
Widget _buildSearchResults() {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '搜索结果 (${searchResults.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  isSearching = false;
                  searchResults.clear();
                });
              },
              child: const Text(
                '返回',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: searchResults.isEmpty
              ? const Center(
                  child: Text(
                    '没有找到相关店铺',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final store = searchResults[index];
                    // 计算最近的可行走区域
                    final nearestArea = WalkableAreaData.findNearestWalkableArea(store.id);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          store.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${store.floor}楼 · 编号: ${store.id}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (nearestArea != null)
                              Text(
                                '最近可行走区域: $nearestArea',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        onTap: () {
                          final areaText = nearestArea != null ? ' (最近区域: $nearestArea)' : '';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('选择了店铺: ${store.name} (${store.id})$areaText'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}


  // 搜索历史
  Widget _buildSearchHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '搜索历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // 历史记录标签 - 恢复原设计
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: searchHistory.map((item) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.text = item;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchHistory.remove(item);
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}