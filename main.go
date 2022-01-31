package main

import (
	"fmt"
	"log"
	"os"

	"github.com/mythrnr/template-pj-golang/cmds"
	"github.com/mythrnr/template-pj-golang/config"
	"github.com/urfave/cli/v2"
)

func main() {
	cmd := cli.NewApp()
	cmd.Version = fmt.Sprintf("%s - %s", config.Version, config.Revision)
	cmd.Commands = []*cli.Command{
		cmds.BatchCommand,
		cmds.ConfigCommand,
		cmds.MigrationCommand,
		cmds.ServeCommand,
	}

	if err := cmd.Run(os.Args); err != nil {
		log.Panicf("%+v", err)
	}
}
