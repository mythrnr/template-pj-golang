package config

import (
	"os"
	"strings"

	validation "github.com/go-ozzo/ozzo-validation/v4"
	"github.com/go-ozzo/ozzo-validation/v4/is"
)

func (c *Config) bindElasticsearch() error {
	hosts := strings.Split(ts(os.Getenv("ELASTICSEARCH_HOSTS")), ",")
	c.Elasticsearch.Hosts = make([]string, 0, len(hosts))

	for _, h := range hosts {
		c.Elasticsearch.Hosts = append(c.Elasticsearch.Hosts, h)
	}

	return validation.Errors{
		"elasticsearch.hosts": validation.Validate(
			c.Elasticsearch.Hosts,
			validation.Required,
			validation.Each(validation.Required, is.URL),
		),
	}.Filter()
}
