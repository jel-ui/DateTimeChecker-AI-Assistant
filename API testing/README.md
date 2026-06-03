# API Testing - Date Time Checker

## Muc tieu

Kiem thu API `POST /api/datetime/check` theo `ProjectIntroduction.docx`, tap trung vao validation input, ket qua valid/invalid va yeu cau performance phan hoi trong 1 giay.

## Endpoint

```text
POST http://localhost:<port>/api/datetime/check
Content-Type: application/json
```

Request body:

```json
{
  "day": "29",
  "month": "2",
  "year": "2024"
}
```

## Requirement duoc kiem thu

- Day la so nguyen trong khoang `1-31`.
- Month la so nguyen trong khoang `1-12`.
- Year la so nguyen trong khoang `1000-3000`.
- Ngay hop le/khong hop le theo lich Gregorian.
- Ket qua kiem tra xuat hien trong vong 1 giay.

## Cach chay

```powershell
.\API testing\run-api-testing.bat
```

Script se tu build project, tu mo server test o port trong, goi API, kiem tra response va ghi report vao:

```text
reports/api-testing-report.tsv
```
