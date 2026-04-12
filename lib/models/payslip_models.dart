class PayslipItem {
  final String month;
  final String netPay;

  const PayslipItem({
    required this.month,
    required this.netPay,
  });
}

class PayslipData {
  static const list = [
    PayslipItem(month: 'December 2025', netPay: '\$5,240.00'),
    PayslipItem(month: 'November 2025', netPay: '\$5,240.00'),
    PayslipItem(month: 'October 2025', netPay: '\$5,240.00'),
  ];
}