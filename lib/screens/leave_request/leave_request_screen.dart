import 'dart:io';

import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/leave_request_service.dart';
import 'package:compupay_mobile/models/leave_request_models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  LeaveRequestType _selectedType = LeaveRequestType.cuti;
  DateTime? _startDate;
  DateTime? _endDate;
  XFile? _pickedAttachment;
  bool _isSubmitting = false;

  late Future<List<LeaveRequestItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = LeaveRequestService.list();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) {
      return;
    }

    setState(() {
      _pickedAttachment = file;
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('Start date dan end date wajib diisi');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('endDate harus lebih besar atau sama dengan startDate');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await LeaveRequestService.create(
        payload: LeaveRequestCreatePayload(
          type: _selectedType,
          startDate: _startDate!,
          endDate: _endDate!,
          reason: _reasonController.text.trim(),
        ),
        attachment: _pickedAttachment != null ? File(_pickedAttachment!.path) : null,
      );

      if (!mounted) {
        return;
      }

      _showSuccess('Surat izin berhasil dibuat');
      _clearForm();
      setState(() {
        _historyFuture = LeaveRequestService.list();
      });
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Terjadi kesalahan saat membuat leave request');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _reasonController.clear();
    setState(() {
      _selectedType = LeaveRequestType.cuti;
      _startDate = null;
      _endDate = null;
      _pickedAttachment = null;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Leave Request',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _historyFuture = LeaveRequestService.list();
            });
            await _historyFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormCard(),
                const SizedBox(height: 16),
                const Text(
                  'Riwayat Pengajuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                _buildHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Surat Izin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Field wajib: type, startDate, endDate, reason',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<LeaveRequestType>(
              initialValue: _selectedType,
              decoration: _inputDecoration('Type'),
              items: LeaveRequestType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    value: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateField(
                    label: 'End Date',
                    value: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              minLines: 3,
              maxLines: 4,
              decoration: _inputDecoration('Reason'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reason wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pickedAttachment == null
                        ? 'Attachment: tidak ada file'
                        : 'Attachment: ${_pickedAttachment!.name}',
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickAttachment,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Pilih'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B3EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Leave Request',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return FutureBuilder<List<LeaveRequestItem>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is ApiException
              ? error.message
              : 'Gagal memuat riwayat leave request';

          return _StateInfoCard(
            title: 'Gagal memuat data',
            subtitle: message,
          );
        }

        final items = snapshot.data ?? const <LeaveRequestItem>[];
        if (items.isEmpty) {
          return const _StateInfoCard(
            title: 'Belum ada pengajuan',
            subtitle: 'Silakan buat surat izin pertama kamu melalui form di atas.',
          );
        }

        return Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryCard(item: item),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B3EEA)),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value == null ? 'Pilih tanggal' : _formatDate(value!),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final LeaveRequestItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.reason,
            style: const TextStyle(
              color: Color(0xFF374151),
              height: 1.35,
            ),
          ),
          if (item.attachment != null && item.attachment!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Attachment: ${item.attachment}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StateInfoCard extends StatelessWidget {
  const _StateInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED':
      return const Color(0xFF047857);
    case 'REJECT':
      return const Color(0xFFB91C1C);
    case 'PENDING':
    default:
      return const Color(0xFF92400E);
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}
