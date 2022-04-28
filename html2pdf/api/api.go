package api

import (
	"context"
	"github.com/labstack/echo-contrib/prometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/labstack/gommon/log"
	"net/http"
)

type Route struct {
	Method  string
	Path    string
	Handler echo.HandlerFunc
}

type Api struct {
	port   int
	routes []Route
	srv    *echo.Echo
}

func (api *Api) AddRoute(route Route) {
	api.routes = append(api.routes, route)
}

func (api *Api) Start() error {
	api.srv = echo.New()
	api.srv.HideBanner = true
	api.srv.Logger.SetLevel(log.INFO)
	api.srv.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: 8,
	}))

	//TODO: inject the metrics from the api into prometheus
	p := prometheus.NewPrometheus("echo", nil)
	p.Use(api.srv)

	api.srv.GET("/_health", func(c echo.Context) error {
		return c.JSON(http.StatusOK, "OK")
	})

	for _, route := range api.routes {
		api.srv.Add(route.Method, route.Path, route.Handler)
	}

	go func() {
		if err := api.srv.Start(":1323"); err != nil && err != http.ErrServerClosed {
			api.srv.Logger.Fatal("shutting down the server")
		}
	}()

	return nil

}

func (api Api) Stop(ctx context.Context) error {
	return api.srv.Shutdown(ctx)
}
