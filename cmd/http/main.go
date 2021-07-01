package main

import (
	via "github.com/mythrnr/template-pj-golang/internal/builder/http"
)

func main() {
	server := via.NewServer()
	server.Start()
}
