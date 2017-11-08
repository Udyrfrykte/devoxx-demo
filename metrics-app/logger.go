package main

import (
	"log"
	"math"
	"net/http"
	"time"
)

// Logger Wrapper for http.Handler that simply wraps for logs and metrics
func Logger(inner http.Handler, name string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fakeLoad.Set(50 + 50*math.Sin(float64(time.Now().Unix())/50))
		start := time.Now()
		inner.ServeHTTP(w, r)
		duration := time.Since(start)
		log.Printf(
			"%s\t%s\t%s\t%s",
			r.Method,
			r.RequestURI,
			name,
			duration,
		)
	})
}
