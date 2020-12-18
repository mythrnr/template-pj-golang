package main

import (
	"os"

	"github.com/mythrnr/template-pj-golang/internal/app"
)

func main() {
	c := app.NewCLI()
	c.Execute(os.Args)
}
