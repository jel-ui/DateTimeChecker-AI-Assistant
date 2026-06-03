# Bao Cao Unit Testing va API Testing

## 1. Thong tin chung

| Noi dung | Gia tri |
| --- | --- |
| Ten du an | Date Time Checker |
| Tai lieu yeu cau | ProjectIntroduction.docx |
| Topic 1 | Unit testing |
| Topic 2 | API testing |
| Ngon ngu trien khai | Java |
| Kieu ung dung | Web application chay bang JDK HTTP server |
| Ngay lap bao cao | 03/06/2026 |

## 2. Co so requirement

Theo file `ProjectIntroduction.docx`, ung dung Date Time Checker can kiem tra tinh hop le cua ngay, thang, nam do nguoi dung nhap vao.

Nhung requirement chinh duoc su dung de thiet ke test:

- Day phai la so nguyen trong khoang `1-31`.
- Month phai la so nguyen trong khoang `1-12`.
- Year phai la so nguyen trong khoang `1000-3000`.
- Neu input khong phai so nguyen thi phai tra ve ket qua khong hop le.
- Neu input ngoai range thi phai tra ve ket qua khong hop le.
- Neu ngay khong ton tai trong thang thi phai tra ve ket qua khong hop le.
- Ngay hop le phai tuan theo lich Gregorian.
- Ket qua kiem tra phai xuat hien trong vong 1 giay.
- Chuong trinh phai chay on dinh, khong crash khi nhan du lieu sai.

## 3. Pham vi Unit Testing

### 3.1. Muc tieu

Unit testing duoc dung de kiem tra truc tiep business logic trong class:

```text
src/main/java/com/datetimechecker/DateTimeValidationService.java
```

Muc tieu la dam bao ham validate xu ly dung cac quy tac ngay thang nam ma khong phu thuoc vao giao dien, HTTP server hay Selenium.

### 3.2. File test

```text
src/test/java/com/datetimechecker/DateTimeValidationServiceTest.java
```

Script chay:

```text
Unit testing/run-unit-testing.bat
```

### 3.3. Test cases

| ID | Nhom kiem thu | Input | Expected result |
| --- | --- | --- | --- |
| UT01 | Ngay hop le | `30/5/2026` | Valid |
| UT02 | Ngay vuot so ngay trong thang | `31/4/2026` | Invalid |
| UT03 | Nam nhuan | `29/2/2024` | Valid |
| UT04 | Nam khong nhuan | `29/2/2025` | Invalid |
| UT05 | Day ngoai range | `0/5/2026` | Invalid |
| UT06 | Month ngoai range | `30/13/2026` | Invalid |
| UT07 | Year ngoai range thap | `30/5/999` | Invalid |
| UT08 | Year ngoai range cao | `30/5/3001` | Invalid |
| UT09 | Input rong | blank day | Invalid |
| UT10 | Input sai format | `30/5.5/2026` | Invalid |
| UT11 | Dinh dang ngay hop le | `30/5/2026` | Display `30/05/2026` |
| UT12 | Nam the ky Gregorian | `29/2/2000`, `29/2/1900` | 2000 valid, 1900 invalid |

### 3.4. Ket qua Unit Testing

Ket qua chay test:

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

Ket luan: tat ca unit test deu PASS. Logic kiem tra ngay thang nam dap ung cac requirement chinh.

## 4. Pham vi API Testing

### 4.1. Muc tieu

API testing duoc dung de kiem tra endpoint HTTP:

```text
POST /api/datetime/check
```

Muc tieu la dam bao API nhan JSON request dung, tra JSON response dung, va thoi gian phan hoi khong vuot qua 1 giay.

### 4.2. File test

```text
API testing/run-api-testing.ps1
API testing/run-api-testing.bat
API testing/api-test-cases.md
```

Report ket qua:

```text
reports/api-testing-report.tsv
```

### 4.3. Request mau

```json
{
  "day": "29",
  "month": "2",
  "year": "2024"
}
```

### 4.4. Response mau

```json
{
  "valid": true,
  "errors": [],
  "parts": {
    "day": 29,
    "month": 2,
    "year": 2024
  },
  "details": {
    "display": "29/02/2024"
  }
}
```

### 4.5. Test cases

| ID | Input | Expected valid | Muc dich |
| --- | --- | --- | --- |
| API01 | `30/5/2026` | True | Ngay hop le |
| API02 | `31/4/2026` | False | Ngay khong ton tai trong thang |
| API03 | `29/2/2024` | True | Nam nhuan |
| API04 | `29/2/2025` | False | Nam khong nhuan |
| API05 | `0/5/2026` | False | Day nho hon 1 |
| API06 | `30/13/2026` | False | Month lon hon 12 |
| API07 | `30/5/999` | False | Year nho hon 1000 |
| API08 | `30/5/3001` | False | Year lon hon 3000 |
| API09 | `abc/5/2026` | False | Day khong phai so |
| API10 | `30/5.5/2026` | False | Month khong phai so nguyen |

### 4.6. Ket qua API Testing

Ket qua chay gan nhat:

| ID | Status | Input | Response time |
| --- | --- | --- | --- |
| API01 | PASS | `30/5/2026` | 15 ms |
| API02 | PASS | `31/4/2026` | 9 ms |
| API03 | PASS | `29/2/2024` | 9 ms |
| API04 | PASS | `29/2/2025` | 9 ms |
| API05 | PASS | `0/5/2026` | 8 ms |
| API06 | PASS | `30/13/2026` | 9 ms |
| API07 | PASS | `30/5/999` | 9 ms |
| API08 | PASS | `30/5/3001` | 9 ms |
| API09 | PASS | `abc/5/2026` | 9 ms |
| API10 | PASS | `30/5.5/2026` | 8 ms |

Tat ca API test deu PASS. Thoi gian phan hoi lon nhat la `15 ms`, nho hon requirement `1 second`.

## 5. So sanh Unit Testing va API Testing

| Tieu chi | Unit testing | API testing |
| --- | --- | --- |
| Muc tieu | Kiem tra logic core | Kiem tra HTTP endpoint |
| Doi tuong test | `DateTimeValidationService` | `POST /api/datetime/check` |
| Co can server khong | Khong | Co |
| Toc do | Rat nhanh | Nhanh |
| Phat hien loi | Loi business logic | Loi contract API, request/response, performance |
| Gia tri khi demo | Cho thay logic dung | Cho thay he thong chay duoc qua API thuc |

## 6. Ket luan

Hai phan testing bo sung da bao phu hai tang quan trong cua ung dung:

- Unit testing dam bao logic kiem tra ngay thang nam dung theo requirement.
- API testing dam bao endpoint backend hoat dong dung, tra response dung va dap ung performance trong 1 giay.

Ket qua hien tai:

- Unit testing: `All 7 Java tests passed`.
- API testing: `All 10 API tests passed`.

Voi ket qua tren, co the ket luan rang chuc nang Date Time Checker da duoc kiem thu o ca muc logic core va muc API.
