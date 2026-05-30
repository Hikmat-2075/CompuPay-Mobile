import 'package:flutter/material.dart';

class LocationStatusSection extends StatelessWidget {
  final bool insideRadius;
  final double? distanceToOffice;
  final double? radius;

  const LocationStatusSection({
    super.key,
    required this.insideRadius,
    this.distanceToOffice,
    this.radius,
  });

  String _formatDistance(double? meters) {
    if (meters == null) return '-';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(2)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = insideRadius
        ? const Color(0xFF16A34A)
        : const Color(0xFFF97316);
    final Color softColor = insideRadius
        ? const Color(0xFFEAF8EF)
        : const Color(0xFFFFF3E8);
    final String title = insideRadius
        ? 'Dalam Radius Kantor'
        : 'Di Luar Radius Kantor';
    final String description = insideRadius
        ? 'Anda berada dalam area yang diperbolehkan untuk absensi.'
        : 'Dekati area kantor agar tombol absensi dapat digunakan.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              insideRadius ? Icons.verified_rounded : Icons.warning_amber_rounded,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.near_me_rounded,
                      label: 'Jarak ${_formatDistance(distanceToOffice)}',
                    ),
                    _InfoChip(
                      icon: Icons.radar_rounded,
                      label: 'Radius ${_formatDistance(radius)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
