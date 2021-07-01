package main

import (
	"os"

	via "github.com/mythrnr/template-pj-golang/internal/builder/cli"
)

func main() {
	c := via.NewCLI()
	c.Execute(os.Args)
}
