package logging

import (
	"bytes"
	"encoding/json"
	"log/slog"
	"strings"
	"testing"
)

func TestHumanOutput(t *testing.T) {
	var buf bytes.Buffer
	l, err := New(Options{Output: &buf, Level: LevelInfo, Color: "never", DisableTime: true})
	if err != nil {
		t.Fatal(err)
	}
	l.Info("hello")
	l.Step("working")
	l.Success("done")
	out := buf.String()
	if !strings.Contains(out, "INF hello") {
		t.Errorf("missing info line: %q", out)
	}
	if !strings.Contains(out, "\u25b8 working") {
		t.Errorf("missing step line: %q", out)
	}
	if !strings.Contains(out, "\u2713 done") {
		t.Errorf("missing success line: %q", out)
	}
}

func TestDebugSuppressedAtInfo(t *testing.T) {
	var buf bytes.Buffer
	l, _ := New(Options{Output: &buf, Level: LevelInfo, Color: "never", DisableTime: true})
	l.Debug("hidden")
	if strings.Contains(buf.String(), "hidden") {
		t.Error("debug line should be suppressed at info level")
	}
}

func TestJSONOutput(t *testing.T) {
	var buf bytes.Buffer
	l, _ := New(Options{Output: &buf, Level: LevelInfo, JSON: true, DisableTime: true})
	l.Info("boot")
	var rec map[string]any
	if err := json.Unmarshal(bytes.TrimSpace(buf.Bytes()), &rec); err != nil {
		t.Fatalf("output is not JSON: %v\n%s", err, buf.String())
	}
	if rec["msg"] != "boot" {
		t.Errorf("msg = %v, want boot", rec["msg"])
	}
	if rec["level"] != "INFO" {
		t.Errorf("level = %v, want INFO", rec["level"])
	}
}

func TestWriterStreamsLines(t *testing.T) {
	var buf bytes.Buffer
	l, _ := New(Options{Output: &buf, Level: LevelInfo, Color: "never", DisableTime: true})
	w := l.Writer(slog.LevelInfo)
	_, _ = w.Write([]byte("line one\nline two\n"))
	out := buf.String()
	if !strings.Contains(out, "line one") || !strings.Contains(out, "line two") {
		t.Errorf("streamed lines missing: %q", out)
	}
}
