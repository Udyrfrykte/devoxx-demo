package main

import (
	//"github.com/go-redis/redis"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// MemKV Memory implmentation of KV
type MemKV struct {
	store map[string]string
}

func NewMemKV() *MemKV {
	fmt.Println("NewMemKV")
	return &MemKV{make(map[string]string)}
}

// Get implementation of KV.Get
func (mkv *MemKV) Get(k string) (interface{}, error) {
	fmt.Printf("Get[%s]\n", k)
	val, ok := mkv.store[k]
	if ok {
		return val, nil
	}
	return nil, ErrKVNotFound
}

// Set implementation of KV.Set
func (mkv *MemKV) Set(k string, v string) error {
	fmt.Printf("Set[%s]=%s\n", k, v)
	mkv.store[k] = string(v[:])
	return nil
}

// Del implementation of KV.Del
func (mkv *MemKV) Del(k string) (int64, error) {
	fmt.Printf("Del[%s]\n", k)
	_, ok := mkv.store[k]
	if ok {
		delete(mkv.store, k)
		return 1, nil
	}
	return 0, nil
}

func TestHealthz(t *testing.T) {
	req, err := http.NewRequest("GET", "/healthz", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	t.Logf("code: %d, body: %s", rr.Code, rr.Body)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
}

func TestVersion(t *testing.T) {
	req, err := http.NewRequest("GET", "/version", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	t.Logf("code: %d, body: %s", rr.Code, rr.Body)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	expected := `{"commit_hash":"No version","build_date":0}`
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}

func TestDefault(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}
	req.RemoteAddr = "10.0.5.55:60444"

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	expected := "10.0.5.55"
	if !strings.Contains(rr.Body.String(), expected) {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}

func TestDefaultForwardedFor(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("X-Forwarded-For", "10.0.0.1, 10.0.0.2, 10.0.0.3")

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	expected := "10.0.0.1"
	if !strings.Contains(rr.Body.String(), expected) {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}

func TestMetrics(t *testing.T) {
	req, err := http.NewRequest("GET", "/metrics", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	if !strings.Contains(rr.Body.String(), "fake_load") {
		t.Errorf("Expected fake_calls in body: in %v", rr.Body.String())
	}
}

func TestPutWithNoServer(t *testing.T) {
	req, err := http.NewRequest("PUT", "/trololos/plop", strings.NewReader("onk"))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	kvStore = NewRedisKV("plop", []string{"localhost:1"})
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusInternalServerError {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusInternalServerError)
	}
}

func TestGetWithNoServer(t *testing.T) {
	req, err := http.NewRequest("GET", "/trololos/plop", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	kvStore = NewRedisKV("plop", []string{"localhost:1"})
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusInternalServerError {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusInternalServerError)
	}
}

func TestDeleteWithNoServer(t *testing.T) {
	req, err := http.NewRequest("DELETE", "/trololos/plop", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	kvStore = NewRedisKV("plop", []string{"localhost:1"})
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusInternalServerError {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusInternalServerError)
	}
}

func TestNotFoundGetWithMockedServer(t *testing.T) {
	req, err := http.NewRequest("GET", "/trololos/plop", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	kvStore = NewMemKV()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusNotFound {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusNotFound)
	}
}

func TestPutWithMockedServer(t *testing.T) {
	req, err := http.NewRequest("PUT", "/trololos/plop", strings.NewReader("bidibule25"))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	kvStore = NewMemKV()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusCreated {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusCreated)
	}
}

func TestFoundGetWithMockedServer(t *testing.T) {
	TestPutWithMockedServer(t)
	req, err := http.NewRequest("GET", "/trololos/plop", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
	if !strings.Contains(rr.Body.String(), "bidibule25") {
		t.Errorf("Expected bidibule25 in body: in %v", rr.Body.String())
	}
}

func TestFoundDeleteWithMockedServer(t *testing.T) {
	TestPutWithMockedServer(t)
	req, err := http.NewRequest("DELETE", "/trololos/plop", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusNoContent {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusNoContent)
	}
}

func TestNotFoundDeleteWithMockedServer(t *testing.T) {
	req, err := http.NewRequest("DELETE", "/trololos/plop", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router := NewRouter()
	kvStore = NewMemKV()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusNotFound {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusNotFound)
	}
}
