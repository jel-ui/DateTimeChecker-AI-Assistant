# Demo Guide - Unit Testing

## Muc tieu demo

Chung minh logic validate ngay thang nam duoc kiem thu truc tiep theo `ProjectIntroduction.docx`.

## Cac buoc demo

1. Mo file `ProjectIntroduction.docx`.
2. Chi ra requirement:
   - Day: `1-31`
   - Month: `1-12`
   - Year: `1000-3000`
   - Kiem tra ngay hop le theo lich Gregorian.
3. Mo file `src/main/java/com/datetimechecker/DateTimeValidationService.java`.
4. Giai thich day la class xu ly logic validate.
5. Mo file `src/test/java/com/datetimechecker/DateTimeValidationServiceTest.java`.
6. Giai thich cac test case:
   - Valid date
   - Invalid day in month
   - Leap year
   - Non-leap year
   - Boundary value
   - Blank/decimal input
   - Gregorian century rule
7. Chay lenh:

```powershell
.\Unit testing\run-unit-testing.bat
```

## Ket qua mong doi

```text
All 7 Java tests passed.
```

## Cau noi ket luan

> Unit testing da verify truc tiep business logic. Neu logic validate date sai, test se fail ngay ma khong can chay UI hay API.

