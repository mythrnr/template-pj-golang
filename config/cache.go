package config

import (
	"os"
	"strconv"

	validation "github.com/go-ozzo/ozzo-validation/v4"
	"github.com/pkg/errors"
)

func (c *Config) bindCache() error {
	c.Cache.Redis.Host = ts(os.Getenv("CACHE_REDIS_HOST"))
	c.Cache.Redis.Password = ts(os.Getenv("CACHE_REDIS_PASSWORD"))

	if v := ts(os.Getenv("CACHE_REDIS_PORT")); v != "" {
		if v, err := strconv.ParseUint(v, 10, 16); err != nil {
			return errors.WithStack(err)
		} else if v != 0 {
			c.App.ListenPort = uint16(v)
		}
	}

	return validation.Errors{
		"cache.redis.host": validation.Validate(
			c.Cache.Redis.Host,
			validation.Required,
		),
		"cache.redis.port": validation.Validate(
			int64(c.Cache.Redis.Port),
			validation.Required,
		),
	}.Filter()
}
