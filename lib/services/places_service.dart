import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/church.dart';

/// مسؤول عن البحث عن الكنايس القريبة باستخدام Google Places API
class PlacesService {
  // ⚠️ ضع مفتاح Google Places API الخاص بيك هنا (من Google Cloud Console)
  // لازم يكون عليه تفعيل "Places API" والـ Billing مفعّل على المشروع
  static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';

  /// يبحث عن أقرب الكنايس حول نقطة معينة (lat, lng)
  /// radius بالمتر - افتراضياً 10 كم
  static Future<List<Church>> getNearbyChurches({
    required double latitude,
    required double longitude,
    int radius = 10000,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$latitude,$longitude'
      '&radius=$radius'
      '&type=church'
      '&language=ar'
      '&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'فشل الاتصال بـ Google Places API (كود ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      // أشهر الأخطاء: REQUEST_DENIED (مفتاح غلط أو Billing غير مفعّل)
      throw Exception('خطأ من Google Places: ${data['status']}');
    }

    final List results = (data['results'] as List?) ?? [];
    return results.map((json) => Church.fromJson(json)).toList();
  }
}
