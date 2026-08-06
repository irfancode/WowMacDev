// Package logging provides structured, human- and JSON-friendly logging for
// the omamac CLI. Human output is written to stderr (so stdout stays clean
// for machine-readable results), colored when attached to a TTY.
package logging

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/mattn/go-isatty"
)

// Level is the severity of a log message.
type Level = slog.Level

// Well-known levels mapped onto slog levels so callers stay slog-compatible.
const (
	LevelDebug = slog.LevelDebug
	LevelInfo  = slog.LevelInfo
	LevelWarn  = slog.LevelWarn
	LevelError = slog.LevelError
)

// Options configures a Logger.
type Options struct {
	// Level is the minimum severity to emit.
	Level slog.Level
	// JSON enables machine-readable JSONL output instead of the human format.
	JSON bool
	// Color is one of "auto", "always", "never".
	Color string
	// Output is where log lines are written. Defaults to stderr.
	Output io.Writer
	// File, if set, receives a copy of every log line.
	File string
	// DisableTime omits timestamps (useful for tests and CI).
	DisableTime bool
}

// Logger is a thin wrapper around slog with convenience methods used across
// omamac: Step, Success and Fail for the human flow, plus structured With.
type Logger struct {
	l     *slog.Logger
	w     io.Writer
	close func() error
	mu    sync.Mutex
}

