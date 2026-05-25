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

  factory PayslipItem.fromJson(Map<String, dynamic> json) {
    final detail = PayslipDetail.fromJson(json);

    return PayslipItem(
      id: _stringValue(json, const [
            'id',
            '_id',
            'payslip_id',
            'payroll_id',
          ]) ??
          detail.periodLabel ??
          detail.totalNetSalary,
      monthLabel:
          _monthLabel(json) ?? detail.periodLabel ?? 'Payslip',
      netPay: _moneyValue(json, const [
            'net_pay',
            'netPay',
            'net_salary',
            'netSalary',
            'take_home_pay',
            'takeHomePay',
            'total_net_salary',
          ]) ??
          detail.totalNetSalary,
      detail: detail,
    );
  }
}

class PayslipDetail {
  final String? periodLabel;
  final String totalNetSalary;
  final List<PayslipLineItem> earnings;
  final List<PayslipLineItem> deductions;

  const PayslipDetail({
    required this.periodLabel,
    required this.totalNetSalary,
    required this.earnings,
    required this.deductions,
  });

  factory PayslipDetail.fromJson(Map<String, dynamic> json) {
    return PayslipDetail(
      periodLabel: _monthLabel(json) ?? _stringValue(json, const [
        'period',
        'pay_period',
        'salary_period',
        'month',
      ]),
      totalNetSalary: _moneyValue(json, const [
            'total_net_salary',
            'net_pay',
            'netPay',
            'net_salary',
            'netSalary',
            'take_home_pay',
            'takeHomePay',
          ]) ??
          '-',
      earnings: _lineItemsFromJson(json, const [
        'earnings',
        'income',
        'allowances',
        'salary_components',
        'salaryComponents',
      ]),
      deductions: _lineItemsFromJson(json, const [
        'deductions',
        'deduction',
        'withholdings',
        'cuts',
        'potongan',
      ]),
    );
  }
}

class PayslipLineItem {
  final String label;
  final String value;

  const PayslipLineItem({required this.label, required this.value});
}

List<PayslipItem> parsePayslipItems(dynamic response) {
  final candidates = <dynamic>[];

  if (response is List) {
    candidates.addAll(response);
  } else {
    final root = asMap(response);
    if (root != null) {
      for (final key in const ['data', 'payslips', 'items', 'records', 'result']) {
        final value = root[key];
        if (value is List) {
          candidates.addAll(value);
          break;
        }

        if (value is Map || value is Map<String, dynamic>) {
          candidates.add(value);
          break;
        }
      }

      if (candidates.isEmpty && root.isNotEmpty) {
        candidates.add(root);
      }
    }
  }

  return candidates
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map(PayslipItem.fromJson)
      .toList(growable: false);
}

List<PayslipLineItem> _lineItemsFromJson(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final rawValue = json[key];
    final items = _parseLineItems(rawValue);
    if (items.isNotEmpty) {
      return items;
    }
  }

  return const [];
}

List<PayslipLineItem> _parseLineItems(dynamic rawValue) {
  if (rawValue is List) {
    return rawValue
        .map((item) {
          final map = asMap(item);
          if (map != null) {
            final label = _stringValue(map, const [
                  'label',
                  'name',
                  'title',
                  'component',
                ]) ??
                'Item';
            final value = _moneyValue(map, const [
                  'value',
                  'amount',
                  'total',
                ]) ??
                _stringValue(map, const [
                  'value',
                  'amount',
                  'total',
                ]) ??
                '-';

            return PayslipLineItem(label: label, value: value);
          }

          if (item is String && item.trim().isNotEmpty) {
            return PayslipLineItem(label: item.trim(), value: '-');
          }

          return null;
        })
        .whereType<PayslipLineItem>()
        .toList(growable: false);
  }

  if (rawValue is Map) {
    final map = asMap(rawValue);
    if (map != null) {
      return map.entries
          .map((entry) {
            final label = _titleCase(entry.key.replaceAll('_', ' '));
            final value = _moneyString(entry.value) ?? '-';
            return PayslipLineItem(label: label, value: value);
          })
          .toList(growable: false);
    }
  }

  return const [];
}

String? _monthLabel(Map<String, dynamic> json) {
  final text = _stringValue(json, const [
    'month_label',
    'monthLabel',
    'payroll_month',
    'salary_month',
    'pay_period_label',
    'period_label',
  ]);
  if (text != null && text.isNotEmpty) {
    return text;
  }

  final dateValue = _stringValue(json, const [
    'month',
    'period',
    'pay_period',
    'salary_period',
    'created_at',
    'date',
    'issued_at',
  ]);
  return _formatMonth(dateValue);
}

String? _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
  }
  return null;
}

String? _moneyValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final formatted = _moneyString(json[key]);
    if (formatted != null) {
      return formatted;
    }
  }
  return null;
}

String? _moneyString(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return _formatCurrency(value.toDouble());
  }

  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(text.replaceAll(',', ''));
    if (parsed != null) {
      return _formatCurrency(parsed);
    }

    return text;
  }

  if (value is Map) {
    final map = asMap(value);
    if (map != null) {
      return _moneyValue(map, const [
        'value',
        'amount',
        'total',
        'price',
      ]);
    }
  }

  return value.toString();
}

String _formatCurrency(double value) {
  final isWholeNumber = value == value.roundToDouble();
  final digits = isWholeNumber ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  final parts = digits.split('.');
  final integerPart = parts.first;
  final decimalPart = parts.length > 1 ? parts[1] : null;
  final formattedInteger = integerPart.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );

  if (decimalPart == null || decimalPart == '00') {
    return 'Rp $formattedInteger';
  }

  return 'Rp $formattedInteger.$decimalPart';
}

String _formatMonth(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Payslip';
  }

  final parsedDate = DateTime.tryParse(value.trim());
  if (parsedDate == null) {
    return value.trim();
  }

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

String _titleCase(String value) {
  return value
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }

  return null;
}