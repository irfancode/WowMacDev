// Package tui renders lightweight terminal progress: a determinate progress
// bar during installs and a spinner during updates. It degrades gracefully to
// plain line output when stdout is not a TTY, in JSON mode, or when
// OMAMAC_NO_TUI is set.
package tui

import (
	"fmt"
	"io"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/mattn/go-isatty"
)

const maxWidth = 60

var spinnerFrames = []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}

// Progress renders activity on a single line that is overwritten in place.
type Progress struct {
	mu      sync.Mutex
	w       io.Writer
	tty     bool
	total   int
	done    int
	label   string
	tick    *time.Ticker
	stopCh  chan struct{}
	started bool
}

// New returns a Progress writing to w. Pass a real *os.File to enable
// in-place rendering; otherwise output is line-oriented.
func New(w io.Writer) *Progress {
	tty := false
	if f, ok := w.(*os.File); ok {
		tty = isatty.IsTerminal(f.Fd())
	}
	if os.Getenv("OMAMAC_NO_TUI") != "" {
		tty = false
	}
	return &Progress{w: w, tty: tty, stopCh: make(chan struct{})}
}

// Start begins a determinate phase with the given total steps.
func (p *Progress) Start(total int) {
	p.mu.Lock()
	p.total = total
	p.done = 0
	if !p.started {
		p.started = true
		p.tick = time.NewTicker(100 * time.Millisecond)
		go p.animate()
	}
	p.mu.Unlock()
}

// Step advances the determinate progress bar to the next step.
func (p *Progress) Step(label string) {
	p.mu.Lock()
	p.done++
	if p.done > p.total {
		p.done = p.total
	}
	p.label = label
	p.mu.Unlock()
	p.draw()
}

// Update sets the current label without advancing (indeterminate mode).
func (p *Progress) Update(label string) {
	p.mu.Lock()
	p.label = label
	p.mu.Unlock()
	p.draw()
}

// Finish clears the line and writes a final status line. ok marks success.
func (p *Progress) Finish(label string, ok bool) {
	if p.tty {
		p.clear()
	}
	mark := "✓"
	if !ok {
		mark = "✗"
	}
	fmt.Fprintf(p.w, " %s %s\n", mark, label)
	p.mu.Lock()
	if p.tick != nil {
		p.tick.Stop()
	}
	close(p.stopCh)
	p.started = false
	p.mu.Unlock()
}

func (p *Progress) animate() {
	i := 0
	for {
		select {
		case <-p.stopCh:
			return
		case <-p.tick.C:
			i++
			p.mu.Lock()
			label := p.label
			p.mu.Unlock()
			if p.tty {
				fmt.Fprintf(p.w, "\r\x1b[2K %s %s", spinnerFrames[i%len(spinnerFrames)], label)
			}
		}
	}
}

func (p *Progress) draw() {
	p.mu.Lock()
	label := p.label
	done, total := p.done, p.total
	p.mu.Unlock()

	if !p.tty {
		fmt.Fprintf(p.w, " • %s\n", label)
		return
	}
	frac := 0.0
	if total > 0 {
		frac = float64(done) / float64(total)
	}
	bar := progressBar(frac)
	fmt.Fprintf(p.w, "\r\x1b[2K %s [%s] %d/%d\n", bar, label, done, total)
}

func progressBar(frac float64) string {
	w := int(frac * maxWidth)
	if w > maxWidth {
		w = maxWidth
	}
	filled := strings.Repeat("█", w)
	rest := strings.Repeat("░", maxWidth-w)
	return filled + rest
}

func (p *Progress) clear() {
	fmt.Fprintf(p.w, "\r\x1b[2K")
}
