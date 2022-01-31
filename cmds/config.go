package cmds

import (
	"os"

	"github.com/mythrnr/template-pj-golang/config"
	"github.com/urfave/cli/v2"
)

var ConfigCommand = &cli.Command{
	Name: "config",
	Action: func(ctx *cli.Context) error {
		c, err := config.Load()
		if err != nil {
			return err
		}

		os.Stdout.WriteString(c.Dump())

		return nil
	},
}
