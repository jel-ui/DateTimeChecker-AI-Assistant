package com.datetimechecker;

import com.datetimechecker.DateTimeValidationService.DateTimeCheckRequest;
import com.datetimechecker.DateTimeValidationService.DateTimeCheckResult;

import java.util.ArrayList;
import java.util.List;

public final class DateTimeValidationServiceTest {
    private static final DateTimeValidationService VALIDATOR = new DateTimeValidationService();
    private static final List<String> FAILURES = new ArrayList<String>();

    private DateTimeValidationServiceTest() {
    }

    public static void main(String[] args) {
        run("Accepts a valid date and time", new TestCase() {
            @Override
            public void execute() {
                assertTrue(validate().valid, "Expected a valid date.");
            }
        });

        run("Rejects a day that does not exist in the selected month", new TestCase() {
            @Override
            public void execute() {
                DateTimeCheckResult result = validate("31", "4", "2026", "14", "20", "10");
                assertTrue(!result.valid, "Expected April 31 to be invalid.");
                assertTrue(contains(result, "chỉ có 30 ngày"), "Expected a month length error.");
            }
        });

        run("Accepts February 29 only in a leap year", new TestCase() {
            @Override
            public void execute() {
                assertTrue(validate("29", "2", "2024", "14", "20", "10").valid, "Expected February 29, 2024 to be valid.");
                assertTrue(!validate("29", "2", "2025", "14", "20", "10").valid, "Expected February 29, 2025 to be invalid.");
            }
        });

        run("Rejects invalid time ranges", new TestCase() {
            @Override
            public void execute() {
                assertTrue(!validate("30", "5", "2026", "24", "20", "10").valid, "Expected hour 24 to be invalid.");
                assertTrue(!validate("30", "5", "2026", "14", "60", "10").valid, "Expected minute 60 to be invalid.");
                assertTrue(!validate("30", "5", "2026", "14", "20", "-1").valid, "Expected second -1 to be invalid.");
            }
        });

        run("Rejects blank and decimal values", new TestCase() {
            @Override
            public void execute() {
                assertTrue(!validate("", "5", "2026", "14", "20", "10").valid, "Expected a blank day to be invalid.");
                assertTrue(!validate("30", "5", "2026", "14", "3.5", "10").valid, "Expected a decimal minute to be invalid.");
            }
        });

        run("Describes a valid date", new TestCase() {
            @Override
            public void execute() {
                DateTimeCheckResult result = validate();
                assertEquals("30/05/2026 14:20:10", result.details.display, "Expected a formatted date.");
                assertEquals("Không", result.details.leapYear, "Expected 2026 not to be a leap year.");
                assertEquals("31", result.details.monthDays, "Expected May to have 31 days.");
                assertEquals("UTC+07:00", result.details.offset, "Expected the device timezone offset.");
            }
        });

        run("Handles century leap-year rules", new TestCase() {
            @Override
            public void execute() {
                assertTrue(validate("29", "2", "2000", "14", "20", "10").valid, "Expected year 2000 to be a leap year.");
                assertTrue(!validate("29", "2", "1900", "14", "20", "10").valid, "Expected year 1900 not to be a leap year.");
            }
        });

        System.out.println();
        if (FAILURES.isEmpty()) {
            System.out.println("All 7 Java tests passed.");
            return;
        }

        System.err.println(FAILURES.size() + " test(s) failed.");
        System.exit(1);
    }

    private static DateTimeCheckResult validate() {
        return validate("30", "5", "2026", "14", "20", "10");
    }

    private static DateTimeCheckResult validate(
            String day,
            String month,
            String year,
            String hour,
            String minute,
            String second) {
        return VALIDATOR.validate(new DateTimeCheckRequest(day, month, year, hour, minute, second, 7 * 60));
    }

    private static boolean contains(DateTimeCheckResult result, String text) {
        for (String error : result.errors) {
            if (error.contains(text)) return true;
        }
        return false;
    }

    private static void run(String name, TestCase test) {
        try {
            test.execute();
            System.out.println("PASS " + name);
        } catch (RuntimeException exception) {
            FAILURES.add(name);
            System.err.println("FAIL " + name + ": " + exception.getMessage());
        }
    }

    private static void assertTrue(boolean condition, String message) {
        if (!condition) throw new IllegalStateException(message);
    }

    private static void assertEquals(String expected, String actual, String message) {
        if (!expected.equals(actual)) {
            throw new IllegalStateException(message + " Expected: " + expected + ", actual: " + actual);
        }
    }

    private interface TestCase {
        void execute();
    }
}
