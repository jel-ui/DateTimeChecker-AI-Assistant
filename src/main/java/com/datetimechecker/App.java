package com.datetimechecker;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class App {
    private static final int DEFAULT_PORT = 4173;
    private static final Path STATIC_ROOT = Paths.get("src", "main", "resources", "static")
            .toAbsolutePath()
            .normalize();

    private App() {
    }

    public static void main(String[] args) throws IOException {
        int port = readPort();
        HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", port), 0);
        server.createContext("/api/datetime/check", new DateTimeCheckHandler());
        server.createContext("/", new StaticFileHandler());
        server.setExecutor(Executors.newCachedThreadPool());
        server.start();
        System.out.println("Date Time Checker Java is running at http://localhost:" + port);
        System.out.println("Press Ctrl+C to stop.");
    }

    private static int readPort() {
        String value = System.getProperty("datetimechecker.port");
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv("PORT");
        }
        if (value == null || value.trim().isEmpty()) {
            return DEFAULT_PORT;
        }

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            return DEFAULT_PORT;
        }
    }

    private static final class DateTimeCheckHandler implements HttpHandler {
        private final DateTimeValidationService validator = new DateTimeValidationService();

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                sendText(exchange, 405, "Method not allowed", "text/plain; charset=utf-8");
                return;
            }

            String body = readText(exchange.getRequestBody());
            DateTimeValidationService.DateTimeCheckRequest request = JsonRequestParser.parse(body);
            sendText(exchange, 200, validator.validate(request).toJson(), "application/json; charset=utf-8");
        }
    }

    private static final class StaticFileHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            if (!"GET".equalsIgnoreCase(exchange.getRequestMethod())
                    && !"HEAD".equalsIgnoreCase(exchange.getRequestMethod())) {
                sendText(exchange, 405, "Method not allowed", "text/plain; charset=utf-8");
                return;
            }

            String requestPath = exchange.getRequestURI().getPath();
            if ("/".equals(requestPath)) {
                requestPath = "/index.html";
            }

            Path file = STATIC_ROOT.resolve(requestPath.substring(1)).normalize();
            if (!file.startsWith(STATIC_ROOT) || !Files.isRegularFile(file)) {
                sendText(exchange, 404, "Not found", "text/plain; charset=utf-8");
                return;
            }

            byte[] content = Files.readAllBytes(file);
            Headers headers = exchange.getResponseHeaders();
            headers.set("Content-Type", contentType(file));
            exchange.sendResponseHeaders(200, "HEAD".equalsIgnoreCase(exchange.getRequestMethod()) ? -1 : content.length);
            if (!"HEAD".equalsIgnoreCase(exchange.getRequestMethod())) {
                try (OutputStream output = exchange.getResponseBody()) {
                    output.write(content);
                }
            } else {
                exchange.close();
            }
        }

        private static String contentType(Path file) {
            String name = file.getFileName().toString().toLowerCase();
            if (name.endsWith(".html")) return "text/html; charset=utf-8";
            if (name.endsWith(".css")) return "text/css; charset=utf-8";
            if (name.endsWith(".js")) return "text/javascript; charset=utf-8";
            if (name.endsWith(".json") || name.endsWith(".webmanifest")) return "application/json; charset=utf-8";
            if (name.endsWith(".svg")) return "image/svg+xml";
            if (name.endsWith(".png")) return "image/png";
            return "application/octet-stream";
        }
    }

    private static final class JsonRequestParser {
        private static final Pattern PROPERTY_PATTERN = Pattern.compile(
                "\"([^\"]+)\"\\s*:\\s*(?:\"((?:\\\\.|[^\"])*)\"|(-?\\d+)|null)");

        private JsonRequestParser() {
        }

        static DateTimeValidationService.DateTimeCheckRequest parse(String json) {
            Map<String, String> values = new HashMap<String, String>();
            Matcher matcher = PROPERTY_PATTERN.matcher(json);
            while (matcher.find()) {
                String value = matcher.group(2) != null ? unescape(matcher.group(2)) : matcher.group(3);
                values.put(matcher.group(1), value);
            }

            return new DateTimeValidationService.DateTimeCheckRequest(
                    values.get("day"),
                    values.get("month"),
                    values.get("year"));
        }

        private static String unescape(String value) {
            return value
                    .replace("\\\"", "\"")
                    .replace("\\\\", "\\")
                    .replace("\\n", "\n")
                    .replace("\\r", "\r")
                    .replace("\\t", "\t");
        }
    }

    private static String readText(InputStream input) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int length;
        while ((length = input.read(buffer)) != -1) {
            output.write(buffer, 0, length);
        }
        return new String(output.toByteArray(), StandardCharsets.UTF_8);
    }

    private static void sendText(HttpExchange exchange, int status, String text, String contentType) throws IOException {
        byte[] content = text.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", contentType);
        exchange.sendResponseHeaders(status, content.length);
        try (OutputStream output = exchange.getResponseBody()) {
            output.write(content);
        }
    }
}
