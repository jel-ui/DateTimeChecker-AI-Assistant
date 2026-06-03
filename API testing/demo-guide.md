# Demo Guide - API Testing

## Muc tieu demo

Chung minh API backend `POST /api/datetime/check` hoat dong dung theo `ProjectIntroduction.docx`.

## Cac buoc demo

1. Mo file `ProjectIntroduction.docx`.
2. Giai thich requirement ve input Day, Month, Year va performance trong 1 giay.
3. Mo file `src/main/java/com/datetimechecker/App.java`.
4. Chi ra endpoint:

```text
/api/datetime/check
```

5. Mo file `API testing/api-test-cases.md`.
6. Giai thich cac API test case.
7. Chay lenh:

```powershell
.\API testing\run-api-testing.bat
```

8. Mo report:

```text
reports\api-testing-report.tsv
```

## Ket qua mong doi

```text
All 10 API tests passed.
```

Tat ca response time can nho hon `1000 ms`.

## Cau noi ket luan

> API testing da verify HTTP status code, JSON response, ket qua valid/invalid va performance. Dieu nay chung minh backend API hoat dong dung, khong chi logic service rieng le.

