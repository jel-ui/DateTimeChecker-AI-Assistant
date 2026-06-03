# Báo cáo dự án Date Time Checker

## 1. Giới thiệu

Date Time Checker là ứng dụng dùng để kiểm tra tính hợp lệ của dữ liệu ngày, tháng, năm do người dùng nhập vào. Dự án được xây dựng dựa trên yêu cầu trong tài liệu `ProjectIntroduction.docx`, trong đó hệ thống cần cho phép người dùng nhập `Day`, `Month`, `Year`, sau đó kiểm tra dữ liệu có phải là một ngày hợp lệ theo lịch Gregorian hay không.

Trong phiên bản hiện tại, nhóm triển khai ứng dụng dưới dạng web application bằng Java thay vì ứng dụng desktop C# như yêu cầu gốc. Bên cạnh chức năng kiểm tra ngày tháng năm, dự án còn tích hợp AI Assistant và Selenium WebDriver để hỗ trợ sinh test case, tạo test data và chạy kiểm thử tự động trên giao diện thật.

Tên dự án trong source code là `DateTimeChecker-AI-Assistant`. Tuy nhiên, theo điều chỉnh mới nhất, chương trình chỉ tập trung kiểm tra ngày, tháng, năm, không còn kiểm tra giờ, phút, giây.

## 2. Mục tiêu dự án

Mục tiêu chính của dự án gồm:

- Xây dựng ứng dụng kiểm tra ngày tháng năm hợp lệ.
- Kiểm tra các trường hợp ngày không tồn tại, tháng không hợp lệ, năm nhuận và năm không nhuận.
- Cung cấp giao diện dễ sử dụng, có thể chạy trực tiếp trên trình duyệt.
- Tự động hóa kiểm thử bằng Selenium WebDriver.
- Tích hợp AI Assistant để sinh test case và test data theo yêu cầu tự nhiên của người dùng.
- Hỗ trợ demo quy trình AI-assisted testing trong môn SWT301.

## 3. Cơ sở yêu cầu từ đề bài

Theo tài liệu yêu cầu `ProjectIntroduction.docx`, ứng dụng Date Time Checker cần có các chức năng chính:

- Giao diện nhập dữ liệu gồm ba trường:
  - Day
  - Month
  - Year
- Nút `Clear` để xóa dữ liệu đã nhập.
- Nút `Check` để kiểm tra ngày tháng năm.
- Kiểm tra dữ liệu nhập vào phải là số nguyên.
- Kiểm tra range:
  - Day nằm trong khoảng `1-31`.
  - Month nằm trong khoảng `1-12`.
  - Year theo đề gốc nằm trong khoảng `1000-3000`.
- Kiểm tra ngày có tồn tại trong tháng hay không.
- Kiểm tra năm nhuận theo lịch Gregorian.
- Hiển thị kết quả hợp lệ hoặc không hợp lệ.
- Ứng dụng phải chạy ổn định, không bị crash.
- Kết quả kiểm tra phải xuất hiện nhanh sau khi người dùng bấm nút kiểm tra.

Trong bản triển khai hiện tại, range của năm được mở rộng thành `1-9999` để phù hợp với thư viện `java.time` và các test case phổ biến như năm 1900, 2000, 2024, 2026.

## 4. Phạm vi chức năng của ứng dụng

### 4.1. Nhập ngày tháng năm

Người dùng nhập ba giá trị:

| Trường | Ý nghĩa | Điều kiện hợp lệ |
|---|---|---|
| Day | Ngày | Số nguyên từ 1 đến 31 |
| Month | Tháng | Số nguyên từ 1 đến 12 |
| Year | Năm | Số nguyên từ 1 đến 9999 |

Nếu một trường bị bỏ trống, nhập chữ, nhập số thập phân hoặc giá trị ngoài khoảng cho phép, hệ thống sẽ trả về kết quả không hợp lệ.

### 4.2. Kiểm tra ngày tồn tại trong tháng

Sau khi các trường có format đúng, hệ thống tiếp tục kiểm tra ngày có thật sự tồn tại trong tháng tương ứng hay không.

Ví dụ:

| Input | Kết quả | Lý do |
|---|---|---|
| 31/04/2026 | Không hợp lệ | Tháng 4 chỉ có 30 ngày |
| 30/04/2026 | Hợp lệ | Tháng 4 có ngày 30 |
| 31/12/2023 | Hợp lệ | Tháng 12 có 31 ngày |

