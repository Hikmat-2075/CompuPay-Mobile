import 'package:compupay_mobile/screens/attendance/widgets/full_map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LiveMapSection extends StatefulWidget {
  const LiveMapSection({super.key});

  @override
  State<LiveMapSection> createState() => _LiveMapSectionState();
}

class _LiveMapSectionState extends State<LiveMapSection> {
  LatLng? currentPosition;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        currentPosition = userLocation;
      });

      // Pindahkan map ke lokasi user
      mapController.move(userLocation, 16);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  void openFullMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullMapPage(location: currentPosition),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const defaultLocation = LatLng(-6.200000, 106.816666);

    return GestureDetector(
      onTap: openFullMap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentPosition ?? defaultLocation,
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),

                  if (currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPosition!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Icon expand (biar user tahu bisa diperbesar)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}