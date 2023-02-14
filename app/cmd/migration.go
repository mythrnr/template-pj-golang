package cmd

import (
	"fmt"
	"log"
	"os"

	"github.com/go-sql-driver/mysql"
	"github.com/mythrnr/template-pj-golang/migration"
	"github.com/urfave/cli/v2"
)

var migrateFlags = []cli.Flag{
	&cli.BoolFlag{
		Name:  "test",
		Value: false,
		Usage: "specify if you want to migrate test DB",
	},
}

var MigrationCommand = &cli.Command{
	Name: "migrate",
	Action: func(ctx *cli.Context) error {
		if err := migration.Up(getDSN(ctx.Bool("test"))); err != nil {
			log.Printf("%+v", err)

			return err
		}

		log.Println("Migration up successfully.")

		return nil
	},
	Flags: migrateFlags,
	Subcommands: []*cli.Command{{
		Name: "up",
		Action: func(ctx *cli.Context) error {
			if err := migration.Up(getDSN(ctx.Bool("test"))); err != nil {
				log.Printf("%+v", err)

				return err
			}

			log.Println("Migration up successfully.")

			return nil
		},
		Flags: migrateFlags,
	}, {
		Name: "down",
		Action: func(ctx *cli.Context) error {
			if err := migration.Down(getDSN(ctx.Bool("test"))); err != nil {
				log.Printf("%+v", err)

				return err
			}

			log.Println("Migration down successfully.")

			return nil
		},
		Flags: migrateFlags,
	}},
}

func getDSN(test bool) string {
	if test {
		return getMigrationTestDatabaseDSN()
	}

	return getMigrationDatabaseDSN()
}

func getMigrationDatabaseDSN() string {
	c := mysql.NewConfig()

	c.DBName = os.Getenv("DATABASE_MYSQL_MIGRATE_DBNAME")
	c.User = os.Getenv("DATABASE_MYSQL_MIGRATE_USER")
	c.Passwd = os.Getenv("DATABASE_MYSQL_MIGRATE_PASSWORD")
	c.Net = "tcp"
	c.Addr = fmt.Sprintf(
		"%s:%s",
		os.Getenv("DATABASE_MYSQL_MIGRATE_HOST"),
		os.Getenv("DATABASE_MYSQL_MIGRATE_PORT"),
	)
	c.ParseTime = true

	return "mysql://" + c.FormatDSN()
}

func getMigrationTestDatabaseDSN() string {
	c := mysql.NewConfig()

	c.DBName = os.Getenv("DATABASE_MYSQL_MIGRATE_DBNAME_TEST")
	c.User = os.Getenv("DATABASE_MYSQL_MIGRATE_USER_TEST")
	c.Passwd = os.Getenv("DATABASE_MYSQL_MIGRATE_PASSWORD_TEST")
	c.Net = "tcp"
	c.Addr = fmt.Sprintf(
		"%s:%s",
		os.Getenv("DATABASE_MYSQL_MIGRATE_HOST_TEST"),
		os.Getenv("DATABASE_MYSQL_MIGRATE_PORT_TEST"),
	)
	c.ParseTime = true

	return "mysql://" + c.FormatDSN()
}
