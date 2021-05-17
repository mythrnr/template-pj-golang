package app

import (
	"fmt"

	myproject "github.com/mythrnr/template-pj-golang"
	"github.com/mythrnr/template-pj-golang/pkg/cli"
)

type cliApp struct{}

var _ cli.CLI = (*cliApp)(nil)

func NewCLI() cli.CLI {
	return &cliApp{}
}

// nolint:forbidigo
func (c *cliApp) Execute(args []string) {
	fmt.Println("[CLI] Hello world.", args)
	fmt.Println("[CLI] Version", myproject.Version)
	fmt.Println("[CLI] Revision", myproject.Revision)
}
