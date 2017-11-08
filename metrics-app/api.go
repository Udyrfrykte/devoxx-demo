package main

import (
	"fmt"
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

var calls int

// Healthz provides a simple healthz HTTP/200 endpoint
func Healthz(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "")
}

// VersionInfo Struct for holding version information
type VersionInfo struct {
	CommitHash string `json:"commit_hash"`
	BuildDate  int    `json:"build_date"`
}

// Version handler for version endpoint
func Version(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, versionString)
}

// Default handler for root URL
func Default(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	hn, err := os.Hostname()
	if err != nil {
		fmt.Fprintf(w, "Can't get local hostname!")
	}
	fmt.Fprintf(w, "Request from %s served by %s\n", r.RemoteAddr, hn)
}

// GetTrololo GET /trololos/{key}
func GetTrololo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	vars := mux.Vars(r)
	val, err := kvStore.Get(vars["key"])
	if err == ErrKVNotFound {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		log.Printf("Looking for trololo %s, not found", vars["key"])
	} else if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Printf("Looking for trololo %s, technical problem", vars["key"])
	} else {
		fmt.Fprintf(w, "{\"payload\":\"%s\"}", val)
		log.Printf("Looking for trololo %s, found, value=%s", vars["key"], val)
	}
}

// PutTrololo PUT /trololos/{key}
func PutTrololo(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	key := vars["key"]
	payload, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Printf("Put trololo %s(%s) failed, can't read body", key, err)
		return
	}
	if err := kvStore.Set(key, string(payload[:])); err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Printf("Put trololo %s(%s) failed, technical problem: %s", key, payload, err)
		return
	}
	w.Header().Set("Location", r.URL.Path)
	http.Error(w, http.StatusText(http.StatusCreated), http.StatusCreated)
	log.Printf("Put trololo %s(%s) succeeded", key, payload)
}

// DeleteTrololo DELETE /trololos/{key}
func DeleteTrololo(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	vars := mux.Vars(r)
	val, err := kvStore.Del(vars["key"])
	if err != nil {
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		log.Printf("Deleting trololo %s, technical problem", vars["key"])
	} else if val >= 1 {
		log.Printf("Deleting trololo %s deleted %d keys", vars["key"], val)
		http.Error(w, http.StatusText(http.StatusNoContent), http.StatusNoContent)
	} else {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		log.Printf("Deleting trololo %s, not found", vars["key"])
	}
}
