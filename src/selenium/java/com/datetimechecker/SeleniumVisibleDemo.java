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
    private static final String APP_URL = System.getProperty("datetimechecker.url", "http://localhost:4173");
    private static final long STEP_DELAY_MS = 1600;
    private static final long FIELD_DELAY_MS = 700;
    private static final long RESULT_DELAY_MS = 2000;

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
        System.out.println("Edge is controlled automatically by Selenium WebDriver.");

        runCurrentDateTest();
        runFormTest("TC02", "Leap year valid", "29", "2", "2024", "Ngày hợp lệ");
        runFormTest("TC03", "Non-leap year invalid", "29", "2", "2025", "Ngày không hợp lệ");
        runFormTest("TC04", "Month boundary invalid", "31", "4", "2026", "Ngày không hợp lệ");
        runFormTest("TC05", "Month range invalid", "30", "13", "2026", "Ngày không hợp lệ");

        String summary = passedTests.size() + "/5 Selenium UI test cases passed."
                + "<br><br>" + String.join("<br>", passedTests);
        showOverlay("SELENIUM DEMO PASSED", summary, "#0f766e");
        System.out.println();
        System.out.println("All 5 Selenium UI test cases passed.");
        waitBeforeClosing();
    }

    private void runCurrentDateTest() {
        String id = "TC01";
        String name = "Use today's date";
        announce(id, name, "Click the today button and validate the result.");
        System.out.println("  Action: click today button");
        driver.findElement(By.id("nowButton")).click();
        assertResult(id, name, "Ngày hợp lệ");
    }

    private void runFormTest(
            String id,
            String name,
            String day,
            String month,
            String year,
            String expectedTitle) {
        announce(id, name, day + "/" + month + "/" + year);
        fill("day", day);
        fill("month", month);
        fill("year", year);
        pause();
        System.out.println("  Action: submit form");
        driver.findElement(By.cssSelector("button[type='submit']")).click();
        assertResult(id, name, expectedTitle);
    }

    private void assertResult(String id, String name, String expectedTitle) {
        wait.until(ExpectedConditions.textToBe(By.id("resultTitle"), expectedTitle));
        String actualTitle = driver.findElement(By.id("resultTitle")).getText();
        String input = currentInput();
        System.out.println("  Input: " + input);
        System.out.println("  Expected result: " + expectedTitle);
        System.out.println("  Actual result: " + actualTitle);
        if (!expectedTitle.equals(actualTitle)) {
            throw new IllegalStateException(id + " expected '" + expectedTitle + "' but received '" + actualTitle + "'.");
        }

        String passed = id + " PASS - " + name;
        passedTests.add(passed);
        showOverlay(passed, "Input: " + input + "<br>Expected: " + expectedTitle + "<br>Actual: " + actualTitle, "#0f766e");
        System.out.println(passed);
        pauseForResult();
        hideOverlay();
    }

    private void fill(String id, String value) {
        WebElement field = driver.findElement(By.id(id));
        field.clear();
        pauseBetweenFields();
        field.sendKeys(value);
        System.out.println("  Input " + id + " = " + value);
        pauseBetweenFields();
    }

    private String currentInput() {
        return driver.findElement(By.id("day")).getAttribute("value")
                + "/" + driver.findElement(By.id("month")).getAttribute("value")
                + "/" + driver.findElement(By.id("year")).getAttribute("value");
    }

    private void announce(String id, String name, String input) {
        System.out.println();
        System.out.println(id + " RUNNING - " + name + " - " + input);
    }

    private void showOverlay(String title, String message, String color) {
        javascript.executeScript(
                "let panel=document.querySelector('#selenium-demo-panel');"
                        + "if(!panel){panel=document.createElement('aside');panel.id='selenium-demo-panel';"
                        + "document.body.append(panel);}"
                        + "panel.style.cssText='position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);"
                        + "z-index:99999;width:min(620px,calc(100vw - 36px));padding:34px 38px;"
                        + "border-radius:18px;color:white;text-align:center;font:700 18px/1.55 Segoe UI,Arial,sans-serif;"
                        + "box-shadow:0 28px 90px rgba(0,0,0,.38);background:' + arguments[2] + ';"
                        + "outline:9999px solid rgba(0,0,0,.28);';"
                        + "panel.innerHTML='<strong style=\"display:block;font-size:30px;line-height:1.2;margin-bottom:12px\">'"
                        + "+arguments[0]+'</strong><span style=\"display:block;font-size:18px;font-weight:650\">'+arguments[1]+'</span>';",
                title,
                message,
                color);
    }

    private void hideOverlay() {
        javascript.executeScript(
                "let panel=document.querySelector('#selenium-demo-panel');"
                        + "if(panel){panel.remove();}");
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
        sleep(STEP_DELAY_MS);
    }

    private static void pauseForResult() {
        sleep(RESULT_DELAY_MS);
    }

    private static void pauseBetweenFields() {
        sleep(FIELD_DELAY_MS);
    }

    private static void sleep(long milliseconds) {
        try {
            Thread.sleep(milliseconds);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("The Selenium demo was interrupted.", exception);
        }
    }
}
