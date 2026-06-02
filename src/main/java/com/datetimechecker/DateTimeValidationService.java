package com.datetimechecker;

import java.time.DateTimeException;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

public final class DateTimeValidationService {
    private static final String[] WEEKDAYS = {
            "Thứ hai",
            "Thứ ba",
            "Thứ tư",
            "Thứ năm",
            "Thứ sáu",
            "Thứ bảy",
            "Chủ nhật"
    };

    public DateTimeCheckResult validate(DateTimeCheckRequest request) {
        List<String> errors = new ArrayList<String>();
        int day = parseInteger(request.day, "Ngày", errors);
        int month = parseInteger(request.month, "Tháng", errors);
        int year = parseInteger(request.year, "Năm", errors);
        int hour = parseInteger(request.hour, "Giờ", errors);
        int minute = parseInteger(request.minute, "Phút", errors);
        int second = parseInteger(request.second, "Giây", errors);

        if (!errors.isEmpty()) {
            return new DateTimeCheckResult(false, errors, null, null);
        }

        validateRange(year, 1, 9999, "Năm", errors);
        validateRange(month, 1, 12, "Tháng", errors);
        validateRange(day, 1, 31, "Ngày", errors);
        validateRange(hour, 0, 23, "Giờ", errors);
        validateRange(minute, 0, 59, "Phút", errors);
        validateRange(second, 0, 59, "Giây", errors);

        if (year >= 1 && year <= 9999 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            int maximum = Month.of(month).length(java.time.Year.isLeap(year));
            if (day > maximum) {
                errors.add(String.format(Locale.ROOT, "Tháng %d năm %d chỉ có %d ngày.", month, year, maximum));
            }
        }

        DateTimeParts parts = new DateTimeParts(day, month, year, hour, minute, second);
        if (!errors.isEmpty()) {
            return new DateTimeCheckResult(false, errors, parts, null);
        }

        LocalDateTime date = LocalDateTime.of(year, month, day, hour, minute, second);
        int offsetMinutes = clamp(request.timezoneOffsetMinutes == null ? 0 : request.timezoneOffsetMinutes, -14 * 60, 14 * 60);
        ZoneOffset offset = ZoneOffset.ofTotalSeconds(offsetMinutes * 60);
        DateTimeDetails details = new DateTimeDetails(
                String.format(Locale.ROOT, "%02d/%02d/%d %02d:%02d:%02d", day, month, year, hour, minute, second),
                WEEKDAYS[date.getDayOfWeek().getValue() - 1],
                java.time.Year.isLeap(year) ? "Có" : "Không",
                Integer.toString(Month.of(month).length(java.time.Year.isLeap(year))),
                hour < 12 ? "Buổi sáng" : hour < 18 ? "Buổi chiều" : "Buổi tối",
                formatOffset(offsetMinutes),
                Long.toString(date.toInstant(offset).toEpochMilli()));

        return new DateTimeCheckResult(true, errors, parts, details);
    }

    private static int parseInteger(String value, String label, List<String> errors) {
        if (value == null || value.trim().isEmpty()) {
            errors.add(label + " phải là số nguyên.");
            return 0;
        }

        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException exception) {
            errors.add(label + " phải là số nguyên.");
            return 0;
        }
    }

    private static void validateRange(int value, int minimum, int maximum, String label, List<String> errors) {
        if (value < minimum || value > maximum) {
            errors.add(String.format(Locale.ROOT, "%s phải nằm trong khoảng %d đến %d.", label, minimum, maximum));
        }
    }

    private static int clamp(int value, int minimum, int maximum) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    private static String formatOffset(int offsetMinutes) {
        String sign = offsetMinutes < 0 ? "-" : "+";
        int absolute = Math.abs(offsetMinutes);
        return String.format(Locale.ROOT, "UTC%s%02d:%02d", sign, absolute / 60, absolute % 60);
    }

    public static final class DateTimeCheckRequest {
        public final String day;
        public final String month;
        public final String year;
        public final String hour;
        public final String minute;
        public final String second;
        public final Integer timezoneOffsetMinutes;

        public DateTimeCheckRequest(
                String day,
                String month,
                String year,
                String hour,
                String minute,
                String second,
                Integer timezoneOffsetMinutes) {
            this.day = day;
            this.month = month;
            this.year = year;
            this.hour = hour;
            this.minute = minute;
            this.second = second;
            this.timezoneOffsetMinutes = timezoneOffsetMinutes;
        }
    }

    public static final class DateTimeParts {
        public final int day;
        public final int month;
        public final int year;
        public final int hour;
        public final int minute;
        public final int second;

        DateTimeParts(int day, int month, int year, int hour, int minute, int second) {
            this.day = day;
            this.month = month;
            this.year = year;
            this.hour = hour;
            this.minute = minute;
            this.second = second;
        }

        String toJson() {
            return String.format(
                    Locale.ROOT,
                    "{\"day\":%d,\"month\":%d,\"year\":%d,\"hour\":%d,\"minute\":%d,\"second\":%d}",
                    day, month, year, hour, minute, second);
        }
    }

    public static final class DateTimeDetails {
        public final String display;
        public final String weekday;
        public final String leapYear;
        public final String monthDays;
        public final String period;
        public final String offset;
        public final String timestamp;

        DateTimeDetails(
                String display,
                String weekday,
                String leapYear,
                String monthDays,
                String period,
                String offset,
                String timestamp) {
            this.display = display;
            this.weekday = weekday;
            this.leapYear = leapYear;
            this.monthDays = monthDays;
            this.period = period;
            this.offset = offset;
            this.timestamp = timestamp;
        }

        String toJson() {
            return "{"
                    + "\"display\":" + Json.quote(display) + ","
                    + "\"weekday\":" + Json.quote(weekday) + ","
                    + "\"leapYear\":" + Json.quote(leapYear) + ","
                    + "\"monthDays\":" + Json.quote(monthDays) + ","
                    + "\"period\":" + Json.quote(period) + ","
                    + "\"offset\":" + Json.quote(offset) + ","
                    + "\"timestamp\":" + Json.quote(timestamp)
                    + "}";
        }
    }

    public static final class DateTimeCheckResult {
        public final boolean valid;
        public final List<String> errors;
        public final DateTimeParts parts;
        public final DateTimeDetails details;

        DateTimeCheckResult(boolean valid, List<String> errors, DateTimeParts parts, DateTimeDetails details) {
            this.valid = valid;
            this.errors = Collections.unmodifiableList(new ArrayList<String>(errors));
            this.parts = parts;
            this.details = details;
        }

        public String toJson() {
            StringBuilder builder = new StringBuilder();
            builder.append("{\"valid\":").append(valid).append(",\"errors\":[");
            for (int index = 0; index < errors.size(); index++) {
                if (index > 0) builder.append(",");
                builder.append(Json.quote(errors.get(index)));
            }
            builder.append("],\"parts\":").append(parts == null ? "null" : parts.toJson());
            builder.append(",\"details\":").append(details == null ? "null" : details.toJson());
            return builder.append("}").toString();
        }
    }

    private static final class Json {
        private Json() {
        }

        static String quote(String value) {
            return "\"" + value
                    .replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t") + "\"";
        }
    }
}
