package app

import (
	"fmt"

	"github.com/mythrnr/template-pj-golang/pkg/http"
)

type srv struct{}

var _ http.Server = (*srv)(nil)

func NewServer() http.Server {
	return &srv{}
}

func (s *srv) Start() {
	fmt.Println("[Server] Hello world.")
}
