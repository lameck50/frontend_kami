import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // The LatLng class is now from the 'latlong2' package
  final LatLng _center = const LatLng(-1.644, 29.200); // ex: Goma/Beni DRC

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carte des agents (OpenStreetMap)")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app', // Replace with your app's package name
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _center,
                child: Tooltip(
                  message: "Agent A",
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
