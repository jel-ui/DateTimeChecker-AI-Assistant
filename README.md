# DateTimeChecker AI Assistant

Ứng dụng Java responsive dùng để kiểm tra ngày giờ hợp lệ trên máy tính và điện thoại. Project tích hợp Gemini AI và Selenium WebDriver để minh họa AI-assisted testing: AI hiểu yêu cầu tự nhiên, sinh dữ liệu kiểm thử và chuyển dữ liệu sang trình duyệt để chạy test trực tiếp.

Project dùng HTTP server có sẵn trong JDK nên không cần tải Maven, Gradle hoặc thư viện ngoài.

## Tính năng chính

- Kiểm tra ngày, tháng, năm, giờ, phút và giây.
- Kiểm tra boundary value, số ngày theo tháng và quy tắc năm nhuận.
- Chạy web responsive trên máy tính và điện thoại trong cùng mạng Wi-Fi.
- Chat với Gemini AI bằng tiếng Việt để sinh testcase động.
- Dùng Selenium WebDriver để chạy testcase trên Microsoft Edge.
- Trình diễn self-healing trong bản sao tạm mà không sửa source production.

## Bắt đầu nhanh

Yêu cầu: JDK 8 trở lên.

```powershell
.\run.bat
```

Script sẽ tự mở `http://localhost:4173`.

- Giữ cửa sổ `run.bat` mở để server tiếp tục hoạt động.
- Khi server đang chạy, bạn có thể tự nhập `http://localhost:4173` trên trình duyệt.
- Nếu bấm `run.bat` thêm lần nữa, script chỉ mở lại trang web thay vì khởi động trùng server.

Để điện thoại truy cập trong cùng mạng Wi-Fi, mở port `4173` trên máy tính và truy cập:

```text
http://<IP-của-máy-tính>:4173
```

## Kiểm thử Java

```powershell
.\test.bat
```

Cửa sổ test sẽ giữ nguyên sau khi chạy xong. Nhấn phím bất kỳ khi bạn muốn đóng.

## Demo AI-assisted testing

```powershell
.\ai-assistant-chat.bat
```

Đây là demo chính để trình bày trước người chấm:

1. Trong lần đầu sử dụng, nhập Gemini API key lấy từ Google AI Studio khi được hỏi.
2. Nhập yêu cầu tự nhiên bằng tiếng Việt, ví dụ:

```text
Vui lòng giúp tôi testing cái project này để kiếm thử có sai gì không, nếu có vui lòng sửa lại.
```

3. AI trả lời, sinh testcase JSON động và chuyển dữ liệu sang Selenium.
4. Selenium mở Edge và chạy testcase trực tiếp trên giao diện.
5. Nhập `/demo-self-heal` trong chat để minh họa AI tìm lỗi, đề xuất sửa và chạy regression trong bản sao tạm.

API key được mã hóa bằng tài khoản Windows hiện tại và lưu cục bộ trong `.secrets/gemini-api-key.txt`. File `.secrets` đã được loại trừ khỏi Git. Những lần mở `ai-assistant-chat.bat` sau không cần nhập lại key trên cùng tài khoản Windows.

Để xóa key cũ và nhập key khác, nhấp đúp `reset-gemini-key.bat`. Source production không bị sửa trong self-healing demo.

Gemini API có free tier với giới hạn thấp hơn paid tier, phù hợp cho demo học tập. Tạo key tại [Google AI Studio](https://aistudio.google.com/app/apikey).

Xem hướng dẫn trình bày chi tiết tại [AI-ASSISTED-TESTING-DEMO.md](AI-ASSISTED-TESTING-DEMO.md).

## Tập dượt không cần API key

```powershell
.\ai-assistant-chat-offline-sample.bat
```

Chế độ này dùng phản hồi AI mẫu để tập dượt luồng chat và Selenium. Khi trình bày AI thật, dùng `ai-assistant-chat.bat`.

## Demo Selenium trực tiếp

```powershell
.\selenium-demo.bat
```

Microsoft Edge sẽ tự mở và hiển thị quá trình Selenium WebDriver thao tác từng testcase. Trình duyệt dừng ở màn hình tổng kết cho đến khi nhấn Enter.

Lần chạy Selenium đầu tiên cần kết nối mạng để Selenium Manager tải EdgeDriver tương thích. Selenium Manager là công cụ quản lý driver chính thức đi kèm Selenium.

Selenium demo cần JDK 17 trở lên. Ứng dụng chính vẫn tương thích JDK 8.

## Cấu trúc

- `src/main/java/com/datetimechecker/App.java`: HTTP server và API.
- `src/main/java/com/datetimechecker/DateTimeValidationService.java`: logic Java kiểm tra ngày giờ.
- `src/main/resources/static`: giao diện responsive và Progressive Web App.
- `src/test/java`: test runner Java không cần package ngoài.
- `scripts`: script tự tìm JDK, biên dịch, chạy ứng dụng và test.
- `tools`: Selenium server JAR dùng cho demo trình duyệt.
- `.secrets`: API key đã mã hóa cục bộ, tự tạo sau lần nhập đầu và không được đưa lên Git.
