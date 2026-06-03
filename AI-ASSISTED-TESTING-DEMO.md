# AI-Assisted Testing and Self-Healing Demo

## Chat với AI Assistant

Nhấp đúp:

```text
ai-assistant-chat.bat
```

Trong lần đầu sử dụng, nhập Gemini API key khi được hỏi. Key được mã hóa bằng tài khoản Windows hiện tại và lưu cục bộ trong `.secrets/gemini-api-key.txt`. File này đã được loại trừ khỏi Git. Những lần mở `ai-assistant-chat.bat` sau không cần nhập lại key trên cùng tài khoản Windows.

Key chỉ được lưu sau khi Gemini xác nhận request đầu tiên thành công. Nếu nhập sai key, hết quota hoặc key bị chặn, cửa sổ chat sẽ hiển thị hướng dẫn xử lý cụ thể.

Để xóa key cũ và nhập key khác, nhấp đúp:

```text
reset-gemini-key.bat
```

Sau đó nhập yêu cầu tự nhiên ngay tại dòng `Bạn:`, ví dụ:

```text
Vui lòng giúp tôi testing cái project này để kiếm thử có sai gì không, nếu có vui lòng sửa lại.
```

Gemini sẽ hiểu ý định, trả lời bằng tiếng Việt, sinh testcase JSON động và chuyển dữ liệu sang Selenium WebDriver. Selenium mở Microsoft Edge, nhập dữ liệu trên giao diện thật và ghi failure report.

Để trình diễn quy trình AI phát hiện và đề xuất sửa controlled defect trong bản sao tạm, nhập:

```text
/demo-self-heal
```

Source production không bị thay đổi trong demo self-healing. Nhập `/help` để xem gợi ý hoặc `/exit` để đóng chat.

## Tập dượt không cần API key

Nhấp đúp:

```text
ai-assistant-chat-offline-sample.bat
```

Chế độ này dùng phản hồi AI mẫu để kiểm tra luồng trình diễn khi chưa có mạng hoặc chưa nhập Gemini API key. Khi trình bày AI thật, dùng `ai-assistant-chat.bat`.

## Demo self-healing trước lớp

Trong cửa sổ `ai-assistant-chat.bat`, nhập:

```text
/demo-self-heal
```

Chat sẽ:

1. Gọi Gemini API để sinh testcase JSON động.
2. Tạo một bản sao source tạm trong `out`.
3. Đưa một controlled defect vào bản sao tạm để minh họa.
4. Mở Microsoft Edge và chạy Selenium với dữ liệu AI vừa sinh.
5. Selenium phát hiện testcase FAIL và ghi failure report.
6. Gửi failure report cùng source lỗi cho AI phân tích.
7. Hiển thị diagnosis và file sửa do AI đề xuất.
8. Hỏi người trình bày có áp dụng fix vào bản sao tạm hay không.
9. Nếu xác nhận, build lại và chạy Selenium regression.
10. Giữ nguyên source production.

Sau khi chạy, bằng chứng demo nằm trong `reports`:

- `ai-generated-testcases.json`: dữ liệu test do AI sinh.
- `ai-selenium-failures-before-fix.tsv`: testcase thất bại trước khi sửa.
- `ai-fix-analysis.json`: diagnosis và fix do AI đề xuất.
- `ai-selenium-failures-after-fix.tsv`: regression report sau khi sửa.

### Demo Selenium automation riêng

Để chạy Selenium với testcase cố định mà không gọi AI, nhấp đúp:

```text
selenium-demo.bat
```

Microsoft Edge sẽ tự mở. Selenium WebDriver sẽ:

1. Bấm `Dùng hôm nay`.
2. Nhập ngày nhuận hợp lệ `29/02/2024`.
3. Nhập ngày không hợp lệ `29/02/2025`.
4. Kiểm tra biên tháng `31/04/2026`.
5. Kiểm tra biên tháng `30/13/2026`.
6. Hiển thị `PASS` sau từng testcase.
7. Dừng tại màn hình tổng kết cho đến khi nhấn Enter.

Nhấp đúp:

```text
run.bat
```

Trình duyệt sẽ tự mở tại:

```text
http://localhost:4173
```

Thử lần lượt:

| Input | Kết quả mong đợi |
|---|---|
| `29/02/2024` | Hợp lệ |
| `29/02/2025` | Không hợp lệ |
| `31/04/2026` | Không hợp lệ |
| Bấm `Dùng hôm nay` | Hợp lệ |

## Vai trò của AI và tester

| AI Assistant | Tester |
|---|---|
| Phân tích yêu cầu | Kiểm tra lại yêu cầu |
| Đề xuất testcase | Review testcase |
| Hỗ trợ viết test code | Chạy test thật |
| Phân tích lỗi | Xác minh và quyết định sửa lỗi |
