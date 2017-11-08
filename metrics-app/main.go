package main

import (
	"encoding/json"
	"github.com/prometheus/client_golang/prometheus"
	"log"
	"net/http"
	"os"
	"strconv"
)

var (
	version   = "No version"
	timestamp = "0.0"
	fakeLoad  = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "fake_load",
		Help: "Fake load Gauge",
	})
	appInfo = prometheus.NewGauge(prometheus.GaugeOpts{
		Name:        "app_info",
		Help:        "Information about application",
		ConstLabels: prometheus.Labels{"version": version, "build_timestamp": timestamp},
	})
	versionString = ""
	kvStore       KV
)

func init() {
	// Metrics have to be registered to be exposed:
	prometheus.MustRegister(fakeLoad)
	prometheus.MustRegister(appInfo)
	ts, err := strconv.ParseFloat(timestamp, 64)
	if err != nil {
		panic(err)
	}
	appInfo.Set(1)
	b, err := json.Marshal(VersionInfo{version, int(ts)})
	if err != nil {
		panic(err)
	}
	versionString = string(b)
}

func main() {
	redisName := os.Getenv("REDIS_MASTER_NAME")
	if redisName == "" {
		redisName = "mymaster"
	}
	redisDest := os.Getenv("REDIS_SENTINEL_ADDR")
	if redisDest == "" {
		redisDest = "redis-sentinel:26379"
	}
	kvStore = NewRedisKV(redisName, []string{redisDest})
	router := NewRouter()
	log.Println("API Server staring on port :8080")
	log.Fatal(http.ListenAndServe(":8080", router))
}
