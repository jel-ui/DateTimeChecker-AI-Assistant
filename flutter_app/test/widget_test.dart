import 'package:flutter_test/flutter_test.dart';
import 'package:date_time_checker/services/date_time_validation_service.dart';

void main() {
  group('DateTimeValidationService', () {
    final service = DateTimeValidationService();

    test('valid date returns valid result', () {
      final result = service.validate(
        const DateTimeCheckRequest(day: '15', month: '6', year: '2024'),
      );
      expect(result.valid, isTrue);
      expect(result.details, isNotNull);
      expect(result.details!.weekday, 'Thứ bảy');
      expect(result.details!.leapYear, 'Có');
    });

    test('leap year Feb 29 is valid', () {
      final result = service.validate(
        const DateTimeCheckRequest(day: '29', month: '2', year: '2024'),
      );
      expect(result.valid, isTrue);
    });

    test('non-leap year Feb 29 is invalid', () {
      final result = service.validate(
        const DateTimeCheckRequest(day: '29', month: '2', year: '2023'),
      );
      expect(result.valid, isFalse);
      expect(result.errors, isNotEmpty);
    });

    test('month 13 is invalid', () {
      final result = service.validate(
        const DateTimeCheckRequest(day: '1', month: '13', year: '2024'),
      );
      expect(result.valid, isFalse);
    });

    test('empty input returns error', () {
      final result = service.validate(
        const DateTimeCheckRequest(day: '', month: '', year: ''),
      );
      expect(result.valid, isFalse);
      expect(result.errors.length, 3);
    });

    test('non-numeric input returns error', () {
      final result = service.validate(
        const DateTimeCheckRequest(day: 'abc', month: '1', year: '2024'),
      );
      expect(result.valid, isFalse);
      expect(result.errors.first, contains('Ngày'));
    });
  });
}
