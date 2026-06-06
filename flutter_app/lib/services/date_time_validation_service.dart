/// Port 1:1 of Java DateTimeValidationService.
/// All validation logic & Vietnamese messages match the original.
class DateTimeValidationService {
  static const List<String> _weekdays = [
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy',
    'Chủ nhật',
  ];

  DateTimeCheckResult validate(DateTimeCheckRequest request) {
    final errors = <String>[];
    final day = _parseInt(request.day, 'Ngày', errors);
    final month = _parseInt(request.month, 'Tháng', errors);
    final year = _parseInt(request.year, 'Năm', errors);

    if (errors.isNotEmpty) {
      return DateTimeCheckResult(
        valid: false,
        errors: List.unmodifiable(errors),
      );
    }

    _validateRange(year, 1, 9999, 'Năm', errors);
    _validateRange(month, 1, 12, 'Tháng', errors);
    _validateRange(day, 1, 31, 'Ngày', errors);

    if (year >= 1 && year <= 9999 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
      final maximum = _daysInMonth(month, year);
      if (day > maximum) {
        errors.add('Tháng $month năm $year chỉ có $maximum ngày.');
      }
    }

    final parts = DateTimeParts(day: day, month: month, year: year);
    if (errors.isNotEmpty) {
      return DateTimeCheckResult(
        valid: false,
        errors: List.unmodifiable(errors),
        parts: parts,
      );
    }

    final date = DateTime(year, month, day);
    // DateTime weekday: 1=Monday … 7=Sunday  →  index 0–6
    final weekdayName = _weekdays[date.weekday - 1];
    final isLeap = _isLeapYear(year);
    final monthDays = _daysInMonth(month, year);

    final display =
        '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

    final details = DateTimeDetails(
      display: display,
      weekday: weekdayName,
      leapYear: isLeap ? 'Có' : 'Không',
      monthDays: monthDays.toString(),
    );

    return DateTimeCheckResult(
      valid: true,
      errors: const [],
      parts: parts,
      details: details,
    );
  }

  // ── helpers ──

  static int _parseInt(String? value, String label, List<String> errors) {
    if (value == null || value.trim().isEmpty) {
      errors.add('$label phải là số nguyên.');
      return 0;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      errors.add('$label phải là số nguyên.');
      return 0;
    }
    return parsed;
  }

  static void _validateRange(
      int value, int min, int max, String label, List<String> errors) {
    if (value < min || value > max) {
      errors.add('$label phải nằm trong khoảng $min đến $max.');
    }
  }

  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static int _daysInMonth(int month, int year) {
    const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) return 29;
    return days[month];
  }
}

// ── Data classes ──

class DateTimeCheckRequest {
  final String? day;
  final String? month;
  final String? year;

  const DateTimeCheckRequest({this.day, this.month, this.year});
}

class DateTimeParts {
  final int day;
  final int month;
  final int year;

  const DateTimeParts({
    required this.day,
    required this.month,
    required this.year,
  });

  String get display =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  Map<String, dynamic> toJson() => {'day': day, 'month': month, 'year': year};

  factory DateTimeParts.fromJson(Map<String, dynamic> json) => DateTimeParts(
        day: json['day'] as int,
        month: json['month'] as int,
        year: json['year'] as int,
      );
}

class DateTimeDetails {
  final String display;
  final String weekday;
  final String leapYear;
  final String monthDays;

  const DateTimeDetails({
    required this.display,
    required this.weekday,
    required this.leapYear,
    required this.monthDays,
  });
}

class DateTimeCheckResult {
  final bool valid;
  final List<String> errors;
  final DateTimeParts? parts;
  final DateTimeDetails? details;

  const DateTimeCheckResult({
    required this.valid,
    required this.errors,
    this.parts,
    this.details,
  });
}
