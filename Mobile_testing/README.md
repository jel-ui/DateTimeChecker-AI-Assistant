# Mobile Testing - Flutter App

## Tool

This project uses Maestro for mobile UI testing.

Maestro is selected because it is free, open-source, and simple to use for Flutter Android UI flows.

## What is tested

- Flutter app launch.
- Valid date input.
- Invalid February 29 in a non-leap year.
- Valid February 29 in a leap year.
- Theme toggle smoke test.

## Prerequisites

1. Flutter installed.
2. Android emulator or Android device connected.
3. Maestro CLI installed.

Check Android device:

```powershell
adb devices
```

Install Maestro CLI on Windows:

```powershell
.\Mobile_testing\install-maestro-free.ps1
```

After installing, open a new terminal and check:

```powershell
maestro --version
```

## Run

```powershell
.\Mobile_testing\run-mobile-testing.bat
```

The script will:

1. Run Flutter tests.
2. Build debug APK.
3. Install APK on the connected Android emulator/device.
4. Run the Maestro flow.
5. Write output to `reports/mobile-testing-report.txt`.

## Run in Maestro Studio

Open the project root:

```text
D:\FPTU\SWT301\Labs\New folder\DateTimeChecker-AI-Assistant
```

Then run:

```text
date_time_checker_flow.yaml
```

This root-level flow is added so Maestro Studio can discover it from the workspace.

## Manual Maestro command

```powershell
maestro test ".\date_time_checker_flow.yaml"
```