### 4.3. Kiểm tra năm nhuận

Ứng dụng sử dụng quy tắc năm nhuận của lịch Gregorian:

- Năm chia hết cho 4 là năm nhuận.
- Nếu năm chia hết cho 100 thì chưa chắc là năm nhuận.
- Năm chia hết cho 100 chỉ là năm nhuận nếu cũng chia hết cho 400.

Ví dụ:

| Năm | Kết quả |
|---|---|
| 2024 | Năm nhuận |
| 2025 | Không nhuận |
| 2000 | Năm nhuận |
| 1900 | Không nhuận |

Do đó:

| Input | Kết quả |
|---|---|
| 29/02/2024 | Hợp lệ |
| 29/02/2025 | Không hợp lệ |
| 29/02/2000 | Hợp lệ |
| 29/02/1900 | Không hợp lệ |

### 4.4. Xóa dữ liệu

Nút `Xóa dữ liệu` cho phép người dùng reset form nhập liệu và đưa khu vực kết quả về trạng thái ban đầu.

### 4.5. Dùng ngày hôm nay

Ứng dụng có nút `Dùng hôm nay`. Khi người dùng bấm nút này, hệ thống tự động điền ngày, tháng, năm hiện tại vào form và kiểm tra tính hợp lệ.

## 5. Thiết kế và công nghệ sử dụng

### 5.1. Kiến trúc tổng quan

Dự án được triển khai theo mô hình web application đơn giản:

```text
Người dùng / Selenium
        |
        v
Giao diện HTML/CSS/JavaScript
        |
        v
HTTP API /api/datetime/check
        |
        v
DateTimeValidationService.java
        |
        v
Kết quả JSON: valid / invalid, errors, details
```

### 5.2. Backend

Backend được viết bằng Java, sử dụng HTTP server có sẵn trong JDK.

Các file chính:

| File | Vai trò |
|---|---|
| `App.java` | Khởi động HTTP server, phục vụ static files và API |
| `DateTimeValidationService.java` | Xử lý logic kiểm tra ngày tháng năm |

Endpoint chính:

```text
POST /api/datetime/check
```

Payload mẫu:

```json
{
  "day": "29",
  "month": "2",
  "year": "2024"
}
```

Response mẫu khi hợp lệ:

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
    "display": "29/02/2024",
    "weekday": "Thứ năm",
    "leapYear": "Có",
    "monthDays": "29"
  }
}
```

### 5.3. Frontend

Frontend được viết bằng HTML, CSS và JavaScript thuần.

Các file chính:

| File | Vai trò |
|---|---|
| `index.html` | Giao diện nhập ngày tháng năm |
| `app.js` | Gửi request API, render kết quả, lưu lịch sử kiểm tra |
| `styles.css` | Thiết kế giao diện responsive |
| `manifest.webmanifest` | Cấu hình Progressive Web App |

Giao diện hiện tại hỗ trợ:

- Nhập ngày, tháng, năm.
- Bấm kiểm tra.
- Xóa dữ liệu.
- Dùng ngày hôm nay.
- Hiển thị kết quả hợp lệ hoặc không hợp lệ.
- Hiển thị chi tiết:
  - Thứ trong tuần.
  - Năm nhuận.
  - Số ngày trong tháng.
- Lưu lịch sử kiểm tra gần đây.

## 6. Logic kiểm tra ngày tháng năm

Quy trình kiểm tra có thể mô tả như sau:

```text
Bắt đầu
  |
  v
Đọc day, month, year
  |
  v
Kiểm tra có phải số nguyên không?
  |
  +-- Không --> Invalid
  |
  v
Kiểm tra range day/month/year
  |
  +-- Sai range --> Invalid
  |
  v
Tính số ngày tối đa của tháng
  |
  v
Day có vượt quá số ngày của tháng không?
  |
  +-- Có --> Invalid
  |
  v
Tạo LocalDate thành công
  |
  v
