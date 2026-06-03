# Unit Testing - Date Time Checker

## Muc tieu

Kiem thu logic xu ly ngay thang nam cua `DateTimeValidationService` theo tai lieu `ProjectIntroduction.docx`.

## Requirement duoc kiem thu

- Day phai la so nguyen trong khoang `1-31`.
- Month phai la so nguyen trong khoang `1-12`.
- Year phai la so nguyen trong khoang `1000-3000`.
- Ngay phai hop le theo lich Gregorian.
- Thang 2 phai xu ly dung nam nhuan va nam khong nhuan.
- Ung dung phai chay on dinh, khong crash khi nhan du lieu sai.

## File lien quan

- Source can test: `src/main/java/com/datetimechecker/DateTimeValidationService.java`
- Unit test: `src/test/java/com/datetimechecker/DateTimeValidationServiceTest.java`
- Script chay test: `run-unit-testing.bat`

## Cach chay

```powershell
.\Unit testing\run-unit-testing.bat
```

Hoac chay truc tiep script goc:

```powershell
.\scripts\test.ps1
```

## Ket qua mong doi

Console hien thi toan bo test case `PASS` va dong tong ket:

```text
All 7 Java tests passed.
```
