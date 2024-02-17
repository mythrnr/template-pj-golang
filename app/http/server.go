package http

import (
	"fmt"
	"net/http"

	"github.com/julienschmidt/httprouter"
	"github.com/mythrnr/template-pj-golang/config"
)

type Server struct {
	c *config.Config
}

//nolint:gosec
func (s *Server) Start() {
	_ = http.ListenAndServe(fmt.Sprintf(":%d", s.c.App.ListenPort), s.setup())
}

func (s *Server) setup() *httprouter.Router {
	router := httprouter.New()

	router.GET("/ping", func(
		rw http.ResponseWriter, _ *http.Request, _ httprouter.Params,
	) {
		_, _ = rw.Write([]byte("ok"))
		rw.WriteHeader(http.StatusOK)
	})

	return router
}

func NewServer(c *config.Config) *Server {
	return &Server{c: c}
}
