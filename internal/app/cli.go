package app

import (
	"fmt"

	"github.com/mythrnr/template-pj-golang/pkg/cli"
)

type cliApp struct{}

var _ cli.CLI = (*cliApp)(nil)

func NewCLI() cli.CLI {
	return &cliApp{}
}

func (c *cliApp) Execute(args []string) {
	fmt.Println("[CLI] Hello world.", args)
}
