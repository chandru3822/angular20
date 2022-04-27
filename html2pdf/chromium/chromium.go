package chromium

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/chromedp/cdproto/emulation"
	"github.com/chromedp/cdproto/network"
	"github.com/chromedp/cdproto/page"
	"github.com/chromedp/cdproto/runtime"
	"github.com/chromedp/chromedp"
	"github.com/google/uuid"
	"github.com/labstack/gommon/log"
	"golang.org/x/sync/errgroup"
	"os"
	"sync"
	"time"
)

var (
	activeInstancesCount   float64
	activeInstancesCountMu sync.RWMutex
)

type Metric struct {
	Name        string
	Description string
	Read        func() float64
}

func (m Metric) MarshalJSON() ([]byte, error) {
	return json.Marshal(map[string]interface{}{
		"name":        m.Name,
		"description": m.Description,
		"value":       m.Read(),
	})
}

type Action func(logger *log.Logger) chromedp.Tasks

type Chromium struct {
}

func (chromium Chromium) Screenshot(content string, result *[]byte) error {
	err := do(func(logger *log.Logger) chromedp.Tasks {
		dynamicContentTasks := setDynamicContent(content, logger)
		return append(dynamicContentTasks, chromedp.FullScreenshot(result, 90))
	})
	return err
}

func (chromium Chromium) Convert(content string, result *[]byte) error {
	err := do(func(logger *log.Logger) chromedp.Tasks {
		dynamicContentTasks := setDynamicContent(content, logger)
		return append(dynamicContentTasks, chromedp.ActionFunc(func(ctx context.Context) error {
			buf, _, err := page.PrintToPDF().
				WithPreferCSSPageSize(true).
				WithPrintBackground(false).
				WithDisplayHeaderFooter(true).
				WithHeaderTemplate("").
				WithFooterTemplate(`<span style="font-size: 10px"><span class="pageNumber"></span>/<span class="totalPages"></span></span>`).
				Do(ctx)
			if err != nil {
				return err
			}
			*result = buf
			return nil
		}))
	})

	return err
}

//TODO: convert this to use the prometheus metric stuff
func (chromium Chromium) Metrics() ([]Metric, error) {
	return []Metric{
		{
			Name:        "chromium_active_instances",
			Description: "Current number of active Chromium instances",
			Read: func() float64 {
				activeInstancesCountMu.RLock()
				defer activeInstancesCountMu.RUnlock()
				return activeInstancesCount
			}},
	}, nil
}

//TODO: error handling
func do(action Action) error {
	logger := log.New("browser")

	userProfileDir := fmt.Sprintf("%s/%s", os.TempDir(), uuid.New())

	args := append(chromedp.DefaultExecAllocatorOptions[:],
		chromedp.CombinedOutput(logger.Output()),
		chromedp.NoSandbox,
		chromedp.DisableGPU,
		chromedp.Flag("font-render-hinting", "none"),
		chromedp.Flag("allow-file-access-from-files", true),
		chromedp.UserDataDir(userProfileDir),
	)

	timeoutCtx, cancelFunc := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancelFunc()

	allocatorCtx, cancel := chromedp.NewExecAllocator(timeoutCtx, args...)
	defer cancel()

	ctx, cancel := chromedp.NewContext(allocatorCtx, chromedp.WithDebugf(logger.Debugf))
	defer cancel()

	logger.Print("Starting conversion...")

	activeInstancesCountMu.Lock()
	activeInstancesCount += 1
	activeInstancesCountMu.Unlock()

	if err := chromedp.Run(ctx, action(logger)); err != nil {
		return err
	}

	activeInstancesCountMu.Lock()
	activeInstancesCount -= 1
	activeInstancesCountMu.Unlock()

	logger.Print("Finished conversion...")

	// Always remove the user profile directory created by Chromium.
	go func() {
		logger.Debug(fmt.Sprintf("remove user profile directory '%s'", userProfileDir))

		err := os.RemoveAll(userProfileDir)
		if err != nil {
			logger.Error(fmt.Sprintf("remove user profile directory: %s", err))
		}
	}()

	return nil
}

func setDynamicContent(content string, logger *log.Logger) chromedp.Tasks {
	return chromedp.Tasks{
		network.Enable(),
		runtime.Enable(),
		chromedp.ActionFunc(func(ctx context.Context) error {

			logger.Print("Navigate to page...")
			_, _, _, err := page.Navigate(`about:blank`).Do(ctx)
			if err != nil {
				return fmt.Errorf("navigate to '%s' : %w", "url", err)
			}
			logger.Print("Finished navigating to page...")

			frameTree, err := page.GetFrameTree().Do(ctx)
			if err != nil {
				return err
			}

			err = page.SetDocumentContent(frameTree.Frame.ID, content).Do(ctx)
			if err != nil {
				return fmt.Errorf("unable to set document content: %w", err)
			}

			err = runBatch(
				ctx,
				waitForEventNetworkIdle(ctx, logger),
			)
			if err == nil {
				return nil
			}
			return fmt.Errorf("wait for events: %w", err)
		}),
		chromedp.ActionFunc(func(ctx context.Context) error {
			media := emulation.SetEmulatedMedia()
			err := media.WithMedia("print").Do(ctx)
			if err == nil {
				return nil
			}
			return fmt.Errorf("emulate media type 'print': %w", err)
		}),
		chromedp.ActionFunc(func(ctx context.Context) error {
			// See:
			// https://github.com/gotenberg/gotenberg/issues/354
			// https://github.com/puppeteer/puppeteer/issues/2685
			// https://github.com/chromedp/chromedp/issues/520
			script := `
(() => {
	const css = 'html { -webkit-print-color-adjust: exact !important; }';
	const style = document.createElement('style');
	style.type = 'text/css';
	style.appendChild(document.createTextNode(css));
	document.head.appendChild(style);
})();
`
			evaluate := chromedp.Evaluate(script, nil)
			err := evaluate.Do(ctx)

			if err == nil {
				return nil
			}

			return fmt.Errorf("add CSS for exact colors: %w", err)
		}),
	}
}

// waitForEventNetworkIdle waits until the event networkIdle is fired or the context timeout.
func waitForEventNetworkIdle(ctx context.Context, logger *log.Logger) func() error {
	return func() error {
		ch := make(chan struct{})
		cctx, cancel := context.WithCancel(ctx)
		chromedp.ListenTarget(cctx, func(ev interface{}) {
			switch e := ev.(type) {
			case *page.EventLifecycleEvent:
				if e.Name == "networkIdle" {
					cancel()
					close(ch)
				}
			}
		})

		select {
		case <-ch:
			logger.Debug("event networkIdle fired")
			return nil
		case <-ctx.Done():
			return fmt.Errorf("wait for event networkIdle: %w", ctx.Err())
		}
	}
}

// runBatch runs all functions simultaneously and waits until all of them are
// completed or an error is encountered.
func runBatch(ctx context.Context, fn ...func() error) error {
	eg, _ := errgroup.WithContext(ctx)

	for _, f := range fn {
		eg.Go(f)
	}

	return eg.Wait()
}
