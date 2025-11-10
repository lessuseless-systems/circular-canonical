# Java Unit Test Generator
# Generates JUnit 5 tests with Mockito

let config = import "../../../src/config.ncl" in
let helpers = import "../../shared/helpers.ncl" in

# Helper: Convert PascalCase to camelCase
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  "%{std.string.lowercase first_char}%{rest}"
in

{
  test_code = m%"
package io.circular.protocol;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import java.net.http.HttpClient;
import java.net.http.HttpResponse;
import java.util.concurrent.CompletableFuture;

/**
 * Circular Protocol Java SDK Unit Tests
 * Generated from Nickel API specification
 *
 * Tests SDK helper functions and basic functionality
 */
@DisplayName("CircularProtocolAPI Unit Tests")
class CircularProtocolAPITest {

    private CircularProtocolAPI api;

    @BeforeEach
    void setUp() {
        api = new CircularProtocolAPI();
    }

    @Test
    @DisplayName("Constructor should set default NAG URL")
    void testConstructorDefaultUrl() {
        CircularProtocolAPI defaultApi = new CircularProtocolAPI();
        assertEquals("https://nag.circularlabs.io/NAG.php?cep=", defaultApi.getNagUrl());
    }

    @Test
    @DisplayName("Constructor should accept custom NAG URL")
    void testConstructorCustomUrl() {
        CircularProtocolAPI customApi = new CircularProtocolAPI("https://custom.url", null);
        assertEquals("https://custom.url", customApi.getNagUrl());
    }

    @Test
    @DisplayName("Constructor should accept NAG key")
    void testConstructorWithKey() {
        CircularProtocolAPI customApi = new CircularProtocolAPI(null, "test-key");
        assertEquals("test-key", customApi.getNagKey());
    }

    @Test
    @DisplayName("setNagUrl should update URL")
    void testSetNagUrl() {
        api.setNagUrl("https://new.url");
        assertEquals("https://new.url", api.getNagUrl());
    }

    @Test
    @DisplayName("setNagKey should update key")
    void testSetNagKey() {
        api.setNagKey("new-key");
        assertEquals("new-key", api.getNagKey());
    }

    @Test
    @DisplayName("CircularProtocolException should store status code")
    void testExceptionStatusCode() {
        CircularProtocolAPI.CircularProtocolException ex =
            new CircularProtocolAPI.CircularProtocolException("Test error", 404, "/test");

        assertEquals(404, ex.getStatusCode());
        assertEquals("/test", ex.getEndpoint());
        assertEquals("Test error", ex.getMessage());
    }

    @Test
    @DisplayName("CircularProtocolException should wrap cause")
    void testExceptionWithCause() {
        Exception cause = new RuntimeException("Root cause");
        CircularProtocolAPI.CircularProtocolException ex =
            new CircularProtocolAPI.CircularProtocolException("Test error", 500, "/test", cause);

        assertEquals(cause, ex.getCause());
    }
}
"%
}
