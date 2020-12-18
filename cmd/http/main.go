package main

import (
	"github.com/mythrnr/template-pj-golang/internal/app"
)

func main() {
	server := app.NewServer()
	server.Start()
}
