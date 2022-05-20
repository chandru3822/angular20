package main

import (
	"context"
	"fmt"
	"github.com/7oaksgroup/html2pdf/v1/api"
	"github.com/7oaksgroup/html2pdf/v1/chromium"
	"github.com/labstack/echo/v4"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"time"
)

func main() {
	t := api.Api{}
	d := chromium.Chromium{}
	t.AddRoute(api.Route{
		Path:   "/api/convert",
		Method: "POST",
		Handler: func(c echo.Context) error {
			html := c.FormValue("html")

			var ret []byte
			_ = d.Convert(html, &ret)

			contentLength := len(ret)
			c.Response().Header().Set("Content-Length", strconv.Itoa(contentLength))
			return c.Blob(http.StatusOK, "application/pdf", ret)
		},
	})

	t.AddRoute(api.Route{
		Path:   "/api/screenshot",
		Method: "GET",
		Handler: func(c echo.Context) error {
			var ret []byte
			html := ""
			_ = d.Screenshot(html, &ret)
			return c.Blob(http.StatusOK, "image/png", ret)
		},
	})

	t.AddRoute(api.Route{
		Path:   "/api/metrics",
		Method: "GET",
		Handler: func(c echo.Context) error {
			metrics, err := d.Metrics()
			if err != nil {
				return err
			}
			return c.JSON(http.StatusOK, metrics)
		},
	})

	err := t.Start()
	if err != nil {
		fmt.Printf("[FATAL] starting server: %s\n", err)
		os.Exit(1)
	}

	// Wait for interrupt signal to gracefully shutdown the server with a timeout of 5 seconds.
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt)
	<-quit
	gracefulShutdownDuration := 5 * time.Second
	gracefulShutdownCtx, cancel := context.WithTimeout(context.Background(), gracefulShutdownDuration)
	defer cancel()

	fmt.Printf("[SYSTEM] graceful shutdown of %s\n", gracefulShutdownDuration)

	if err := t.Stop(gracefulShutdownCtx); err != nil {
		// todo: handle the error a little better
		fmt.Printf("[FATAL] stopping server: %s\n", err)
	}
}