Valid
```

Ứng dụng dùng `java.time.LocalDate`, `java.time.Month` và `java.time.Year.isLeap(year)` để bảo đảm kết quả tương thích với lịch Gregorian.

## 7. Tích hợp AI Assistant

Một điểm mở rộng quan trọng của dự án là tích hợp AI Assistant để hỗ trợ kiểm thử.

AI Assistant có các vai trò:

- Nhận yêu cầu tự nhiên bằng tiếng Việt từ người dùng.
- Phân tích yêu cầu kiểm thử.
- Sinh danh sách test case.
- Tạo test data gồm `day`, `month`, `year`, `expectedValid`, `reason`.
- Xuất dữ liệu test thành file JSON và TSV.
- Chuyển dữ liệu sang Selenium để chạy kiểm thử tự động.

Ví dụ người dùng có thể nhập:

```text
tạo ra data để test chương trình datetimechecker
```

AI sẽ sinh danh sách test case như:

| ID | Nội dung | Expected |
|---|---|---|
| CHAT01 | Normal valid date | Valid |
| CHAT02 | Leap day valid | Valid |
| CHAT03 | Non-leap day invalid | Invalid |
| CHAT04 | Century leap year | Valid |
| CHAT05 | Century non-leap | Invalid |
| CHAT06 | Month boundary | Invalid |
| CHAT07 | Month upper boundary | Invalid |
| CHAT08 | Blank input | Invalid |
| CHAT09 | Day lower boundary | Invalid |
| CHAT10 | Month format invalid | Invalid |

Nếu Gemini API bị quá tải hoặc tạm thời không khả dụng, chương trình không bị dừng ngay mà fallback sang bộ 10 test case offline mẫu để vẫn có thể tiếp tục demo.

## 8. Tự động hóa kiểm thử bằng Selenium

Selenium WebDriver được dùng để chạy test trực tiếp trên trình duyệt Microsoft Edge.

Quy trình chạy mỗi test case:

```text
Đọc test case từ TSV
  |
  v
Mở ứng dụng Date Time Checker
  |
  v
Nhập day, month, year vào form
  |
  v
Bấm nút kiểm tra
  |
  v
Đọc kết quả hiển thị trên UI
  |
  v
So sánh actual result với expected result
  |
  v
Hiển thị PASS/FAIL
```

Trong bản demo hiện tại, Selenium đã được chỉnh để:

- Nhập từng trường chậm hơn để người xem dễ quan sát.
- In quá trình nhập dữ liệu ra CMD.
- Hiển thị popup kết quả ở giữa màn hình sau khi submit.
- Popup chỉ hiện sau khi có kết quả, không che quá trình nhập dữ liệu.
- Popup tự tắt sau 2 giây rồi mới chạy test case tiếp theo.
- Popup hiển thị:
  - PASS hoặc FAIL.
  - Input đã nhập.
  - Expected result.
  - Actual result.

Ví dụ log trên CMD:

```text
AI02 RUNNING - Leap day valid - 2024 is a leap year.
  Input day = 29
  Input month = 2
  Input year = 2024
  Action: submit form
  Original testcase input: 29/2/2024
  Form input: 29/2/2024
  Expected result: Ngày hợp lệ
  Actual result: Ngày hợp lệ
