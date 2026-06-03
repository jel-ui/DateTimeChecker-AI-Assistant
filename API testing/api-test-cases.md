# API Test Cases

| ID | Requirement | JSON body | Expected HTTP | Expected API result | Performance |
| --- | --- | --- | --- | --- | --- |
| API01 | Ngay hop le | `{"day":"30","month":"5","year":"2026"}` | 200 | `valid = true` | <= 1000 ms |
| API02 | Ngay khong ton tai trong thang | `{"day":"31","month":"4","year":"2026"}` | 200 | `valid = false` | <= 1000 ms |
| API03 | Nam nhuan | `{"day":"29","month":"2","year":"2024"}` | 200 | `valid = true` | <= 1000 ms |
| API04 | Nam khong nhuan | `{"day":"29","month":"2","year":"2025"}` | 200 | `valid = false` | <= 1000 ms |
| API05 | Day ngoai range | `{"day":"0","month":"5","year":"2026"}` | 200 | `valid = false` | <= 1000 ms |
| API06 | Month ngoai range | `{"day":"30","month":"13","year":"2026"}` | 200 | `valid = false` | <= 1000 ms |
| API07 | Year nho hon 1000 | `{"day":"30","month":"5","year":"999"}` | 200 | `valid = false` | <= 1000 ms |
| API08 | Year lon hon 3000 | `{"day":"30","month":"5","year":"3001"}` | 200 | `valid = false` | <= 1000 ms |
| API09 | Day khong phai so | `{"day":"abc","month":"5","year":"2026"}` | 200 | `valid = false` | <= 1000 ms |
| API10 | Month la so thap phan | `{"day":"30","month":"5.5","year":"2026"}` | 200 | `valid = false` | <= 1000 ms |

## Test level

API testing kiem tra qua HTTP endpoint nen nam giua unit testing va UI/E2E testing. Bo test nay xac nhan contract API truoc khi giao dien hoac Selenium su dung API.
