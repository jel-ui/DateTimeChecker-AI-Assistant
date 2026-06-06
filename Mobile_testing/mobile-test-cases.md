# Mobile Testing Test Cases - Flutter App

Tool selected: Maestro.

Reason:
- Free and open-source.
- Works well with Android emulator/device and Flutter UI.
- Test flow is short YAML, easy to demo.
- Uses visible text assertions for results and fixed tap points only for the three compact input fields.

## Scope

App under test:

```text
flutter_app
```

Android package:

```text
com.datetimechecker.date_time_checker
```

## Test Cases

| ID | Scenario | Steps | Expected result |
|---|---|---|---|
| MOB01 | App launches successfully | Launch app with clean state | Home screen shows Date Checker and initial waiting result |
| MOB02 | Valid date 30/05/2026 | Clear data, enter day `30`, month `5`, year `2026`, tap check | Result shows valid date, display `30/05/2026`, weekday `Thứ bảy`, and non-leap year |
| MOB03 | Invalid non-leap date 29/02/2025 | Clear data, enter day `29`, month `2`, year `2025`, tap check | Result shows invalid date and error `Tháng 2 năm 2025 chỉ có 28 ngày.` |
| MOB04 | Valid leap date 29/02/2024 | Clear data, enter day `29`, month `2`, year `2024`, tap check | Result shows valid date, display `29/02/2024`, and leap year `Có` |
| MOB05 | Theme toggle does not break result screen | Tap theme toggle after a valid result | Result remains visible |

## Files

- Maestro Studio flow: `date_time_checker_flow.yaml`
- Organized flow copy: `Mobile_testing/maestro/date_time_checker_flow.yaml`
- Runner script: `Mobile_testing/run-mobile-testing.ps1`
- Batch launcher: `Mobile_testing/run-mobile-testing.bat`
- Report path: `reports/mobile-testing-report.txt`
