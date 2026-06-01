import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/payroll_service.dart';
import 'package:compupay_mobile/models/payslip_models.dart';
import 'package:compupay_mobile/screens/payslip/payslip_theme.dart';
import 'package:compupay_mobile/screens/payslip/widgets/payslip_card.dart';
import 'package:compupay_mobile/screens/payslip/widgets/payslip_detail_sheet.dart';
import 'package:compupay_mobile/screens/payslip/widgets/payslip_header.dart';
import 'package:compupay_mobile/screens/payslip/widgets/payslip_state_view.dart';
import 'package:flutter/material.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

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
      backgroundColor: PayslipTheme.screenBg,
      body: SafeArea(
        top: true,
        bottom: false,
        child: FutureBuilder<List<PayslipItem>>(
          future: _payslipsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: PayslipTheme.primaryPurple,
                ),
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error;

              final message = error is ApiException
                  ? error.message
                  : 'Failed to load payslip data';

              return PayslipStateView(
                title: 'Unable to load payslips',
                description: message,
                actionLabel: 'Retry',
                onAction: _refresh,
              );
            }

            final slips = snapshot.data ?? const <PayslipItem>[];

            if (slips.isEmpty) {
              return PayslipStateView(
                title: 'No payslips found',
                description: 'No payroll data available.',
                actionLabel: 'Refresh',
                onAction: _refresh,
              );
            }

            return RefreshIndicator(
              color: PayslipTheme.primaryPurple,
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  const PayslipHeader(),
                  const SizedBox(height: 24),
                  ...slips.map(
                    (slip) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PayslipCard(
                        slip: slip,
                        onTap: () => showPayslipDetailSheet(context, slip),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
