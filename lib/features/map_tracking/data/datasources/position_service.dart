import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PositionService {
  Timer? _timer;
  final String apiUrl;
  final String token; // Bearer token

  PositionService({required this.apiUrl, required this.token});

  Future<void> start({Duration interval = const Duration(seconds: 30)}) async {
    bool ok = await _ensurePermission();
    if (!ok) return;
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _sendOnce());
  }

  Future<bool> _ensurePermission() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> _sendOnce() async {
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final body = jsonEncode({
      'lat': pos.latitude,
      'lon': pos.longitude,
      'accuracy': pos.accuracy,
      'timestamp': DateTime.now().toIso8601String()
    });
    try {
      await http.post(Uri.parse('$apiUrl/api/positions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: body);
    } catch (e) {
      // gestion d'erreur réseau
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
