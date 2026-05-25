import 'dart:io';

import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/leave_request_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/models/leave_request_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RequestFormScreen extends StatefulWidget {
  const RequestFormScreen({super.key});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _reasonController = TextEditingController();

  LeaveRequestType _selectedType = LeaveRequestType.cuti;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _attachmentFile;
  bool _isSubmitting = false;
  bool _isLoadingIdentity = true;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadIdentity() async {
    final employeeName = await SessionService.getEmployeeName();
    final employeeId = await SessionService.getEmployeeId();

    if (!mounted) {
      return;
    }

    setState(() {
      _nameController.text = employeeName ?? '';
      _employeeIdController.text = employeeId ?? '';
      _isLoadingIdentity = false;
    });
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: false,
    );

    final path = result?.files.single.path;
    if (path == null) {
      return;
    }

    setState(() {
      _attachmentFile = File(path);
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _employeeIdController.text.trim().isEmpty) {
      _showError('Data karyawan belum tersedia. Silakan login ulang.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('Tanggal mulai dan selesai wajib diisi');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('Tanggal selesai harus sama atau setelah tanggal mulai');
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
        attachment: _attachmentFile,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Terjadi kesalahan saat mengirim pengajuan');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Buat Pengajuan',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi form di bawah ini untuk mengajukan cuti atau izin sakit.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(
                            label: 'Nama Lengkap',
                            isLoading: _isLoadingIdentity,
                          ),
                          const SizedBox(height: 10),
                          _ReadOnlyField(
                            controller: _nameController,
                            hintText: 'Nama karyawan',
                            icon: Icons.person_outline,
                            isLoading: _isLoadingIdentity,
                          ),
                          const SizedBox(height: 14),
                          _SectionLabel(
                            label: 'ID Karyawan',
                            isLoading: _isLoadingIdentity,
                          ),
                          const SizedBox(height: 10),
                          _ReadOnlyField(
                            controller: _employeeIdController,
                            hintText: 'ID karyawan',
                            icon: Icons.badge_outlined,
                            isLoading: _isLoadingIdentity,
                          ),
                          const SizedBox(height: 14),
                          const _SectionLabel(label: 'Tipe Pengajuan'),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<LeaveRequestType>(
                            initialValue: _selectedType,
                            decoration: _inputDecoration(
                              hintText: 'Pilih jenis pengajuan...',
                            ),
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
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DatePickerField(
                                  label: 'Tanggal Mulai',
                                  value: _startDate,
                                  onTap: () => _pickDate(isStart: true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _DatePickerField(
                                  label: 'Tanggal Selesai',
                                  value: _endDate,
                                  onTap: () => _pickDate(isStart: false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const _SectionLabel(label: 'Alasan / Keterangan'),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _reasonController,
                            minLines: 4,
                            maxLines: 6,
                            decoration: _inputDecoration(
                              hintText:
                                  'Tuliskan alasan pengajuan Anda secara singkat...',
                              alignTop: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Alasan wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(
                            label: 'Unggah Dokumen Pendukung (Opsional)',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lampirkan surat keterangan dokter atau dokumen terkait lainnya.',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: _pickAttachment,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 28,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFD6D3E8),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3E8FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.upload_file_rounded,
                                      color: Color(0xFF6B3EEA),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    _attachmentFile == null
                                        ? 'Pilih file atau tarik ke sini'
                                        : _attachmentFile!.path.split(Platform.pathSeparator).last,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Maks. 5MB (PDF, JPG, PNG)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B3EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Kirim Pengajuan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    bool alignTop = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: alignTop ? 16 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6B3EEA)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.isLoading = false});

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: Color(0xFF374151),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.isLoading,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: isLoading ? 'Memuat data akun...' : hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? 'mm/dd/yyyy' : _formatShortDate(value!),
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
