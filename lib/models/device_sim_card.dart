class DeviceSimCard {
  final int slot;
  final int? subscriptionId;
  final String? carrierName;
  final String? displayName;
  final bool isActive;

  const DeviceSimCard({
    required this.slot,
    this.subscriptionId,
    this.carrierName,
    this.displayName,
    this.isActive = false,
  });

  factory DeviceSimCard.fromMap(Map<String, dynamic> map) {
    return DeviceSimCard(
      slot: (map['slot'] as num?)?.toInt() ?? 1,
      subscriptionId: (map['subscription_id'] as num?)?.toInt(),
      carrierName: map['carrier_name']?.toString(),
      displayName: map['display_name']?.toString(),
      isActive: map['is_active'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slot': slot,
      'subscription_id': subscriptionId,
      'carrier_name': carrierName,
      'display_name': displayName,
      'is_active': isActive,
    };
  }

  String get label {
    final display = displayName?.trim();
    if (display != null && display.isNotEmpty) return display;

    final carrier = carrierName?.trim();
    if (carrier != null && carrier.isNotEmpty) return carrier;

    return 'SIM $slot';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceSimCard &&
        other.slot == slot &&
        other.subscriptionId == subscriptionId &&
        other.carrierName == carrierName &&
        other.displayName == displayName &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
        slot, subscriptionId, carrierName, displayName, isActive);
  }
}
