import 'package:compupay_mobile/screens/attendance/widgets/full_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LiveMapSection extends StatefulWidget {
  final double? officeLatitude;
  final double? officeLongitude;
  final double? radius;
  final Position? userPosition;

  const LiveMapSection({
    super.key,
    this.officeLatitude,
    this.officeLongitude,
    this.radius,
    this.userPosition,
  });

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

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final userLocation = LatLng(position.latitude, position.longitude);
      setState(() => currentPosition = userLocation);
      mapController.move(userLocation, 16);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void openFullMap() {
    final location = widget.userPosition != null
        ? LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude)
        : currentPosition;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullMapPage(location: location)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const defaultLocation = LatLng(-6.200000, 106.816666);
    final officeLocation =
        (widget.officeLatitude != null && widget.officeLongitude != null)
            ? LatLng(widget.officeLatitude!, widget.officeLongitude!)
            : null;
    final userLoc = widget.userPosition != null
        ? LatLng(widget.userPosition!.latitude, widget.userPosition!.longitude)
        : currentPosition;

    return GestureDetector(
      onTap: openFullMap,
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: userLoc ?? officeLocation ?? defaultLocation,
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  if (officeLocation != null && widget.radius != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: officeLocation,
                          radius: widget.radius!,
                          useRadiusInMeter: true,
                          color: const Color(0x336D28D9),
                          borderStrokeWidth: 2,
                          borderColor: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  if (userLoc != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLoc,
                          width: 46,
                          height: 46,
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 42,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  if (officeLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: officeLocation,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              size: 28,
                              color: Color(0xFF6D28D9),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                left: 14,
                top: 14,
                child: _MapBadge(
                  icon: Icons.my_location_rounded,
                  label: userLoc == null ? 'Mencari lokasi' : 'Live Location',
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fullscreen_rounded, size: 22),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0x99000000)],
                    ),
                  ),
                  child: const Text(
                    'Ketuk peta untuk melihat lebih besar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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

class _MapBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MapBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF6D28D9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
