package config

import (
	"os"
	"strconv"

	validation "github.com/go-ozzo/ozzo-validation/v4"
	pkgerrs "github.com/pkg/errors"
)

func (c *Config) bindDatabase() error {
	if v, err := strconv.ParseUint(
		os.Getenv("DATABASE_CONN_LIFETIME_SECONDS"), 10, 32,
	); err != nil {
		return pkgerrs.WithStack(err)
	} else if v != 0 {
		c.Database.Connection.LifeTimeSeconds = uint(v)
	}

	if v, err := strconv.ParseUint(
		os.Getenv("DATABASE_CONN_MAXIDLE"), 10, 32,
	); err != nil {
		return pkgerrs.WithStack(err)
	} else if v != 0 {
		c.Database.Connection.MaxIdle = uint(v)
	}

	if v, err := strconv.ParseUint(
		os.Getenv("DATABASE_CONN_MAXOPEN"), 10, 32,
	); err != nil {
		return pkgerrs.WithStack(err)
	} else if v != 0 {
		c.Database.Connection.MaxOpen = uint(v)
	}

	c.Database.MySQL.Database = ts(os.Getenv("DATABASE_MYSQL_DBNAME"))
	c.Database.MySQL.Host = ts(os.Getenv("DATABASE_MYSQL_HOST"))
	c.Database.MySQL.Password = ts(os.Getenv("DATABASE_MYSQL_PASSWORD"))
	c.Database.MySQL.Username = ts(os.Getenv("DATABASE_MYSQL_USER"))

	if v, err := strconv.ParseUint(
		os.Getenv("DATABASE_MYSQL_PORT"), 10, 16,
	); err != nil {
		return pkgerrs.WithStack(err)
	} else if v != 0 {
		c.Database.MySQL.Port = uint16(v)
	}

	return validation.Errors{
		"database.connection.life_time_seconds": validation.Validate(
			c.Database.Connection.LifeTimeSeconds,
			validation.Required,
		),
		"database.connection.max_idle": validation.Validate(
			c.Database.Connection.MaxIdle,
			validation.Required,
			validation.
				Min(c.Database.Connection.MaxOpen).
				Error(
					"database.connection.max_idle must be "+
						"grater than or equal database.connection.max_open",
				),
		),
		"database.connection.max_open": validation.Validate(
			c.Database.Connection.MaxOpen,
			validation.Required,
		),
		"database.mysql.charset": validation.Validate(
			c.Database.MySQL.Charset,
			validation.Required,
		),
		"database.mysql.database": validation.Validate(
			c.Database.MySQL.Database,
			validation.Required,
		),
		"database.mysql.host": validation.Validate(
			c.Database.MySQL.Host,
			validation.Required,
		),
		"database.mysql.password": validation.Validate(
			c.Database.MySQL.Password,
			validation.Required,
		),
		"database.mysql.port": validation.Validate(
			int64(c.Database.MySQL.Port),
			validation.Required,
		),
		"database.mysql.timezone": validation.Validate(
			c.Database.MySQL.Timezone,
			validation.Required,
		),
		"database.mysql.username": validation.Validate(
			c.Database.MySQL.Username,
			validation.Required,
		),
	}.Filter()
}
