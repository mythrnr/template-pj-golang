package http

import (
	"fmt"

	myproject "github.com/mythrnr/template-pj-golang"
	"github.com/mythrnr/template-pj-golang/pkg/http"
)

type srv struct{}

var _ http.Server = (*srv)(nil)

func NewServer() http.Server {
	return &srv{}
}

// nolint:forbidigo
func (s *srv) Start() {
	fmt.Println("[Server] Hello world.")
	fmt.Println("[Server] Version", myproject.Version)
	fmt.Println("[Server] Revision", myproject.Revision)
}
