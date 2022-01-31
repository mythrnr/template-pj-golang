package migration

import (
	"embed"
	"errors"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/mysql"
	"github.com/golang-migrate/migrate/v4/source/iofs"
)

//go:embed sql/*.sql
var sqlFiles embed.FS

func prepare(source string) (*migrate.Migrate, error) {
	driver, err := iofs.New(sqlFiles, "sql")
	if err != nil {
		return nil, err
	}

	return migrate.NewWithSourceInstance("iofs", driver, source)
}

func Up(source string) error {
	m, err := prepare(source)
	if err != nil {
		return err
	}

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return err
	}

	return nil
}

func Down(source string) error {
	m, err := prepare(source)
	if err != nil {
		return err
	}

	return m.Steps(-1)
}
