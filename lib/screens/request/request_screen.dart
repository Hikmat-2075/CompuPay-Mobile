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

  static const Color primaryColor = Color(0xFF6B3EEA);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

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
      MaterialPageRoute(builder: (_) => const RequestFormScreen()),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _refresh,
          child: FutureBuilder<List<LeaveRequestItem>>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final hasError = snapshot.hasError;

              final allItems = snapshot.data ?? const <LeaveRequestItem>[];
              final filteredItems = allItems.where(_matchesFilter).toList();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(onCreatePressed: _openCreateForm),
                    const SizedBox(height: 18),

                    if (!hasError) _SummarySection(items: allItems),

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

                    if (isLoading)
                      const _LoadingState()
                    else if (hasError)
                      _ErrorState(
                        message: _getErrorMessage(snapshot.error),
                        onRetry: _refresh,
                      )
                    else if (filteredItems.isEmpty)
                      _EmptyState(
                        filter: _selectedFilter,
                        onCreatePressed: _openCreateForm,
                      )
                    else
                      _RequestList(items: filteredItems),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Gagal memuat daftar pengajuan.';
  }

  bool _matchesFilter(LeaveRequestItem item) {
    final status = _normalizeStatus(item.status);

    switch (_selectedFilter) {
      case RequestFilter.all:
        return true;
      case RequestFilter.pending:
        return status == 'menunggu';
      case RequestFilter.approved:
        return status == 'disetujui';
      case RequestFilter.rejected:
        return status == 'ditolak';
    }
  }
}

enum RequestFilter { all, pending, approved, rejected }

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3EEA), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3EEA).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _HeaderIcon(),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ajukan cuti atau izin sakit dan pantau status persetujuannya di satu tempat.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onCreatePressed,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Buat Pengajuan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6B3EEA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Icon(
        Icons.assignment_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.items});

  final List<LeaveRequestItem> items;

  @override
  Widget build(BuildContext context) {
    final pending = items
        .where((item) => _normalizeStatus(item.status) == 'menunggu')
        .length;

    final approved = items
        .where((item) => _normalizeStatus(item.status) == 'disetujui')
        .length;

    final rejected = items
        .where((item) => _normalizeStatus(item.status) == 'ditolak')
        .length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total',
                value: items.length.toString(),
                icon: Icons.folder_copy_rounded,
                color: const Color(0xFF6B3EEA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'Menunggu',
                value: pending.toString(),
                icon: Icons.schedule_rounded,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Disetujui',
                value: approved.toString(),
                icon: Icons.verified_rounded,
                color: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'Ditolak',
                value: rejected.toString(),
                icon: Icons.cancel_rounded,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selectedFilter, required this.onChanged});

  final RequestFilter selectedFilter;
  final ValueChanged<RequestFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Semua',
            icon: Icons.apps_rounded,
            isSelected: selectedFilter == RequestFilter.all,
            onTap: () => onChanged(RequestFilter.all),
          ),
          _FilterChip(
            label: 'Menunggu',
            icon: Icons.schedule_rounded,
            isSelected: selectedFilter == RequestFilter.pending,
            onTap: () => onChanged(RequestFilter.pending),
          ),
          _FilterChip(
            label: 'Disetujui',
            icon: Icons.verified_rounded,
            isSelected: selectedFilter == RequestFilter.approved,
            onTap: () => onChanged(RequestFilter.approved),
          ),
          _FilterChip(
            label: 'Ditolak',
            icon: Icons.cancel_rounded,
            isSelected: selectedFilter == RequestFilter.rejected,
            onTap: () => onChanged(RequestFilter.rejected),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF6B3EEA);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? activeColor : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.items});

  final List<LeaveRequestItem> items;

  @override
  Widget build(BuildContext context) {
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
        ? const Color(0xFFEA580C)
        : const Color(0xFF6B3EEA);

    final icon = item.type == LeaveRequestType.sakit
        ? Icons.local_hospital_rounded
        : Icons.beach_access_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDEDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type.label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRange(item.startDate, item.endDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(label: _statusLabel(status), color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              item.reason.isEmpty ? 'Tidak ada keterangan.' : item.reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                item.attachment == null || item.attachment!.isEmpty
                    ? Icons.attach_file_rounded
                    : Icons.task_rounded,
                size: 17,
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.attachment == null || item.attachment!.isEmpty
                      ? 'Tidak ada lampiran'
                      : 'Lampiran tersedia',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.createdAt != null)
                Text(
                  _formatShortDate(item.createdAt!),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          width: double.infinity,
          height: 132,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEDEDF3)),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF6B3EEA)),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.wifi_off_rounded,
      iconColor: const Color(0xFFDC2626),
      title: 'Gagal memuat data',
      subtitle: message,
      buttonLabel: 'Coba Lagi',
      onPressed: onRetry,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, required this.onCreatePressed});

  final RequestFilter filter;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final isAll = filter == RequestFilter.all;

    return _StateCard(
      icon: isAll ? Icons.assignment_outlined : Icons.filter_alt_off_rounded,
      iconColor: const Color(0xFF6B3EEA),
      title: isAll ? 'Belum ada pengajuan' : 'Tidak ada data di filter ini',
      subtitle: isAll
          ? 'Buat pengajuan cuti atau izin sakit pertama kamu dari tombol di bawah.'
          : 'Coba ubah filter status untuk melihat pengajuan lain.',
      buttonLabel: isAll ? 'Buat Pengajuan' : null,
      onPressed: isAll ? onCreatePressed : null,
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEDEDF3)),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B3EEA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _normalizeStatus(String status) {
  final normalized = status.trim().toLowerCase();

  if (normalized.contains('approve') ||
      normalized.contains('approved') ||
      normalized.contains('accept') ||
      normalized.contains('accepted') ||
      normalized.contains('setuju') ||
      normalized.contains('disetujui')) {
    return 'disetujui';
  }

  if (normalized.contains('reject') ||
      normalized.contains('rejected') ||
      normalized.contains('decline') ||
      normalized.contains('declined') ||
      normalized.contains('tolak') ||
      normalized.contains('ditolak')) {
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
      return const Color(0xFF059669);
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
