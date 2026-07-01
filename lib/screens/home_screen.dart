import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/church.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Church> _churches = [];

  Future<void> _findNearestChurches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _churches = [];
    });

    try {
      // 1) جلب موقع المستخدم الحالي عبر GPS
      final position = await LocationService.getCurrentLocation();

      // 2) البحث عن الكنايس القريبة عبر Google Places API
      final churches = await PlacesService.getNearbyChurches(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 3) حساب المسافة الحقيقية (بالمتر) لكل كنيسة من موقع المستخدم
      for (final church in churches) {
        church.distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          church.latitude,
          church.longitude,
        );
      }

      // 4) ترتيب الكنايس من الأقرب للأبعد
      churches.sort(
        (a, b) => (a.distanceInMeters ?? 0).compareTo(b.distanceInMeters ?? 0),
      );

      setState(() {
        _churches = churches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openDirections(Church church) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${church.latitude},${church.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '';
    if (meters < 1000) return '${meters.toStringAsFixed(0)} متر';
    return '${(meters / 1000).toStringAsFixed(1)} كم';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أقرب كنيسة'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _findNearestChurches,
              icon: const Icon(Icons.location_searching),
              label: Text(_isLoading ? 'بنبحث...' : 'دوّر على أقرب كنيسة'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _churches.length,
                itemBuilder: (context, index) {
                  final church = _churches[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.church, color: Colors.indigo),
                      title: Text(
                        church.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${church.address}\n${_formatDistance(church.distanceInMeters)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.directions, color: Colors.green),
                        onPressed: () => _openDirections(church),
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
}
