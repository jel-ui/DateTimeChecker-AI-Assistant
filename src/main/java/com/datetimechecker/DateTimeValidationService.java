package com.datetimechecker;

import java.time.LocalDate;
import java.time.Month;
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

        if (!errors.isEmpty()) {
            return new DateTimeCheckResult(false, errors, null, null);
        }

        validateRange(year, 1000, 3000, "Năm", errors);
        validateRange(month, 1, 12, "Tháng", errors);
        validateRange(day, 1, 31, "Ngày", errors);

        if (year >= 1000 && year <= 3000 && month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            int maximum = Month.of(month).length(java.time.Year.isLeap(year));
            if (day > maximum) {
                errors.add(String.format(Locale.ROOT, "Tháng %d năm %d chỉ có %d ngày.", month, year, maximum));
            }
        }

        DateTimeParts parts = new DateTimeParts(day, month, year);
        if (!errors.isEmpty()) {
            return new DateTimeCheckResult(false, errors, parts, null);
        }

        LocalDate date = LocalDate.of(year, month, day);
        DateTimeDetails details = new DateTimeDetails(
                String.format(Locale.ROOT, "%02d/%02d/%d", day, month, year),
                WEEKDAYS[date.getDayOfWeek().getValue() - 1],
                java.time.Year.isLeap(year) ? "Có" : "Không",
                Integer.toString(Month.of(month).length(java.time.Year.isLeap(year))));

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

    public static final class DateTimeCheckRequest {
        public final String day;
        public final String month;
        public final String year;

        public DateTimeCheckRequest(
                String day,
                String month,
                String year) {
            this.day = day;
            this.month = month;
            this.year = year;
        }
    }

    public static final class DateTimeParts {
        public final int day;
        public final int month;
        public final int year;

        DateTimeParts(int day, int month, int year) {
            this.day = day;
            this.month = month;
            this.year = year;
        }

        String toJson() {
            return String.format(
                    Locale.ROOT,
                    "{\"day\":%d,\"month\":%d,\"year\":%d}",
                    day, month, year);
        }
    }

    public static final class DateTimeDetails {
        public final String display;
        public final String weekday;
        public final String leapYear;
        public final String monthDays;

        DateTimeDetails(
                String display,
                String weekday,
                String leapYear,
                String monthDays) {
            this.display = display;
            this.weekday = weekday;
            this.leapYear = leapYear;
            this.monthDays = monthDays;
        }

        String toJson() {
            return "{"
                    + "\"display\":" + Json.quote(display) + ","
                    + "\"weekday\":" + Json.quote(weekday) + ","
                    + "\"leapYear\":" + Json.quote(leapYear) + ","
                    + "\"monthDays\":" + Json.quote(monthDays)
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
