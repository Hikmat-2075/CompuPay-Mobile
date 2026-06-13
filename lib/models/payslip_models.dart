class PayslipItem {
  final String id;
  final String monthLabel;
  final String netPay;
  final PayslipDetail detail;

  const PayslipItem({
    required this.id,
    required this.monthLabel,
    required this.netPay,
    required this.detail,
  });

  factory PayslipItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final detail = PayslipDetail.fromJson(json);

    return PayslipItem(
      id: json['id']?.toString() ?? '',
      monthLabel: _formatMonth(
        json['date_to'],
      ),
      netPay: _formatCurrency(
        json['net'],
      ),
      detail: detail,
    );
  }
}

class PayslipDetail {
  final String? periodLabel;
  final String totalNetSalary;
  final List<PayslipLineItem> earnings;
  final List<PayslipLineItem> deductions;
  final String employeeName;
  final String employeeNumber;
  final String status;

  const PayslipDetail({
    required this.periodLabel,
    required this.totalNetSalary,
    required this.earnings,
    required this.deductions,
    required this.employeeName,
    required this.employeeNumber,
    required this.status,
  });

  factory PayslipDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    final employee =
        json['employee'] ?? {};

    return PayslipDetail(
      periodLabel: _formatMonth(
        json['date_to'],
      ),
      totalNetSalary:
          _formatCurrency(
        json['net'],
      ),
      employeeName:
          employee['full_name'] ?? '-',
      employeeNumber:
          employee['employee_number'] ?? '-',
      status:
          json['status'] ?? '-',
      earnings: [
        PayslipLineItem(
          label: 'Basic Salary',
          value: _formatCurrency(
            json['salary'],
          ),
        ),
        PayslipLineItem(
          label: 'Allowance',
          value: _formatCurrency(
            json['allowance_amount'],
          ),
        ),
      ],
      deductions: [
        PayslipLineItem(
          label: 'Deductions',
          value: _formatCurrency(
            json['deductions'],
          ),
        ),
      ],
    );
  }
}

class PayslipLineItem {
  final String label;
  final String value;

  const PayslipLineItem({
    required this.label,
    required this.value,
  });
}

List<PayslipItem> parsePayslipItems(
  dynamic response,
) {
  if (response
      is Map<String, dynamic>) {
    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (e) =>
                PayslipItem.fromJson(
              e,
            ),
          )
          .toList();
    }
  }

  return [];
}

String _formatCurrency(
  dynamic value,
) {
  final number =
      (value ?? 0).toDouble();

  return 'Rp ${number.toStringAsFixed(0)}';
}

String _formatMonth(
  dynamic date,
) {
  if (date == null) {
    return 'Payslip';
  }

  final parsedDate =
      DateTime.parse(
    date.toString(),
  );

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[parsedDate.month - 1]} ${parsedDate.year}';
}