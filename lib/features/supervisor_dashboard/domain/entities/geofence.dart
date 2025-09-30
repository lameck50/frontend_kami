import 'package:latlong2/latlong.dart';

class Geofence {
  final String id;
  final String name;
  final LatLng center;
  final double radius;
  final bool alertOnEnter;
  final bool alertOnExit;

  Geofence({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
    required this.alertOnEnter,
    required this.alertOnExit,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['_id'],
      name: json['name'],
      center: LatLng(json['center']['lat'], json['center']['lng']),
      radius: json['radius'].toDouble(),
      alertOnEnter: json['alertOnEnter'],
      alertOnExit: json['alertOnExit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'center': {'lat': center.latitude, 'lng': center.longitude},
      'radius': radius,
      'alertOnEnter': alertOnEnter,
      'alertOnExit': alertOnExit,
    };
  }
}
