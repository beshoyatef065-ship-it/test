import 'package:geolocator/geolocator.dart';

/// مسؤول عن طلب صلاحية الموقع وجلب موقع المستخدم الحالي (GPS)
class LocationService {
  static Future<Position> getCurrentLocation() async {
    // 1) هل خدمة الموقع مفعّلة على الجهاز أصلاً؟
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'خدمة الموقع (GPS) مقفولة على الجهاز. افتحها من الإعدادات وحاول تاني.',
      );
    }

    // 2) هل عندنا صلاحية الوصول للموقع؟
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'لازم تسمح للتطبيق بالوصول لموقعك عشان يلاقي أقرب كنيسة.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'صلاحية الموقع مرفوضة بشكل نهائي. لازم تفعّلها من إعدادات الجهاز.',
      );
    }

    // 3) جلب الموقع الحالي بأعلى دقة ممكنة
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
