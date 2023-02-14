package config

import (
	validation "github.com/go-ozzo/ozzo-validation/v4"
	"golang.org/x/text/language"
)

func (c *Config) bindLang() error {
	c.Lang.Fallback = ts(c.Lang.Fallback)
	c.Lang.HTTPHeaderName = ts(c.Lang.HTTPHeaderName)

	return validation.Errors{
		"lang.fallback": validation.Validate(
			c.Lang.Fallback,
			validation.Required,
			validation.By(func(v interface{}) error {
				_, err := language.Parse(v.(string))

				return err
			}),
		),
		"lang.http_header_name": validation.Validate(
			c.Lang.HTTPHeaderName,
			validation.Required,
		),
	}.Filter()
}
