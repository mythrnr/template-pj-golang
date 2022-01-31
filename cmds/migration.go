package cmds

import (
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"

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
	host := os.Getenv("DATABASE_MYSQL_MIGRATE_HOST")
	port := os.Getenv("DATABASE_MYSQL_MIGRATE_PORT")
	database := os.Getenv("DATABASE_MYSQL_MIGRATE_DBNAME")
	username := os.Getenv("DATABASE_MYSQL_MIGRATE_USER")
	password := os.Getenv("DATABASE_MYSQL_MIGRATE_PASSWORD")

	return fmt.Sprintf(
		"mysql://%s:%s@tcp(%s:%s)/%s",
		strings.TrimSpace(username),
		strings.TrimSpace(password),
		strings.TrimSpace(host),
		strings.TrimSpace(port),
		strings.TrimSpace(database),
	) + "?" + url.Values{
		"charset": []string{"utf8mb4"},
		"loc":     []string{"UTC"},
	}.Encode()
}
