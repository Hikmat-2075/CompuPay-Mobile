import 'package:compupay_mobile/core/exceptions/api_exception.dart';

import 'package:compupay_mobile/core/services/payroll_service.dart';

import 'package:compupay_mobile/models/payslip_models.dart';

import 'package:flutter/material.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  static const Color _primaryPurple = Color(0xFF6B3EEA);

  static const Color _softPurple = Color(0xFFF1EAFF);

  static const Color _screenBg = Color(0xFFF5F6FA);

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  late Future<List<PayslipItem>> _payslipsFuture;

  @override
  void initState() {
    super.initState();

    _payslipsFuture = PayrollService.getPayslips();
  }

  Future<void> _refresh() async {
    setState(() {
      _payslipsFuture = PayrollService.getPayslips();
    });

    await _payslipsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PayslipScreen._screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu_rounded,
            color: PayslipScreen._primaryPurple,
          ),
        ),
        title: const Row(
          children: [
            Text(
              'Compu',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Pay',
              style: TextStyle(
                color: PayslipScreen._primaryPurple,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFD1F0FF),
              child: Icon(Icons.person, color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<PayslipItem>>(
          future: _payslipsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: PayslipScreen._primaryPurple,
                ),
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error;
              final message = error is ApiException
                  ? error.message
                  : 'The app could not load payslip data.';

              return _PayslipStateView(
                title: 'Unable to load payslips',
                description: message,
                actionLabel: 'Retry',
                onAction: _refresh,
              );
            }

            final slips = snapshot.data ?? const <PayslipItem>[];

            if (slips.isEmpty) {
              return _PayslipStateView(
                title: 'No payslips found',
                description:
                    'The API returned no payslip records for the current account.',
                actionLabel: 'Refresh',
                onAction: _refresh,
              );
            }

            return RefreshIndicator(
              color: PayslipScreen._primaryPurple,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'My Payslips',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101828),
                              letterSpacing: -1,
                              height: 1.05,
                            ),
                          ),
                          Text(
                            'HISTORY',
                            style: TextStyle(
                              color: PayslipScreen._primaryPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Access and download your monthly financial\nstatements.',
                        style: TextStyle(
                          fontSize: 19,
                          color: Color(0xFF4B5563),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      for (final slip in slips) ...[
                        _PayslipCard(
                          slip: slip,
                          onTap: () => _showPayslipDetail(context, slip),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const SizedBox(height: 12),
                      _AnnualSummaryCard(
                        onPressed: () =>
                            _showPayslipDetail(context, slips.first),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPayslipDetail(BuildContext context, PayslipItem slip) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.77,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7FB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4EC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Payslip Detail',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slip.monthLabel,
                                    style: const TextStyle(
                                      color: PayslipScreen._primaryPurple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0F1F5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, size: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Total Net Salary',
                                style: TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slip.netPay,
                                style: const TextStyle(
                                  color: PayslipScreen._primaryPurple,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (slip.detail.earnings.isNotEmpty) ...[
                          const _SectionTitle(
                            icon: Icons.add_circle_outline,
                            title: 'EARNINGS',
                            color: PayslipScreen._primaryPurple,
                          ),
                          const SizedBox(height: 10),
                          for (final item in slip.detail.earnings) ...[
                            _AmountRow(label: item.label, value: item.value),
                          ],
                          const SizedBox(height: 20),
                        ],
                        if (slip.detail.deductions.isNotEmpty) ...[
                          const _SectionTitle(
                            icon: Icons.remove_circle_outline,
                            title: 'DEDUCTIONS',
                            color: Color(0xFFB42318),
                          ),
                          const SizedBox(height: 10),
                          for (final item in slip.detail.deductions) ...[
                            _AmountRow(
                              label: item.label,
                              value: item.value,
                              valueColor: const Color(0xFFB42318),
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B3EEA), Color(0xFF7B4DF0)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: PayslipScreen._primaryPurple
                                      .withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'PDF download is not wired yet.',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                              ),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Download PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PayslipCard extends StatelessWidget {
  const _PayslipCard({required this.slip, required this.onTap});

  final PayslipItem slip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: PayslipScreen._softPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: PayslipScreen._primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slip.monthLabel,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NET PAY: ${slip.netPay}',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC5C7D0),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayslipStateView extends StatelessWidget {
  const _PayslipStateView({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 54,
              color: Color(0xFF6B3EEA),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _AnnualSummaryCard extends StatelessWidget {
  const _AnnualSummaryCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFE5D8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'TAX PREPARATION',
              style: TextStyle(
                color: Color(0xFF9A6D35),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Annual Summary Ready',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Your 2025 financial year summary is now\navailable for download. Perfect for tax\nfilings.',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B3EEA), Color(0xFF7B4DF0)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B3EEA).withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Download 2025 Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF111827),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
