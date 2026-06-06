# Demo Guide - Mobile Testing

## Goal

Show that the Flutter mobile app works correctly on Android through real UI automation.

## Demo Steps

1. Open `flutter_app/lib/widgets/date_input_card.dart`.
2. Point out the input fields: Day, Month, Year.
3. Open `Mobile_testing/mobile-test-cases.md`.
4. Explain the selected tool: Maestro, free and open-source.
5. Open `date_time_checker_flow.yaml`.
6. Explain that the flow launches the app, enters dates, taps buttons, and verifies visible results.
7. Start an Android emulator or connect a phone.
8. Run:

```powershell
.\Mobile_testing\run-mobile-testing.bat
```

9. Open the generated report:

```text
reports\mobile-testing-report.txt
```

## Expected Result

```text
All Flutter tests passed.
APK build completed.
APK install completed.
Maestro mobile testing passed.
```

## Conclusion Script

> Mobile testing verified the Flutter UI on Android from the user's point of view. The test did not only check service logic; it launched the app, entered data, tapped controls, and asserted the visible result.
