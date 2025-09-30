import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/domain/entities/geofence.dart';
import 'package:kami_geoloc/features/supervisor_dashboard/presentation/providers/supervisor_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class GeofencingScreen extends StatefulWidget {
  const GeofencingScreen({Key? key}) : super(key: key);

  @override
  _GeofencingScreenState createState() => _GeofencingScreenState();
}

class _GeofencingScreenState extends State<GeofencingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupervisorProvider>(context, listen: false).fetchGeofences();
    });
  }

  void _showCreateGeofenceDialog(LatLng center) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _radiusController = TextEditingController();
    bool _alertOnEnter = true;
    bool _alertOnExit = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Créer une zone de geofencing'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom de la zone'),
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                  ),
                  TextFormField(
                    controller: _radiusController,
                    decoration: const InputDecoration(labelText: 'Rayon (en mètres)'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer un rayon' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Alerte à l\'entrée'),
                    value: _alertOnEnter,
                    onChanged: (value) => setState(() => _alertOnEnter = value),
                  ),
                  SwitchListTile(
                    title: const Text('Alerte à la sortie'),
                    value: _alertOnExit,
                    onChanged: (value) => setState(() => _alertOnExit = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final geofenceData = {
                    'name': _nameController.text,
                    'center': {'lat': center.latitude, 'lng': center.longitude},
                    'radius': double.parse(_radiusController.text),
                    'alertOnEnter': _alertOnEnter,
                    'alertOnExit': _alertOnExit,
                  };
                  final provider = Provider.of<SupervisorProvider>(context, listen: false);
                  final success = await provider.createGeofence(geofenceData);
                  if (success) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  void _showGeofenceDetailsDialog(Geofence fence) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(fence.name),
          content: Text('Rayon: ${fence.radius}m'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final provider = Provider.of<SupervisorProvider>(context, listen: false);
                final success = await provider.deleteGeofence(fence.id);
                if (success) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Zones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Comment ça marche ?'),
                  content: const Text('Appuyez longuement sur la carte pour créer une nouvelle zone de geofencing.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SupervisorProvider>(
        builder: (context, provider, child) {
          return FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(0.4911, 29.4731), // Beni
              initialZoom: 11.0,
              onLongPress: (tapPosition, point) => _showCreateGeofenceDialog(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              CircleLayer(
                circles: provider.geofences.map((fence) {
                  return CircleMarker(
                    point: fence.center,
                    radius: fence.radius,
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: provider.geofences.map((fence) {
                  return Marker(
                    point: fence.center,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _showGeofenceDetailsDialog(fence),
                      child: Tooltip(
                        message: fence.name,
                        child: const Icon(Icons.location_pin, color: Colors.blue, size: 30),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
