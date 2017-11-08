#!/usr/bin/env bats

@test "check healthz URL" {
  curl -sfq localhost:8080/healthz
}

@test "check version URL" {
  curl -sfq localhost:8080/version
}

@test "check metrics URL" {
  curl -sfq localhost:8080/metrics
}

@test "check version URL Content" {
  curl -sfq localhost:8080/version | fgrep -q $CI_COMMIT_SHA
}

@test "check version in metrics" {
  curl -sfq localhost:8080/metrics | fgrep -q $CI_COMMIT_SHA
}

@test "check metrics URL Content" {
  curl -sfq localhost:8080/metrics | fgrep -q http_request_duration_microseconds
}
@test "check home Headers handling" {
  curl -sfq -H 'X-Forwarded-For: 10.0.0.1, 10.0.0.2, 10.0.0.3' localhost:8080 | fgrep -q 10.0.0.1
}
