package cmd

import (
	"log"
	"os"

	"github.com/mythrnr/template-pj-golang/app/http"
	"github.com/mythrnr/template-pj-golang/config"
	"github.com/mythrnr/template-pj-golang/migration"
	"github.com/urfave/cli/v2"
)

var ServeCommand = &cli.Command{
	Name: "serve",
	Action: func(ctx *cli.Context) error {
		c, err := config.Load()
		if err != nil {
			log.Printf("%+v", err)

			return err
		}

		if c.App.LogLevel == config.LogLevelDebug {
			os.Stdout.WriteString(c.Dump())
		}

		if c.App.Env == config.EnvLocal {
			if err := migration.Up(getDSN(false)); err != nil {
				log.Printf("%+v", err)

				return err
			}

			if err := migration.Up(getDSN(true)); err != nil {
				log.Printf("%+v", err)

				return err
			}
		}

		server := http.NewServer(c)
		server.Start()

		return nil
	},
}
