#!/usr/bin/env bats

key="metrics-app-dev-$CI_COMMIT_REF_NAME-$CI_JOB_ID"
payload="Payload for $now"

@test "check version URL Content" {
  curl -f metrics-app-dev-$CI_COMMIT_REF_NAME:8080/version | fgrep -q $CI_COMMIT_SHA
}

@test "check not found get" {
  curl -s -o /dev/null -w "%{http_code}" metrics-app-dev-$CI_COMMIT_REF_NAME:8080/trololos/$key | fgrep -q 404
}

@test "check put" {
  curl -s -o /dev/null -w "%{http_code}" -X PUT metrics-app-dev-$CI_COMMIT_REF_NAME:8080/trololos/$key -d "$payload" | fgrep -q 201
}

@test "check found get" {
  curl -s -o /dev/null -w "%{http_code}" metrics-app-dev-$CI_COMMIT_REF_NAME:8080/trololos/$key  | fgrep -q 200
}

@test "check found delete" {
  curl -s -o /dev/null -w "%{http_code}" -X DELETE metrics-app-dev-$CI_COMMIT_REF_NAME:8080/trololos/$key  | fgrep -q 204
}

@test "check not found delete" {
  curl -s -o /dev/null -w "%{http_code}" -X DELETE metrics-app-dev-$CI_COMMIT_REF_NAME:8080/trololos/$key  | fgrep -q 404
}
