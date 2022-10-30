package cmds

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/go-sql-driver/mysql"
	"github.com/mythrnr/template-pj-golang/migration"
	"github.com/urfave/cli/v2"
)

var MigrationCommand = &cli.Command{
	Name: "migrate",
	Action: func(ctx *cli.Context) error {
		if err := migration.Up(getMigrationDatabaseURL()); err != nil {
			return err
		}

		log.Println("Migration up successfully.")

		return nil
	},
	Subcommands: []*cli.Command{{
		Name: "up",
		Action: func(ctx *cli.Context) error {
			if err := migration.Up(getMigrationDatabaseURL()); err != nil {
				return err
			}

			log.Println("Migration up successfully.")

			return nil
		},
	}, {
		Name: "down",
		Action: func(ctx *cli.Context) error {
			if err := migration.Down(getMigrationDatabaseURL()); err != nil {
				return err
			}

			log.Println("Migration down successfully.")

			return nil
		},
	}},
}

func getMigrationDatabaseURL() string {
	c := mysql.Config{
		DBName: os.Getenv("DATABASE_MYSQL_MIGRATE_DBNAME"),
		User:   os.Getenv("DATABASE_MYSQL_MIGRATE_USER"),
		Passwd: os.Getenv("DATABASE_MYSQL_MIGRATE_PASSWORD"),
		Addr: fmt.Sprintf(
			"%s:%s",
			os.Getenv("DATABASE_MYSQL_MIGRATE_HOST"),
			os.Getenv("DATABASE_MYSQL_MIGRATE_PORT"),
		),
		Net:       "tcp",
		ParseTime: true,
		Collation: "utf8mb4",
		Loc:       time.UTC,
	}

	return c.FormatDSN()
}
