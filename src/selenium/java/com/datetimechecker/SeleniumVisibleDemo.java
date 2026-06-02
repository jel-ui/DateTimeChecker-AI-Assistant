package com.datetimechecker;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class SeleniumVisibleDemo {
    private static final String APP_URL = "http://localhost:4173";
    private static final long STEP_DELAY_MS = 1400;

    private final WebDriver driver;
    private final WebDriverWait wait;
    private final JavascriptExecutor javascript;
    private final boolean autoClose;
    private final List<String> passedTests = new ArrayList<String>();

    private SeleniumVisibleDemo(boolean headless, boolean autoClose) {
        Logger.getLogger("org.openqa.selenium").setLevel(Level.SEVERE);
        EdgeOptions options = new EdgeOptions();
        options.addArguments("--start-maximized");
        options.addArguments("--disable-search-engine-choice-screen");
        if (headless) {
            options.addArguments("--headless=new");
            options.addArguments("--window-size=1440,1000");
        }

        this.driver = new EdgeDriver(options);
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(10));
        this.javascript = (JavascriptExecutor) driver;
        this.autoClose = autoClose;
    }

    public static void main(String[] args) {
        boolean headless = hasArgument(args, "--headless");
        boolean autoClose = hasArgument(args, "--auto-close");
        SeleniumVisibleDemo demo = null;

        try {
            demo = new SeleniumVisibleDemo(headless, autoClose);
            demo.run();
        } catch (RuntimeException exception) {
            System.err.println("SELENIUM DEMO FAILED: " + exception.getMessage());
            if (demo != null) {
                demo.showOverlay("FAILED", exception.getMessage(), "#be3f4b");
                demo.waitBeforeClosing();
            }
            System.exit(1);
        } finally {
            if (demo != null) {
                demo.driver.quit();
            }
        }
    }

    private void run() {
        System.out.println("Opening Edge with Selenium WebDriver...");
        driver.get(APP_URL);
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("dateTimeForm")));
        showOverlay("AI-ASSISTED SELENIUM TEST", "Edge is controlled automatically by Selenium WebDriver.", "#0f766e");
        pause();

        runCurrentTimeTest();
        runFormTest("TC02", "Leap year valid", "29", "2", "2024", "14", "20", "10", "Ngày giờ hợp lệ");
        runFormTest("TC03", "Non-leap year invalid", "29", "2", "2025", "14", "20", "10", "Ngày giờ không hợp lệ");
        runFormTest("TC04", "Month boundary invalid", "31", "4", "2026", "14", "20", "10", "Ngày giờ không hợp lệ");
        runFormTest("TC05", "Hour boundary invalid", "30", "5", "2026", "24", "20", "10", "Ngày giờ không hợp lệ");

        String summary = passedTests.size() + "/5 Selenium UI test cases passed."
                + "<br><br>" + String.join("<br>", passedTests);
        showOverlay("SELENIUM DEMO PASSED", summary, "#0f766e");
        System.out.println();
        System.out.println("All 5 Selenium UI test cases passed.");
        waitBeforeClosing();
    }

    private void runCurrentTimeTest() {
        String id = "TC01";
        String name = "Synchronize current time";
        announce(id, name, "Click the current-time button and validate the result.");
        driver.findElement(By.id("nowButton")).click();
        assertResult(id, name, "Ngày giờ hợp lệ");
    }

    private void runFormTest(
            String id,
            String name,
            String day,
            String month,
            String year,
            String hour,
            String minute,
            String second,
            String expectedTitle) {
        announce(id, name, day + "/" + month + "/" + year + " " + hour + ":" + minute + ":" + second);
        fill("day", day);
        fill("month", month);
        fill("year", year);
        fill("hour", hour);
        fill("minute", minute);
        fill("second", second);
        pause();
        driver.findElement(By.cssSelector("button[type='submit']")).click();
        assertResult(id, name, expectedTitle);
    }

    private void assertResult(String id, String name, String expectedTitle) {
        wait.until(ExpectedConditions.textToBe(By.id("resultTitle"), expectedTitle));
        String actualTitle = driver.findElement(By.id("resultTitle")).getText();
        if (!expectedTitle.equals(actualTitle)) {
            throw new IllegalStateException(id + " expected '" + expectedTitle + "' but received '" + actualTitle + "'.");
        }

        String passed = id + " PASS - " + name;
        passedTests.add(passed);
        showOverlay(passed, "Expected result: " + expectedTitle, "#0f766e");
        System.out.println(passed);
        pause();
    }

    private void fill(String id, String value) {
        WebElement field = driver.findElement(By.id(id));
        field.clear();
        field.sendKeys(value);
    }

    private void announce(String id, String name, String input) {
        showOverlay(id + " - " + name, "Selenium is executing:<br>" + input, "#d97706");
        System.out.println();
        System.out.println(id + " RUNNING - " + name + " - " + input);
        pause();
    }

    private void showOverlay(String title, String message, String color) {
        javascript.executeScript(
                "let panel=document.querySelector('#selenium-demo-panel');"
                        + "if(!panel){panel=document.createElement('aside');panel.id='selenium-demo-panel';"
                        + "document.body.append(panel);}"
                        + "panel.style.cssText='position:fixed;right:18px;bottom:18px;z-index:99999;"
                        + "max-width:390px;padding:18px 20px;border-radius:16px;color:white;"
                        + "font:600 14px/1.55 Segoe UI,Arial,sans-serif;box-shadow:0 15px 45px rgba(0,0,0,.25);"
                        + "background:' + arguments[2] + ';';"
                        + "panel.innerHTML='<strong style=\"display:block;font-size:16px;margin-bottom:6px\">'"
                        + "+arguments[0]+'</strong><span>'+arguments[1]+'</span>';",
                title,
                message,
                color);
    }

    private void waitBeforeClosing() {
        if (autoClose) return;
        System.out.println();
        System.out.println("Press ENTER to close the Selenium browser.");
        new Scanner(System.in).nextLine();
    }

    private static boolean hasArgument(String[] args, String expected) {
        for (String argument : args) {
            if (expected.equals(argument)) return true;
        }
        return false;
    }

    private static void pause() {
        try {
            Thread.sleep(STEP_DELAY_MS);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("The Selenium demo was interrupted.", exception);
        }
    }
}
