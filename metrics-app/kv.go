package main

import "errors"

// KV wrapper to a generic k/v provider
type KV interface {
	Get(k string) (interface{}, error)
	Set(k string, v string) error
	Del(k string) (int64, error)
}

// ErrKVNotFound Error set if key not found in K/V Store
var ErrKVNotFound = errors.New("Not found")
