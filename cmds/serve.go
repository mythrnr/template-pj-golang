package cmds

import (
	"os"

	"github.com/mythrnr/template-pj-golang/builder"
	"github.com/mythrnr/template-pj-golang/config"
	"github.com/mythrnr/template-pj-golang/http"
	"github.com/mythrnr/template-pj-golang/migration"
	"github.com/urfave/cli/v2"
)

var ServeCommand = &cli.Command{
	Name: "serve",
	Action: func(ctx *cli.Context) error {
		c, err := config.Load()
		if err != nil {
			return err
		}

		if c.App.LogLevel == "debug" {
			os.Stdout.WriteString(c.Dump())
		}

		d, err := builder.Resolve(c)
		if err != nil {
			return err
		}

		if c.App.Env == "local" {
			if err := migration.Up(getMigrationDatabaseURL()); err != nil {
				return err
			}
		}

		server := http.NewServer(d)
		server.Start()

		return nil
	},
}
