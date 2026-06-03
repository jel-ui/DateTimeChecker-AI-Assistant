# Huong Dan Demo Unit Testing va API Testing

Tai lieu nay dung de demo 2 topic moi cho giang vien:

- Unit testing
- API testing

Du an can duoc mo tai thu muc:

```text
D:\DataFPTU\Semester5\SWT301\DateTimeChecker-AI-Assistant
```

## 1. Chuan bi truoc khi demo

### Buoc 1: Mo project

Mo thu muc project trong File Explorer hoac terminal:

```powershell
cd "D:\DataFPTU\Semester5\SWT301\DateTimeChecker-AI-Assistant"
```

### Buoc 2: Noi voi giang vien ve requirement

Gioi thieu ngan gon:

> Theo file ProjectIntroduction.docx, Date Time Checker can kiem tra Day, Month, Year. Day phai nam trong khoang 1-31, Month 1-12, Year 1000-3000. Chuong trinh phai kiem tra ngay hop le theo lich Gregorian, bao gom nam nhuan, thang co 30/31 ngay va ngay khong ton tai nhu 31/04 hoac 29/02 cua nam khong nhuan.

### Buoc 3: Noi ve 2 loai testing

Gioi thieu:

> Em da lam them 2 topic la Unit testing va API testing. Unit testing kiem tra truc tiep logic DateTimeValidationService. API testing kiem tra endpoint POST /api/datetime/check qua HTTP request va dong thoi do thoi gian phan hoi co nho hon 1 giay hay khong.

## 2. Demo Unit Testing

### File can mo cho giang vien xem

Mo cac file sau:

```text
Unit testing\README.md
Unit testing\unit-test-cases.md
src\test\java\com\datetimechecker\DateTimeValidationServiceTest.java
src\main\java\com\datetimechecker\DateTimeValidationService.java
```

### Noi dung trinh bay

Noi voi giang vien:

> Phan Unit testing khong chay qua giao dien va khong goi API. No test truc tiep service xu ly nghiep vu, nen neu logic validate date sai thi unit test se phat hien nhanh.

Chi vao file `DateTimeValidationServiceTest.java` va giai thich cac nhom test:

- Test ngay hop le: `30/5/2026`.
- Test ngay khong ton tai trong thang: `31/4/2026`.
- Test nam nhuan: `29/2/2024`.
- Test nam khong nhuan: `29/2/2025`.
- Test boundary range: day `0`, month `13`, year `999`, year `3001`.
- Test input sai format: rong, so thap phan.
- Test quy tac Gregorian voi nam `2000` va `1900`.

### Cach chay demo

Chay file:

```powershell
.\Unit testing\run-unit-testing.bat
```

Hoac chay bang terminal:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\test.ps1
```

### Ket qua can chi cho giang vien

Sau khi chay, man hinh se hien:

```text
PASS Accepts a valid date
PASS Rejects a day that does not exist in the selected month
PASS Accepts February 29 only in a leap year
PASS Rejects invalid date ranges
PASS Rejects blank and decimal values
PASS Describes a valid date
PASS Handles century leap-year rules

All 7 Java tests passed.
```

Noi ket luan:

> Tat ca unit test deu PASS, chung to logic validate ngay thang nam dang dung voi cac requirement chinh trong Product Introduction.

## 3. Demo API Testing

### File can mo cho giang vien xem

Mo cac file:

```text
API testing\README.md
API testing\api-test-cases.md
API testing\run-api-testing.ps1
src\main\java\com\datetimechecker\App.java
```

### Noi dung trinh bay

Noi voi giang vien:

> Phan API testing kiem tra endpoint POST /api/datetime/check. Khac voi unit testing, API testing chay qua HTTP layer, gui JSON request vao server va kiem tra JSON response tra ve.

Giai thich endpoint:

```text
POST /api/datetime/check
```

Body mau:

```json
{
  "day": "29",
  "month": "2",
  "year": "2024"
}
```

Response mong doi:

```json
{
  "valid": true,
  "errors": [],
  "parts": {
    "day": 29,
    "month": 2,
    "year": 2024
  }
}
```

### Cach chay demo

Chay file:

```powershell
.\API testing\run-api-testing.bat
```

Hoac chay bang terminal:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\API testing\run-api-testing.ps1"
```

### Ket qua can chi cho giang vien

Sau khi chay, man hinh se hien cac dong tuong tu:

```text
API01 PASS - Valid date - 30/5/2026
API02 PASS - Invalid day in month - 31/4/2026
API03 PASS - Leap year valid - 29/2/2024
API04 PASS - Non-leap year invalid - 29/2/2025
API05 PASS - Day below range - 0/5/2026
API06 PASS - Month above range - 30/13/2026
API07 PASS - Year below range - 30/5/999
API08 PASS - Year above range - 30/5/3001
API09 PASS - Day is not a number - abc/5/2026
API10 PASS - Month is decimal - 30/5.5/2026

All 10 API tests passed.
```

Sau do mo file report:

```text
reports\api-testing-report.tsv
```

Noi ket luan:

> API test da verify ca status code, actual valid/invalid va thoi gian phan hoi. Cac test deu PASS va thoi gian deu nho hon 1 giay, dung voi performance requirement.

## 4. Thu tu demo de de dat diem

Nen demo theo thu tu:

1. Mo `ProjectIntroduction.docx` va noi requirement chinh.
2. Mo `Unit testing\unit-test-cases.md` de cho thay test case duoc thiet ke theo requirement.
3. Chay `.\Unit testing\run-unit-testing.bat`.
4. Mo `API testing\api-test-cases.md` de cho thay API test case.
5. Chay `.\API testing\run-api-testing.bat`.
6. Mo `reports\api-testing-report.tsv`.
7. Mo `UNIT_API_TESTING_REPORT.md` de trinh bay bao cao tong hop.

## 5. Cau noi demo ngan gon

Ban co the noi:

> Em tach testing thanh 2 tang. Tang thu nhat la Unit testing, kiem tra truc tiep business logic de dam bao quy tac ngay thang nam dung. Tang thu hai la API testing, kiem tra endpoint ma frontend goi toi backend. Nhu vay neu co loi, em co the biet loi nam o logic core hay o layer API.

## 6. Neu gap loi khi demo

### Loi khong tim thay JDK

Neu hien:

```text
Khong tim thay JDK
```

Can cai JDK 8 tro len hoac cau hinh `JAVA_HOME`.

### Loi port dang duoc su dung

API script co co che tu chon port du phong `4174-4190`. Neu van loi, dong cac cua so `run.bat` cu roi chay lai.

### Loi PowerShell execution policy

Chay bang lenh co san:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\API testing\run-api-testing.ps1"
```

