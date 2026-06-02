package com.datetimechecker;

import org.openqa.selenium.By;
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

public final class AiGeneratedSeleniumDemo {
    private static final String APP_URL = System.getProperty("datetimechecker.url", "http://localhost:4173");
    private static final long STEP_DELAY_MS = 900;

    private final WebDriver driver;
    private final WebDriverWait wait;
    private final JavascriptExecutor javascript;
    private final boolean autoClose;
    private final List<String> failures = new ArrayList<String>();
    private int passed;

    private AiGeneratedSeleniumDemo(boolean headless, boolean autoClose) {
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

    public static void main(String[] args) throws IOException {
        String file = valueAfter(args, "--cases");
        if (file == null) throw new IllegalArgumentException("Missing --cases path.");
        boolean headless = hasArgument(args, "--headless");
        boolean autoClose = hasArgument(args, "--auto-close");
        AiGeneratedSeleniumDemo demo = new AiGeneratedSeleniumDemo(headless, autoClose);
        try {
            demo.run(Paths.get(file));
        } finally {
            demo.driver.quit();
        }
    }

    private void run(Path path) throws IOException {
        List<TestCase> testCases = readCases(path);
        driver.get(APP_URL);
        wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("dateTimeForm")));
        showOverlay("AI-GENERATED SELENIUM TEST", testCases.size() + " dynamic test cases loaded from AI output.", "#0f766e");
        pause();

        for (TestCase testCase : testCases) {
            execute(testCase);
        }

        Path failurePath = Paths.get("reports", "ai-selenium-failures.tsv");
        Files.createDirectories(failurePath.getParent());
        List<String> lines = new ArrayList<String>();
        lines.add("failure");
        lines.addAll(failures);
        Files.write(failurePath, lines, StandardCharsets.UTF_8);

        String title = failures.isEmpty() ? "AI SELENIUM TEST PASSED" : "AI SELENIUM FOUND BUGS";
        String color = failures.isEmpty() ? "#0f766e" : "#be3f4b";
        String summary = passed + " passed, " + failures.size() + " failed."
                + "<br><br>" + String.join("<br>", failures.isEmpty() ? java.util.Collections.singletonList("No UI bugs detected.") : failures);
        showOverlay(title, summary, color);
        System.out.println();
        System.out.println("AI-generated Selenium results: " + passed + " passed, " + failures.size() + " failed.");
        waitBeforeClosing();
        if (!failures.isEmpty()) System.exit(2);
    }

    private void execute(TestCase testCase) {
        showOverlay(testCase.id + " - " + testCase.title, "AI reason: " + testCase.reason, "#d97706");
        System.out.println();
        System.out.println(testCase.id + " RUNNING - " + testCase.title + " - " + testCase.reason);
        fill("day", testCase.day);
        fill("month", testCase.month);
        fill("year", testCase.year);
        fill("hour", testCase.hour);
        fill("minute", testCase.minute);
        fill("second", testCase.second);
        driver.findElement(By.cssSelector("button[type='submit']")).click();

        try {
            wait.until(ExpectedConditions.textToBe(By.id("resultTitle"), testCase.expectedTitle));
            passed++;
            System.out.println(testCase.id + " PASS");
            showOverlay(testCase.id + " PASS", "Expected result: " + testCase.expectedTitle, "#0f766e");
        } catch (RuntimeException exception) {
            String actual = driver.findElement(By.id("resultTitle")).getText();
            String failure = testCase.id + " FAIL - expected=" + testCase.expectedTitle + " actual=" + actual + " input=" + testCase.input();
            failures.add(failure);
            System.out.println(failure);
            showOverlay(testCase.id + " FAIL", failure, "#be3f4b");
        }
        pause();
    }

    private static List<TestCase> readCases(Path path) throws IOException {
        List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
        List<TestCase> cases = new ArrayList<TestCase>();
        for (int index = 1; index < lines.size(); index++) {
            String[] cells = lines.get(index).split("\\t", -1);
            if (cells.length < 10) throw new IllegalArgumentException("Invalid testcase TSV row: " + lines.get(index));
            cases.add(new TestCase(cells));
        }
        return cases;
    }

    private void fill(String id, String value) {
        WebElement field = driver.findElement(By.id(id));
        field.clear();
        field.sendKeys(value);
    }

    private void showOverlay(String title, String message, String color) {
        javascript.executeScript(
                "let panel=document.querySelector('#selenium-demo-panel');"
                        + "if(!panel){panel=document.createElement('aside');panel.id='selenium-demo-panel';document.body.append(panel);}"
                        + "panel.style.cssText='position:fixed;right:18px;bottom:18px;z-index:99999;max-width:430px;padding:18px 20px;"
                        + "border-radius:16px;color:white;font:600 14px/1.55 Segoe UI,Arial,sans-serif;"
                        + "box-shadow:0 15px 45px rgba(0,0,0,.25);background:'+arguments[2]+';';"
                        + "panel.innerHTML='<strong style=\"display:block;font-size:16px;margin-bottom:6px\">'+arguments[0]+'</strong><span>'+arguments[1]+'</span>';",
                title, message, color);
    }

    private void waitBeforeClosing() {
        if (autoClose) return;
        System.out.println("Press ENTER to close the Selenium browser.");
        new Scanner(System.in).nextLine();
    }

    private static boolean hasArgument(String[] args, String expected) {
        for (String argument : args) if (expected.equals(argument)) return true;
        return false;
    }

    private static String valueAfter(String[] args, String expected) {
        for (int index = 0; index < args.length - 1; index++) {
            if (expected.equals(args[index])) return args[index + 1];
        }
        return null;
    }

    private static void pause() {
        try {
            Thread.sleep(STEP_DELAY_MS);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("The Selenium demo was interrupted.", exception);
        }
    }

    private static final class TestCase {
        final String id;
        final String title;
        final String day;
        final String month;
        final String year;
        final String hour;
        final String minute;
        final String second;
        final String expectedTitle;
        final String reason;

        TestCase(String[] cells) {
            id = cells[0]; title = cells[1]; day = cells[2]; month = cells[3]; year = cells[4];
            hour = cells[5]; minute = cells[6]; second = cells[7]; expectedTitle = cells[8]; reason = cells[9];
        }

        String input() {
            return day + "/" + month + "/" + year + " " + hour + ":" + minute + ":" + second;
        }
    }
}
