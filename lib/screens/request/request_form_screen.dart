import 'dart:io';

import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/leave_request_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/models/leave_request_models.dart';
import 'package:compupay_mobile/core/utils/jwt_utils.dart';
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

  static const Color primaryColor = Color(0xFF6B3EEA);
  static const Color backgroundColor = Color(0xFFF7F7FB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

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
    String? employeeName = await SessionService.getEmployeeName();
    String? employeeId = await SessionService.getEmployeeId();

    if ((employeeName == null || employeeName.trim().isEmpty) ||
        (employeeId == null || employeeId.trim().isEmpty)) {
      final token = await SessionService.getToken();
      final payload = token == null ? null : JwtUtils.decodePayload(token);

      employeeName ??= JwtUtils.getString(payload, const [
        'name',
        'fullName',
        'full_name',
        'fullname',
        'employeeName',
        'employee_name',
        'username',
      ]);

      employeeId ??= JwtUtils.getString(payload, const [
        'id',
        'userId',
        'user_id',
        'employeeId',
        'employee_id',
        'employeeNumber',
        'employee_number',
        'nip',
      ]);

      final role = JwtUtils.getString(payload, const ['role']);

      final position = JwtUtils.getString(payload, const [
        'position',
        'jabatan',
      ]);

      await SessionService.saveUserProfile(
        employeeName: employeeName,
        employeeId: employeeId,
        role: role,
        position: position,
      );
    }

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
    final now = DateTime.now();

    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final firstDate = isStart
        ? now.subtract(const Duration(days: 365))
        : (_startDate ?? now.subtract(const Duration(days: 365)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
      confirmText: 'Pilih',
      cancelText: 'Batal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

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
    if (path == null) return;

    setState(() {
      _attachmentFile = File(path);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        _employeeIdController.text.trim().isEmpty) {
      _showError('Data karyawan belum tersedia. Silakan login ulang.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('Tanggal mulai dan selesai wajib diisi.');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('Tanggal selesai harus sama atau setelah tanggal mulai.');
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan berhasil dikirim.'),
          backgroundColor: Color(0xFF059669),
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Terjadi kesalahan saat mengirim pengajuan.');
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  int? get _durationDays {
    if (_startDate == null || _endDate == null) return null;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  String get _attachmentName {
    final file = _attachmentFile;
    if (file == null) return '';

    return file.path.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    final durationDays = _durationDays;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textPrimary,
        title: const Text(
          'Buat Pengajuan',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: const Color(0xFFC4B5FD),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const _IntroCard(),
                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Data Karyawan',
                  subtitle:
                      'Data ini diambil otomatis dari akun yang sedang login.',
                  icon: Icons.account_circle_rounded,
                  child: Column(
                    children: [
                      _ReadOnlyField(
                        label: 'Nama Lengkap',
                        controller: _nameController,
                        hintText: 'Nama karyawan',
                        icon: Icons.person_outline_rounded,
                        isLoading: _isLoadingIdentity,
                      ),
                      const SizedBox(height: 14),
                      _ReadOnlyField(
                        label: 'ID Karyawan',
                        controller: _employeeIdController,
                        hintText: 'ID karyawan',
                        icon: Icons.badge_outlined,
                        isLoading: _isLoadingIdentity,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Detail Pengajuan',
                  subtitle:
                      'Pilih jenis, rentang tanggal, dan tuliskan alasan pengajuan.',
                  icon: Icons.assignment_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Jenis Pengajuan'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeOptionCard(
                              title: 'Cuti',
                              subtitle: 'Libur / keperluan pribadi',
                              icon: Icons.beach_access_rounded,
                              isSelected:
                                  _selectedType == LeaveRequestType.cuti,
                              onTap: () {
                                setState(() {
                                  _selectedType = LeaveRequestType.cuti;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeOptionCard(
                              title: 'Sakit',
                              subtitle: 'Izin karena sakit',
                              icon: Icons.local_hospital_rounded,
                              isSelected:
                                  _selectedType == LeaveRequestType.sakit,
                              onTap: () {
                                setState(() {
                                  _selectedType = LeaveRequestType.sakit;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const _FieldLabel('Tanggal Pengajuan'),
                      const SizedBox(height: 10),
                      _DatePickerField(
                        label: 'Tanggal Mulai',
                        value: _startDate,
                        onTap: () => _pickDate(isStart: true),
                      ),
                      const SizedBox(height: 12),
                      _DatePickerField(
                        label: 'Tanggal Selesai',
                        value: _endDate,
                        onTap: () => _pickDate(isStart: false),
                      ),

                      if (durationDays != null) ...[
                        const SizedBox(height: 12),
                        _DurationInfo(days: durationDays),
                      ],

                      const SizedBox(height: 18),

                      const _FieldLabel('Alasan / Keterangan'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _reasonController,
                        minLines: 4,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                        decoration: _inputDecoration(
                          hintText:
                              'Contoh: Saya mengajukan cuti karena ada keperluan keluarga...',
                          alignTop: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alasan wajib diisi.';
                          }

                          if (value.trim().length < 8) {
                            return 'Alasan terlalu singkat.';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _SectionCard(
                  title: 'Dokumen Pendukung',
                  subtitle: _selectedType == LeaveRequestType.sakit
                      ? 'Untuk izin sakit, lampiran surat dokter disarankan.'
                      : 'Lampiran bersifat opsional jika diperlukan.',
                  icon: Icons.attach_file_rounded,
                  child: _AttachmentPicker(
                    fileName: _attachmentName,
                    hasFile: _attachmentFile != null,
                    onPick: _pickAttachment,
                    onRemove: () {
                      setState(() {
                        _attachmentFile = null;
                      });
                    },
                  ),
                ),
              ],
            ),
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
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: alignTop ? 16 : 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3EEA), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3EEA).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.edit_document,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Isi data dengan benar agar proses persetujuan lebih cepat.',
                  style: TextStyle(
                    color: Color(0xFFEDE9FE),
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          _SectionHeader(title: title, subtitle: subtitle, icon: icon),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF6B3EEA), size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.45,
        color: Color(0xFF374151),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: isLoading ? 'Memuat data akun...' : hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6B3EEA),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TypeOptionCard extends StatelessWidget {
  const _TypeOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = title == 'Sakit'
        ? const Color(0xFFEA580C)
        : const Color(0xFF6B3EEA);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.10)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE5E7EB),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: activeColor, size: 22),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? activeColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? activeColor
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
    final hasValue = value != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasValue
                  ? const Color(0xFFDDD6FE)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 22,
                  color: Color(0xFF6B3EEA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasValue ? _formatShortDate(value!) : 'Pilih tanggal',
                      style: TextStyle(
                        color: hasValue
                            ? const Color(0xFF111827)
                            : const Color(0xFF9CA3AF),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationInfo extends StatelessWidget {
  const _DurationInfo({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_rounded,
            color: Color(0xFF059669),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Durasi pengajuan: $days hari',
              style: const TextStyle(
                color: Color(0xFF047857),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  const _AttachmentPicker({
    required this.fileName,
    required this.hasFile,
    required this.onPick,
    required this.onRemove,
  });

  final String fileName;
  final bool hasFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (hasFile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD6D3E8)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFF6B3EEA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD6D3E8), width: 1.2),
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
                  Icons.cloud_upload_rounded,
                  color: Color(0xFF6B3EEA),
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pilih dokumen pendukung',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Format PDF, JPG, JPEG, atau PNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
