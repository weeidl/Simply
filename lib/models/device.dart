import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simply/models/device_sim_card.dart';

class Device {
  final String userId;
  final String deviceName;
  final String deviceId;
  final bool isMainDevice;
  final int? batteryLevel;
  final String? networkType;
  final Timestamp? dateUpdateInfo;
  final String? platform;
  final int? simCount;
  final int? activeSimSlot;
  final List<DeviceSimCard> simCards;
  final int todayMessageCount;
  final List<int> todaySparkline;
  final String? todaySparklineDay;
  final Timestamp? lastMessageAt;
  final int? sortOrder;

  Device({
    required this.userId,
    required this.deviceName,
    required this.deviceId,
    this.isMainDevice = false,
    this.batteryLevel,
    this.networkType,
    this.dateUpdateInfo,
    this.platform,
    this.simCount,
    this.activeSimSlot,
    this.simCards = const [],
    this.todayMessageCount = 0,
    this.todaySparkline = const [0, 0, 0, 0, 0, 0],
    this.todaySparklineDay,
    this.lastMessageAt,
    this.sortOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      'device_name': deviceName,
      'device_id': deviceId,
      "is_main_device": isMainDevice,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (networkType != null) "network_type": networkType,
      if (dateUpdateInfo != null) "date_update_info": dateUpdateInfo,
      if (platform != null) "platform": platform,
      if (simCount != null) "sim_count": simCount,
      if (activeSimSlot != null) "active_sim_slot": activeSimSlot,
      if (simCards.isNotEmpty)
        "sim_cards": simCards.map((item) => item.toMap()).toList(),
      if (todayMessageCount > 0) "today_message_count": todayMessageCount,
      if (todaySparklineDay != null) "today_sparkline": todaySparkline,
      if (todaySparklineDay != null) "today_sparkline_day": todaySparklineDay,
      if (lastMessageAt != null) "last_message_at": lastMessageAt,
      if (sortOrder != null) "sort_order": sortOrder,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    final rawSimCards = map['sim_cards'];
    final simCards = rawSimCards is Iterable
        ? rawSimCards
            .whereType<Map>()
            .map((item) =>
                DeviceSimCard.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : const <DeviceSimCard>[];
    final rawSparkline = map['today_sparkline'];

    return Device(
      userId: map['user_id']?.toString() ?? '',
      deviceName: map['device_name']?.toString() ?? '',
      deviceId: map['device_id']?.toString() ?? '',
      isMainDevice: map['is_main_device'] == true,
      batteryLevel: (map['battery_level'] as num?)?.toInt(),
      networkType: map['network_type'],
      dateUpdateInfo: map['date_update_info'],
      platform: map['platform'],
      simCount: (map['sim_count'] as num?)?.toInt(),
      activeSimSlot: (map['active_sim_slot'] as num?)?.toInt(),
      simCards: simCards,
      todayMessageCount: (map['today_message_count'] as num?)?.toInt() ?? 0,
      todaySparkline: rawSparkline is Iterable
          ? rawSparkline.map((value) => (value as num?)?.toInt() ?? 0).toList()
          : const [0, 0, 0, 0, 0, 0],
      todaySparklineDay: map['today_sparkline_day']?.toString(),
      lastMessageAt: map['last_message_at'],
      sortOrder: (map['sort_order'] as num?)?.toInt(),
    );
  }

  Device copyWith({
    String? userId,
    String? deviceName,
    String? deviceId,
    bool? isMainDevice,
    int? batteryLevel,
    String? networkType,
    Timestamp? dateUpdateInfo,
    String? platform,
    int? simCount,
    int? activeSimSlot,
    List<DeviceSimCard>? simCards,
    int? todayMessageCount,
    List<int>? todaySparkline,
    String? todaySparklineDay,
    Timestamp? lastMessageAt,
    int? sortOrder,
  }) {
    return Device(
      userId: userId ?? this.userId,
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      isMainDevice: isMainDevice ?? this.isMainDevice,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      networkType: networkType ?? this.networkType,
      dateUpdateInfo: dateUpdateInfo ?? this.dateUpdateInfo,
      platform: platform ?? this.platform,
      simCount: simCount ?? this.simCount,
      activeSimSlot: activeSimSlot ?? this.activeSimSlot,
      simCards: simCards ?? this.simCards,
      todayMessageCount: todayMessageCount ?? this.todayMessageCount,
      todaySparkline: todaySparkline ?? this.todaySparkline,
      todaySparklineDay: todaySparklineDay ?? this.todaySparklineDay,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get isReceiverOnly => platform?.toLowerCase().contains('ios') == true;

  bool get supportsRuntimeDetails =>
      !isReceiverOnly &&
      (batteryLevel != null ||
          (networkType?.trim().isNotEmpty ?? false) ||
          simCount != null ||
          simCards.isNotEmpty);

  List<int> get normalizedSparkline {
    if (todaySparkline.length == 6) return todaySparkline;
    return const [0, 0, 0, 0, 0, 0];
  }

  String get platformLabel {
    final value = platform?.toLowerCase();
    if (value == null || value.isEmpty) return 'Устройство';
    if (value.contains('ios')) return 'iOS';
    if (value.contains('android')) return 'Android';
    return platform!;
  }

  int get resolvedSimCount {
    if (simCount != null && simCount! > 0) return simCount!;
    return simCards.length;
  }

  String get simLabel {
    final count = resolvedSimCount;
    if (count <= 0) return '—';
    if (count == 1) return 'Single';
    if (count == 2) return 'Dual';
    return '$count SIM';
  }
}
