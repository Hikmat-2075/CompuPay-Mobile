import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/payroll_service.dart';
import 'package:compupay_mobile/models/payslip_models.dart';
import 'package:flutter/material.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  static const Color _primaryPurple =
      Color(0xFF6B3EEA);

  static const Color _softPurple =
      Color(0xFFF1EAFF);

  static const Color _screenBg =
      Color(0xFFF5F6FA);

  @override
  State<PayslipScreen> createState() =>
      _PayslipScreenState();
}

class _PayslipScreenState
    extends State<PayslipScreen> {
  late Future<List<PayslipItem>>
      _payslipsFuture;

  @override
  void initState() {
    super.initState();

    _payslipsFuture =
        PayrollService.getPayslips();
  }

  Future<void> _refresh() async {
    setState(() {
      _payslipsFuture =
          PayrollService.getPayslips();
    });

    await _payslipsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          PayslipScreen._screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 8,
        leading: IconButton(
          onPressed: () =>
              Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color:
                PayslipScreen._primaryPurple,
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
              ),
            ),
            Text(
              'Pay',
              style: TextStyle(
                color:
                    PayslipScreen
                        ._primaryPurple,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child:
            FutureBuilder<List<PayslipItem>>(
          future: _payslipsFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color: PayslipScreen
                      ._primaryPurple,
                ),
              );
            }

            if (snapshot.hasError) {
              final error = snapshot.error;

              final message =
                  error is ApiException
                      ? error.message
                      : 'Failed to load payslip data';

              return _PayslipStateView(
                title:
                    'Unable to load payslips',
                description: message,
                actionLabel: 'Retry',
                onAction: _refresh,
              );
            }

            final slips =
                snapshot.data ??
                const <PayslipItem>[];

            if (slips.isEmpty) {
              return _PayslipStateView(
                title: 'No payslips found',
                description:
                    'No payroll data available.',
                actionLabel: 'Refresh',
                onAction: _refresh,
              );
            }

            return RefreshIndicator(
              color:
                  PayslipScreen
                      ._primaryPurple,
              onRefresh: _refresh,
              child: ListView(
                padding:
                    const EdgeInsets.all(20),
                children: [
                  const Text(
                    'My Payslips',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Track your salary, allowances and deductions.',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 28),

                  ...slips.map(
                    (slip) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: _PayslipCard(
                        slip: slip,
                        onTap: () =>
                            _showPayslipDetail(
                          context,
                          slip,
                        ),
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

  void _showPayslipDetail(
    BuildContext context,
    PayslipItem slip,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.6,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration:
                  const BoxDecoration(
                color: Color(0xFFF8F9FD),
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(
                    34,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding:
                    const EdgeInsets.fromLTRB(
                  24,
                  14,
                  24,
                  32,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Center(
                      child: Container(
                        width: 55,
                        height: 6,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey
                              .shade300,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Text(
                                'Payslip Detail',
                                style:
                                    TextStyle(
                                  fontSize:
                                      28,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color: Color(
                                    0xFF111827,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                slip.monthLabel,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  color:
                                      PayslipScreen
                                          ._primaryPurple,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () =>
                                Navigator.pop(
                              context,
                            ),
                            icon:
                                const Icon(
                              Icons
                                  .close_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(
                        24,
                      ),
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin:
                              Alignment
                                  .topLeft,
                          end: Alignment
                              .bottomRight,
                          colors: [
                            Color(
                              0xFF6B3EEA,
                            ),
                            Color(
                              0xFF9F67FF,
                            ),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Employee',
                            style: TextStyle(
                              color: Colors
                                  .white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            slip.detail
                                .employeeName,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            slip.detail
                                .employeeNumber,
                            style:
                                const TextStyle(
                              color: Colors
                                  .white70,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          const Text(
                            'Net Salary',
                            style: TextStyle(
                              color: Colors
                                  .white70,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            slip.detail
                                .totalNetSalary,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 34,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white
                                      .withValues(
                                alpha: 0.15,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                999,
                              ),
                            ),
                            child: Text(
                              slip.detail
                                  .status,
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    const Text(
                      'Earnings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ...slip.detail.earnings
                        .map(
                      (item) =>
                          _buildPayslipRow(
                        title: item.label,
                        value: item.value,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    const Text(
                      'Deductions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ...slip
                        .detail.deductions
                        .map(
                      (item) =>
                          _buildPayslipRow(
                        title: item.label,
                        value: item.value,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons
                              .download_rounded,
                        ),
                        label: const Text(
                          'Download PDF',
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              PayslipScreen
                                  ._primaryPurple,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
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
  }
}

class _PayslipCard extends StatelessWidget {
  const _PayslipCard({
    required this.slip,
    required this.onTap,
  });

  final PayslipItem slip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),
          padding:
              const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      PayslipScreen
                          ._softPurple,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: const Icon(
                  Icons
                      .receipt_long_rounded,
                  color:
                      PayslipScreen
                          ._primaryPurple,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      slip.monthLabel,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                        color: Color(
                          0xFF111827,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      slip.netPay,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        color: PayslipScreen
                            ._primaryPurple,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayslipStateView
    extends StatelessWidget {
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
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 60,
              color: PayslipScreen
                  ._primaryPurple,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPayslipRow({
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    margin:
        const EdgeInsets.only(
      bottom: 14,
    ),
    padding:
        const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
    ),
    child: Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}