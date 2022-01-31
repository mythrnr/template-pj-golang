package config

import (
	"os"

	validation "github.com/go-ozzo/ozzo-validation/v4"
	"github.com/go-ozzo/ozzo-validation/v4/is"
)

func (c *Config) bindHTTP() error {
	c.HTTP.Proxy = ts(os.Getenv("HTTP_PROXY"))

	return validation.Errors{
		"http.default_timeout": validation.Validate(
			int64(c.HTTP.DefaultTimeoutSeconds),
			validation.Required,
		),
		"http.proxy": validation.Validate(c.HTTP.Proxy, is.URL),
	}.Filter()
}
