#!/usr/bin/env bats

@test "check found get" {
  curl -s -o /dev/null -w "%{http_code}" localhost:80 | fgrep -q 200
}

@test "check not found get" {
  curl -s -o /dev/null -w "%{http_code}" localhost:80/rekterltherl | fgrep -q 404
}
