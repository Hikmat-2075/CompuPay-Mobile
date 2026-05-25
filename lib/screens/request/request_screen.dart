import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/leave_request_service.dart';
import 'package:compupay_mobile/models/leave_request_models.dart';
import 'package:flutter/material.dart';

import 'request_form_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  late Future<List<LeaveRequestItem>> _requestsFuture;
  RequestFilter _selectedFilter = RequestFilter.all;

  @override
  void initState() {
    super.initState();
    _requestsFuture = LeaveRequestService.list();
  }

  Future<void> _refresh() async {
    setState(() {
      _requestsFuture = LeaveRequestService.list();
    });

    await _requestsFuture;
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RequestFormScreen(),
      ),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        backgroundColor: const Color(0xFF6B3EEA),
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add, size: 30),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeaderSection(),
                const SizedBox(height: 18),
                _FilterBar(
                  selectedFilter: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                _buildRequestList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return FutureBuilder<List<LeaveRequestItem>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ApiException
              ? error.message
              : 'Gagal memuat daftar pengajuan';

          return _EmptyState(
            title: 'Gagal memuat data',
            subtitle: message,
          );
        }

        final items = (snapshot.data ?? const <LeaveRequestItem>[])
            .where(_matchesFilter)
            .toList(growable: false);

        if (items.isEmpty) {
          return const _EmptyState(
            title: 'Belum ada pengajuan',
            subtitle: 'Tekan tombol + untuk membuat surat izin pertama kamu.',
          );
        }

        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _RequestCard(item: item),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  bool _matchesFilter(LeaveRequestItem item) {
    switch (_selectedFilter) {
      case RequestFilter.all:
        return true;
      case RequestFilter.pending:
        return _normalizeStatus(item.status) == 'menunggu';
      case RequestFilter.approved:
        return _normalizeStatus(item.status) == 'disetujui';
    }
  }
}

enum RequestFilter { all, pending, approved }

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengajuan Izin',
          style: TextStyle(
            fontSize: 31,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Kelola dan pantau status pengajuan cuti atau izin Anda.',
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedFilter,
    required this.onChanged,
  });

  final RequestFilter selectedFilter;
  final ValueChanged<RequestFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            label: 'Semua',
            isSelected: selectedFilter == RequestFilter.all,
            onTap: () => onChanged(RequestFilter.all),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterChip(
            label: 'Menunggu',
            isSelected: selectedFilter == RequestFilter.pending,
            onTap: () => onChanged(RequestFilter.pending),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterChip(
            label: 'Disetujui',
            isSelected: selectedFilter == RequestFilter.approved,
            onTap: () => onChanged(RequestFilter.approved),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF6B3EEA);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? const Color(0xFFE9D5FF) : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? activeColor : const Color(0xFF4B5563),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item});

  final LeaveRequestItem item;

  @override
  Widget build(BuildContext context) {
    final status = _normalizeStatus(item.status);
    final statusColor = _statusColor(status);
    final accentColor = item.type == LeaveRequestType.sakit
        ? const Color(0xFFB7791F)
        : const Color(0xFF6B3EEA);
    final icon = item.type == LeaveRequestType.sakit
        ? Icons.healing_rounded
        : Icons.flight_takeoff_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.type.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        _StatusChip(
                          label: _statusLabel(status),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatRange(item.startDate, item.endDate),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${item.reason}"',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Color(0xFF6B3EEA),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

String _normalizeStatus(String status) {
  final normalized = status.trim().toLowerCase();

  if (normalized.contains('approve') || normalized.contains('setuju')) {
    return 'disetujui';
  }

  if (normalized.contains('reject') || normalized.contains('tolak')) {
    return 'ditolak';
  }

  return 'menunggu';
}

String _statusLabel(String status) {
  switch (status) {
    case 'disetujui':
      return 'DISETUJUI';
    case 'ditolak':
      return 'DITOLAK';
    case 'menunggu':
    default:
      return 'MENUNGGU';
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'disetujui':
      return const Color(0xFF7C3AED);
    case 'ditolak':
      return const Color(0xFFDC2626);
    case 'menunggu':
    default:
      return const Color(0xFFD97706);
  }
}

String _formatRange(DateTime start, DateTime end) {
  if (_sameDay(start, end)) {
    return _formatShortDate(start);
  }

  return '${_formatShortDate(start)} - ${_formatShortDate(end)}';
}

bool _sameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatShortDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
}
