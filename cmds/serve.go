package cmds

import (
	"os"

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

		if c.App.LogLevel == config.LogLevelDebug {
			os.Stdout.WriteString(c.Dump())
		}

		if c.App.Env == config.EnvLocal {
			if err := migration.Up(getMigrationDatabaseURL()); err != nil {
				return err
			}
		}

		server := http.NewServer(c)
		server.Start()

		return nil
	},
}
