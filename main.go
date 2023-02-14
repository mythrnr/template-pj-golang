package main

import (
	"fmt"
	"log"
	"os"

	"github.com/mythrnr/template-pj-golang/app/cmd"
	"github.com/mythrnr/template-pj-golang/config"
	"github.com/urfave/cli/v2"
)

func main() {
	app := cli.NewApp()
	app.Version = fmt.Sprintf("%s - %s", config.Version, config.Revision)
	app.Commands = []*cli.Command{
		cmd.BatchCommand,
		cmd.ConfigCommand,
		cmd.MigrationCommand,
		cmd.ServeCommand,
	}

	if err := app.Run(os.Args); err != nil {
		log.Panicf("%+v", err)
	}
}
