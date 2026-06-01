import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/payroll_service.dart';
import 'package:compupay_mobile/models/payslip_models.dart';
import 'package:compupay_mobile/screens/payslip/payslip_theme.dart';
import 'package:flutter/material.dart';

void showPayslipDetailSheet(BuildContext context, PayslipItem slip) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      bool isDownloading = false;

      Future<void> downloadPayslipPdf(StateSetter setModalState) async {
        if (isDownloading) return;

        setModalState(() {
          isDownloading = true;
        });

        try {
          final file = await PayrollService.downloadPayslipPdf(
            payrollId: slip.id,
            fileName: 'payslip-${slip.monthLabel}',
          );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF berhasil disimpan: ${file.path}')),
          );
        } on ApiException catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        } catch (_) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal download PDF')),
          );
        } finally {
          if (context.mounted) {
            setModalState(() {
              isDownloading = false;
            });
          }
        }
      }

      return StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.82,
            minChildSize: 0.6,
            maxChildSize: 0.92,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    14,
                    24,
                    MediaQuery.of(context).padding.bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 55,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payslip Detail',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: PayslipTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  slip.monthLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: PayslipTheme.primaryPurple,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _PayslipSummaryCard(slip: slip),
                      const SizedBox(height: 28),
                      const _DetailSectionTitle(title: 'Earnings'),
                      const SizedBox(height: 16),
                      ...slip.detail.earnings.map(
                        (item) => _PayslipRow(
                          title: item.label,
                          value: item.value,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const _DetailSectionTitle(title: 'Deductions'),
                      const SizedBox(height: 16),
                      ...slip.detail.deductions.map(
                        (item) => _PayslipRow(
                          title: item.label,
                          value: item.value,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isDownloading
                              ? null
                              : () => downloadPayslipPdf(setModalState),
                          icon: isDownloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          label: Text(
                            isDownloading
                                ? 'Downloading...'
                                : 'Download PDF',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PayslipTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                PayslipTheme.primaryPurple.withOpacity(0.6),
                            disabledForegroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

class _PayslipSummaryCard extends StatelessWidget {
  const _PayslipSummaryCard({required this.slip});

  final PayslipItem slip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PayslipTheme.primaryPurple, Color(0xFF9F67FF)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            slip.detail.employeeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            slip.detail.employeeNumber,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 28),
          const Text(
            'Net Salary',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            slip.detail.totalNetSalary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              slip.detail.status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: PayslipTheme.textPrimary,
      ),
    );
  }
}

class _PayslipRow extends StatelessWidget {
  const _PayslipRow({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PayslipTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}