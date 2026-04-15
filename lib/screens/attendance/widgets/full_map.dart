import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FullMapPage extends StatelessWidget {
  final LatLng? location;

  const FullMapPage({super.key, this.location});

  @override
  Widget build(BuildContext context) {
    final LatLng defaultLocation = LatLng(-6.200000, 106.816666);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location"),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: location ?? defaultLocation,
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: location ?? defaultLocation,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}