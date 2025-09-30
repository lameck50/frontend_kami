import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HistoryMapScreen extends StatelessWidget {
  final List<LatLng> points;
  final String agentName;

  const HistoryMapScreen({
    super.key,
    required this.points,
    required this.agentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique de $agentName'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: points.isNotEmpty ? points[points.length ~/ 2] : const LatLng(0.49, 29.47), // Centrer sur le milieu du trajet
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              if (points.isNotEmpty)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: points.first,
                  child: const Column(
                    children: [
                      Text('Début', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Icon(Icons.flag, color: Colors.green, size: 30),
                    ],
                  ),
                ),
              if (points.length > 1)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: points.last,
                  child: const Column(
                    children: [
                      Text('Fin', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Icon(Icons.flag, color: Colors.red, size: 30),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
