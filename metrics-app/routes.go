package main

import "net/http"
import "github.com/prometheus/client_golang/prometheus"

// Route basic gorilla routing definition
type Route struct {
	Name        string
	Method      string
	Pattern     string
	HandlerFunc http.HandlerFunc
}

// Routes array of Route
type Routes []Route

var promHandler = prometheus.UninstrumentedHandler().ServeHTTP
var routes = Routes{
	Route{
		"Healthz",
		"GET",
		"/healthz",
		Healthz,
	},
	Route{
		"Metrics",
		"GET",
		"/metrics",
		promHandler,
	},
	Route{
		"Version",
		"GET",
		"/version",
		Version,
	},
	Route{
		"Default",
		"GET",
		"/",
		Default,
	},
	Route{
		"GetTrololo",
		"GET",
		"/trololos/{key}",
		GetTrololo,
	},
	Route{
		"DeleteTrololo",
		"DELETE",
		"/trololos/{key}",
		DeleteTrololo,
	},
	Route{
		"PutTrololo",
		"PUT",
		"/trololos/{key}",
		PutTrololo,
	},
}
