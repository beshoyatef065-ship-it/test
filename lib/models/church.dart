/// موديل بيانات الكنيسة القادمة من Google Places API
class Church {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  /// المسافة بالمتر من موقع المستخدم - يتم حسابها بعد معرفة موقعه
  double? distanceInMeters;

  Church({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceInMeters,
  });

  /// تحويل استجابة JSON من Google Places API لـ Church
  factory Church.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return Church(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'بدون اسم',
      address: json['vicinity'] ?? json['formatted_address'] ?? '',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }
}
