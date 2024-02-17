package cmd

import (
	"log"
	"os"

	"github.com/mythrnr/template-pj-golang/config"
	"github.com/urfave/cli/v2"
)

var ConfigCommand = &cli.Command{
	Name: "config",
	Action: func(_ *cli.Context) error {
		c, err := config.Load()
		if err != nil {
			log.Printf("%+v", err)

			return err
		}

		os.Stdout.WriteString(c.Dump())

		return nil
	},
}
