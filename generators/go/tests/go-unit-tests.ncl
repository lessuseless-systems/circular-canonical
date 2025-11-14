# Go Unit Test Generator
# Generates basic unit tests for the Go SDK

let config = import "../../../src/config.ncl" in

{
  test_code = m%"
package circularprotocol

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestNewClient(t *testing.T) {
	client := NewClient("https://test.com/api", "test-key")

	if client.GetNAGURL() != "https://test.com/api" {
		t.Errorf("Expected NAG URL 'https://test.com/api', got '%s'", client.GetNAGURL())
	}

	if client.GetNAGKey() != "test-key" {
		t.Errorf("Expected NAG key 'test-key', got '%s'", client.GetNAGKey())
	}
}

func TestNewClientWithConfig(t *testing.T) {
	cfg := Config{
		NAGURL: "https://custom.com/api",
		NAGKey: "custom-key",
	}
	client := NewClientWithConfig(cfg)

	if client.GetNAGURL() != "https://custom.com/api" {
		t.Errorf("Expected NAG URL 'https://custom.com/api', got '%s'", client.GetNAGURL())
	}
}

func TestSettersAndGetters(t *testing.T) {
	client := NewClient("", "")

	client.SetNAGURL("https://new.com/api")
	if client.GetNAGURL() != "https://new.com/api" {
		t.Errorf("SetNAGURL failed")
	}

	client.SetNAGKey("new-key")
	if client.GetNAGKey() != "new-key" {
		t.Errorf("SetNAGKey failed")
	}

	client.SetHeader("X-Custom", "value")
	if client.headers["X-Custom"] != "value" {
		t.Errorf("SetHeader failed")
	}
}

func TestMakeRequest_Success(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"Result": 200, "Response": {"data": "success"}}`))
	}))
	defer server.Close()

	client := NewClient(server.URL+"/", "")
	result, err := client.makeRequest(context.Background(), "TestEndpoint", map[string]interface{}{
		"param": "value",
	})

	if err != nil {
		t.Fatalf("makeRequest failed: %v", err)
	}

	if result["Result"].(float64) != 200 {
		t.Errorf("Expected Result 200, got %v", result["Result"])
	}
}

func TestMakeRequest_APIError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"Result": 111, "Response": "Invalid parameter"}`))
	}))
	defer server.Close()

	client := NewClient(server.URL+"/", "")
	_, err := client.makeRequest(context.Background(), "TestEndpoint", map[string]interface{}{})

	if err == nil {
		t.Fatal("Expected error, got nil")
	}

	apiErr, ok := err.(*APIError)
	if !ok {
		t.Fatalf("Expected *APIError, got %T", err)
	}

	if apiErr.StatusCode != 111 {
		t.Errorf("Expected status code 111, got %d", apiErr.StatusCode)
	}
}

func TestMakeRequest_HTTPError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer server.Close()

	client := NewClient(server.URL+"/", "")
	_, err := client.makeRequest(context.Background(), "TestEndpoint", map[string]interface{}{})

	if err == nil {
		t.Fatal("Expected error, got nil")
	}

	apiErr, ok := err.(*APIError)
	if !ok {
		t.Fatalf("Expected *APIError, got %T", err)
	}

	if apiErr.StatusCode != http.StatusInternalServerError {
		t.Errorf("Expected status code 500, got %d", apiErr.StatusCode)
	}
}
"%,
}