// New builds a Logger from Options.
func New(opts Options) (*Logger, error) {
	w := opts.Output
	if w == nil {
		w = os.Stderr
	}

	var file *os.File
	if opts.File != "" {
		if err := os.MkdirAll(filepath.Dir(opts.File), 0o755); err != nil {
			return nil, fmt.Errorf("create log dir: %w", err)
		}
		f, err := os.OpenFile(opts.File, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
		if err != nil {
			return nil, fmt.Errorf("open log file: %w", err)
		}
		file = f
		w = io.MultiWriter(w, f)
	}

	color := opts.Color
	if color == "" {
		color = "auto"
	}
	useColor := color == "always"
	if color == "auto" {
		f, ok := w.(*os.File)
		useColor = ok && isatty.IsTerminal(f.Fd()) && os.Getenv("NO_COLOR") == ""
	}

	var h slog.Handler
	if opts.JSON {
		wo := &slog.HandlerOptions{Level: opts.Level}
		if opts.DisableTime {
			wo.ReplaceAttr = dropTimeAttr
		}
		h = slog.NewJSONHandler(w, wo)
	} else {
		h = &consoleHandler{w: w, level: opts.Level, color: useColor, noTime: opts.DisableTime}
	}

	return &Logger{
		l: slog.New(h),
		w: w,
		close: func() error {
			if file != nil {
				return file.Close()
			}
			return nil
		},
	}, nil
}

func dropTimeAttr(_ []string, a slog.Attr) slog.Attr {
	if a.Key == slog.TimeKey {
		return slog.Attr{}
	}
	return a
}

// Close flushes and closes any backing file.
func (l *Logger) Close() error {
	if l.close == nil {
		return nil
	}
	return l.close()
}

// L exposes the underlying slog.Logger for advanced use.
func (l *Logger) L() *slog.Logger { return l.l }

// With returns a derived logger carrying extra structured attributes.
func (l *Logger) With(args ...any) *Logger {
	return &Logger{l: l.l.With(args...), w: l.w, close: nil}
}

// Debug logs a message at debug level.
func (l *Logger) Debug(msg string) { l.l.Debug(msg) }

// Debugf logs a formatted message at debug level.
func (l *Logger) Debugf(format string, args ...any) { l.l.Debug(fmt.Sprintf(format, args...)) }

// Info logs a message at info level.
func (l *Logger) Info(msg string) { l.l.Info(msg) }

// Infof logs a formatted message at info level.
func (l *Logger) Infof(format string, args ...any) { l.l.Info(fmt.Sprintf(format, args...)) }

// Warn logs a message at warn level.
func (l *Logger) Warn(msg string) { l.l.Warn(msg) }

// Warnf logs a formatted message at warn level.
func (l *Logger) Warnf(format string, args ...any) { l.l.Warn(fmt.Sprintf(format, args...)) }

// Error logs a message at error level.
func (l *Logger) Error(msg string) { l.l.Error(msg) }

// Errorf logs a formatted message at error level.
func (l *Logger) Errorf(format string, args ...any) { l.l.Error(fmt.Sprintf(format, args...)) }

// Step reports an in-progress action with a leading arrow marker.
func (l *Logger) Step(msg string) { l.l.Info("\u25b8 " + msg) }

// Stepf reports a formatted in-progress action with a leading arrow marker.
func (l *Logger) Stepf(format string, args ...any) {
	l.l.Info("\u25b8 " + fmt.Sprintf(format, args...))
}

// Success reports a completed action with a checkmark marker.
func (l *Logger) Success(msg string) { l.l.Info("\u2713 " + msg) }

// Successf reports a formatted completed action with a checkmark marker.
func (l *Logger) Successf(format string, args ...any) {
	l.l.Info("\u2713 " + fmt.Sprintf(format, args...))
}

// Fail reports a failed action with a cross marker.
func (l *Logger) Fail(msg string) { l.l.Error("\u2717 " + msg) }

// Failf reports a formatted failed action with a cross marker.
func (l *Logger) Failf(format string, args ...any) {
	l.l.Error("\u2717 " + fmt.Sprintf(format, args...))
}

// Section prints a visually separated header line to the log output.
func (l *Logger) Section(title string) {
	line := strings.Repeat("\u2500", 24)
	l.mu.Lock()
	defer l.mu.Unlock()
	fmt.Fprintf(l.w, "%s %s %s\n", dim(line), bold(title), dim(line))
}

// Raw writes text directly to the log output with no formatting. It is used
// for rendering results (tables, YAML) and is safe to call even in JSON mode.
func (l *Logger) Raw(format string, args ...any) {
	l.mu.Lock()
	defer l.mu.Unlock()
	fmt.Fprintf(l.w, format+"\n", args...)
}

// Writer returns an io.Writer that routes writes through the logger at the
// given level (used to stream subprocess output).
func (l *Logger) Writer(level slog.Level) io.Writer {
	return &writer{log: l, level: level}
}

type writer struct {
	log   *Logger
	level slog.Level
	buf   strings.Builder
}

func (w *writer) Write(p []byte) (int, error) {
	n := len(p)
	w.buf.Write(p)
	for {
		s := w.buf.String()
		idx := strings.IndexByte(s, '\n')
		if idx < 0 {
			break
		}
		line := s[:idx]
		w.buf.Reset()
		w.buf.WriteString(s[idx+1:])
		line = strings.TrimRight(line, "\r")
		if strings.TrimSpace(line) != "" {
			w.log.l.Log(context.TODO(), w.level, line)
		}
	}
	return n, nil
}

func dim(s string) string  { return "\x1b[2m" + s + "\x1b[0m" }
func bold(s string) string { return "\x1b[1m" + s + "\x1b[0m" }

// consoleHandler formats log records as colored, human-readable lines.
type consoleHandler struct {
	mu     sync.Mutex
	w      io.Writer
	level  slog.Level
	color  bool
	noTime bool
}

func (h *consoleHandler) Enabled(_ context.Context, level slog.Level) bool {
	return level >= h.level
}

func (h *consoleHandler) Handle(_ context.Context, rec slog.Record) error {
	h.mu.Lock()
	defer h.mu.Unlock()

	var b strings.Builder
	if !h.noTime {
		b.WriteString(dim(rec.Time.Format(time.StampMilli)) + " ")
	}
	b.WriteString(levelTag(rec.Level, h.color) + rec.Message)
	rec.Attrs(func(a slog.Attr) bool {
		if a.Key == slog.MessageKey || a.Key == slog.TimeKey || a.Key == slog.LevelKey {
			return true
		}
		fmt.Fprintf(&b, " %s=%v", a.Key, a.Value)
		return true
	})
	b.WriteString("\n")
	_, err := io.WriteString(h.w, b.String())
	return err
}

func (h *consoleHandler) WithAttrs(_ []slog.Attr) slog.Handler {
	return h
}

func (h *consoleHandler) WithGroup(string) slog.Handler { return h }

func levelTag(l slog.Level, color bool) string {
	var s string
	switch {
	case l >= LevelError:
		s = "ERR"
		if color {
			s = red(s)
		}
	case l >= LevelWarn:
		s = "WRN"
		if color {
			s = yellow(s)
		}
	case l >= LevelInfo:
		s = "INF"
		if color {
			s = blue(s)
		}
	default:
		s = "DBG"
		if color {
			s = gray(s)
		}
	}
	return s + " "
}

func red(s string) string    { return "\x1b[31m" + s + "\x1b[0m" }
func yellow(s string) string { return "\x1b[33m" + s + "\x1b[0m" }
func blue(s string) string   { return "\x1b[34m" + s + "\x1b[0m" }
func gray(s string) string   { return "\x1b[90m" + s + "\x1b[0m" }
