# Unit Test Cases

| ID | Requirement | Input | Expected result |
| --- | --- | --- | --- |
| UT01 | Ngay hop le | `30/5/2026` | Valid |
| UT02 | Ngay vuot so ngay trong thang | `31/4/2026` | Invalid |
| UT03 | Nam nhuan hop le | `29/2/2024` | Valid |
| UT04 | Nam khong nhuan | `29/2/2025` | Invalid |
| UT05 | Day ngoai range | `0/5/2026` | Invalid |
| UT06 | Month ngoai range | `30/13/2026` | Invalid |
| UT07 | Year ngoai range thap | `30/5/999` | Invalid |
| UT08 | Year ngoai range cao | `30/5/3001` | Invalid |
| UT09 | Du lieu rong | blank day | Invalid |
| UT10 | Du lieu khong phai so nguyen | `30/5.5/2026` | Invalid |
| UT11 | Format ket qua ngay hop le | `30/5/2026` | Display `30/05/2026` |
| UT12 | Quy tac nam the ky | `29/2/2000`, `29/2/1900` | 2000 valid, 1900 invalid |

## Test level

Unit testing kiem tra truc tiep service xu ly nghiep vu, khong phu thuoc giao dien web, HTTP server hoac Selenium.
