enum DeviceType {
  reflector,   // Reflects laser at 90 deg or custom angle
  splitter,    // Splits laser into two beams (e.g. reflects 90 deg, passes straight)
  gravityWell, // Bends the laser path continuously
  bomb,        // Explodes in a radius when hit by the laser
  portal,      // Teleports laser to another portal
  floatingAsteroid, // Floating beatable asteroid that changes laser direction slightly
}

class DeviceModel {
  final String id;
  final DeviceType type;
  int gridX;
  int gridY;
  double angleDegrees; // Rotation in degrees (e.g., 0, 45, 90, 135...)
  final String? portalPairId; // Linked portal id if portal
  final double? splitAngleDegrees; // Splitting angle for splitters (45, 90, 135, 180)
  bool isPlaced;

  DeviceModel({
    required this.id,
    required this.type,
    this.gridX = 0,
    this.gridY = 0,
    this.angleDegrees = 0.0,
    this.portalPairId,
    this.splitAngleDegrees,
    this.isPlaced = false,
  });

  DeviceModel copyWith({
    String? id,
    DeviceType? type,
    int? gridX,
    int? gridY,
    double? angleDegrees,
    String? portalPairId,
    double? splitAngleDegrees,
    bool? isPlaced,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      type: type ?? this.type,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      angleDegrees: angleDegrees ?? this.angleDegrees,
      portalPairId: portalPairId ?? this.portalPairId,
      splitAngleDegrees: splitAngleDegrees ?? this.splitAngleDegrees,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      type: DeviceType.values.firstWhere((e) => e.name == json['type']),
      gridX: json['gridX'] as int? ?? 0,
      gridY: json['gridY'] as int? ?? 0,
      angleDegrees: (json['angleDegrees'] as num? ?? 0.0).toDouble(),
      portalPairId: json['portalPairId'] as String?,
      splitAngleDegrees: (json['splitAngleDegrees'] as num?)?.toDouble(),
      isPlaced: json['isPlaced'] as bool? ?? false,
    );
  }
}
