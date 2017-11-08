package main

import (
	"github.com/go-redis/redis"
)

// RedisKV Redis implmentation of KV
type RedisKV struct {
	client *redis.Client
}

// NewRedisKV Creates and Initialize a new RedisKV
func NewRedisKV(redisName string, sentinelAddrs []string) *RedisKV {
	client := redis.NewFailoverClient(&redis.FailoverOptions{
		MasterName:    redisName,
		SentinelAddrs: sentinelAddrs,
	})
	return &RedisKV{client}
}

// Get implementation of KV.Get
func (rkv *RedisKV) Get(k string) (interface{}, error) {
	val, err := rkv.client.Get(k).Result()
	if err == redis.Nil {
		return val, ErrKVNotFound
	}
	return val, err
}

// Set implementation of KV.Set
func (rkv *RedisKV) Set(k string, v string) error {
	return rkv.client.Set(k, v, 0).Err()
}

// Del implementation of KV.Del
func (rkv *RedisKV) Del(k string) (int64, error) {
	return rkv.client.Del(k).Result()
}