AI02 PASS
```

## 9. Bộ test case tiêu biểu

| Test ID | Input | Expected Result | Mục đích |
|---|---|---|---|
| TC01 | 30/05/2026 | Ngày hợp lệ | Ngày bình thường hợp lệ |
| TC02 | 29/02/2024 | Ngày hợp lệ | Kiểm tra năm nhuận |
| TC03 | 29/02/2025 | Ngày không hợp lệ | Kiểm tra năm không nhuận |
| TC04 | 29/02/2000 | Ngày hợp lệ | Kiểm tra năm thế kỷ chia hết cho 400 |
| TC05 | 29/02/1900 | Ngày không hợp lệ | Kiểm tra năm thế kỷ không chia hết cho 400 |
| TC06 | 31/04/2026 | Ngày không hợp lệ | Tháng 4 chỉ có 30 ngày |
| TC07 | 30/13/2026 | Ngày không hợp lệ | Tháng vượt range |
| TC08 | /05/2026 | Ngày không hợp lệ | Bỏ trống ngày |
| TC09 | 0/05/2026 | Ngày không hợp lệ | Ngày dưới range |
| TC10 | 30/5.5/2026 | Ngày không hợp lệ | Tháng sai format |

## 10. Kết quả kiểm thử

Dự án có hai nhóm kiểm thử chính:

### 10.1. Unit test Java

File:

```text
src/test/java/com/datetimechecker/DateTimeValidationServiceTest.java
```

Các test chính:

- Chấp nhận ngày hợp lệ.
- Từ chối ngày không tồn tại trong tháng.
- Chấp nhận 29/02 ở năm nhuận.
- Từ chối 29/02 ở năm không nhuận.
- Từ chối input rỗng hoặc sai format.
- Kiểm tra quy tắc năm thế kỷ.

Kết quả hiện tại:

```text
All 7 Java tests passed.
```

### 10.2. Selenium UI test

Selenium chạy test trên giao diện thật của ứng dụng.

Kết quả demo với bộ 10 test case offline:

```text
AI-generated Selenium results: 10 passed, 0 failed.
```

Điều này cho thấy:

- Backend validate đúng.
- UI gửi dữ liệu đúng.
- Selenium đọc và so sánh kết quả đúng.
- Luồng AI-generated test data có thể chuyển sang Selenium để chạy tự động.

## 11. Điểm khác biệt so với yêu cầu gốc

| Nội dung | Yêu cầu gốc | Bản triển khai hiện tại |
|---|---|---|
| Nền tảng | C# Windows Forms | Java web application |
| Runtime | .NET Framework | JDK + browser |
| Giao diện | Desktop form | Responsive web UI |
| Input | Day, Month, Year | Day, Month, Year |
| Validate | Date time valid/invalid | Date valid/invalid |
| Kiểm thử | Manual test/test report | Java unit test + Selenium automation |
| AI | Không yêu cầu | Có AI Assistant sinh test case và test data |

Việc thay đổi nền tảng giúp ứng dụng dễ chạy demo trên trình duyệt, dễ tích hợp Selenium và phù hợp hơn với mục tiêu trình bày AI-assisted testing.

## 12. Lợi ích của AI-assisted testing trong dự án

Việc kết hợp AI và Selenium đem lại các lợi ích sau:

- Tạo test case nhanh hơn so với viết thủ công.
- Bao phủ nhiều nhóm dữ liệu hơn:
  - Valid date.
  - Invalid date.
  - Leap year.
  - Century leap year.
  - Empty input.
  - Wrong format.
  - Boundary value.
- Giúp tester giảm nguy cơ bỏ sót edge case.
- Selenium giúp chạy test lặp lại được, phù hợp cho regression testing.
- AI hỗ trợ giải thích lý do của từng test case.
- Khi có lỗi, log gồm input, expected và actual giúp phân tích nhanh hơn.

## 13. Hạn chế

Dù AI hỗ trợ tốt cho quá trình kiểm thử, dự án vẫn có một số hạn chế:

- AI có thể sinh test case chưa hoàn toàn đúng requirement, tester vẫn cần review.
- Nếu Gemini API quá tải, hệ thống phải dùng fallback offline sample.
- Selenium phụ thuộc vào trình duyệt và EdgeDriver.
- UI thay đổi có thể làm Selenium locator cần cập nhật.
- Project hiện tại tập trung kiểm tra ngày tháng năm, chưa xử lý giờ phút giây.
- Một số yêu cầu desktop trong đề gốc như message box `Close`, form không có maximize/minimize không còn áp dụng trực tiếp với bản web.

## 14. Hướng phát triển

Một số hướng phát triển tiếp theo:

- Cho phép export test report ra file Markdown hoặc HTML.
- Lưu screenshot khi test case fail.
- Thêm chế độ chọn số lượng test case AI cần sinh.
- Cho AI phân tích failure report và đề xuất nguyên nhân lỗi.
- Thêm kiểm thử accessibility cho giao diện.
- Thêm CI script để chạy unit test và Selenium test tự động.
- Nếu cần bám sát đề gốc hơn, có thể cấu hình lại range năm thành `1000-3000`.

## 15. Kết luận

Date Time Checker là một ứng dụng nhỏ nhưng có nhiều tình huống kiểm thử quan trọng liên quan đến ngày tháng năm, đặc biệt là năm nhuận, số ngày trong tháng, input rỗng và dữ liệu sai format.

Thông qua dự án này, nhóm không chỉ xây dựng chức năng kiểm tra ngày hợp lệ mà còn mở rộng thành một demo AI-assisted testing. AI được dùng để sinh test case và test data, còn Selenium chịu trách nhiệm thực thi test trên giao diện thật. Sự kết hợp này giúp quá trình kiểm thử nhanh hơn, trực quan hơn và dễ trình bày hơn trong bối cảnh môn học Software Testing.

Điểm quan trọng là AI không thay thế tester. AI đóng vai trò hỗ trợ thiết kế và phân tích test, trong khi tester vẫn cần review requirement, xác nhận expected result và quyết định cách xử lý lỗi.

