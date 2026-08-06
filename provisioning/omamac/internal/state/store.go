// Package state implements an append-only journal recording every mutation
// omamac performs. It powers idempotency checks, `omamac uninstall` rollback
// and `omamac doctor`/`omamac verify` reporting.
package state

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"
)

// Action is the kind of mutation recorded.
type Action string

// Supported actions.
const (
	ActionInstall Action = "install"
	ActionUpdate  Action = "update"
	ActionRemove  Action = "remove"
	ActionVerify  Action = "verify"
	ActionApply   Action = "apply" // macOS defaults / config file writes
)

// Status is the outcome of a recorded action.
type Status string

// Supported statuses.
const (
	StatusOK      Status = "ok"
	StatusFailed  Status = "failed"
	StatusSkipped Status = "skipped"
	StatusDryRun  Status = "dry-run"
)

// Entry is a single journal line.
type Entry struct {
	ID      string         `json:"id"`
	TS      time.Time      `json:"ts"`
	Action  Action         `json:"action"`
	Module  string         `json:"module"`
	Status  Status         `json:"status"`
	Detail  string         `json:"detail,omitempty"`
	Command string         `json:"command,omitempty"`
	Before  map[string]any `json:"before,omitempty"`
	After   map[string]any `json:"after,omitempty"`
}

// Store is a thread-safe append-only journal backed by a JSONL file.
type Store struct {
	path    string
	mu      sync.Mutex
	entries []Entry

	// DryRun keeps Append in-memory only: entries are visible to the current
	// process but never flushed to disk, so previews leave no trace.
	DryRun bool
}

// Open loads (creating if needed) the journal at path.
func Open(path string) (*Store, error) {
	s := &Store{path: path}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return nil, fmt.Errorf("create state dir: %w", err)
	}
	f, err := os.OpenFile(path, os.O_CREATE|os.O_RDONLY, 0o644)
	if err != nil {
		return nil, fmt.Errorf("open state file: %w", err)
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 0, 1<<20), 1<<20)
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if line == "" {
			continue
		}
		var e Entry
		if err := json.Unmarshal([]byte(line), &e); err != nil {
			// Corrupt lines are ignored rather than fatal; the journal is
			// advisory, and we must stay safe to rerun.
			continue
		}
		s.entries = append(s.entries, e)
	}
	return s, sc.Err()
}

// Path returns the backing file path.
func (s *Store) Path() string { return s.path }

// Reset truncates the journal.
func (s *Store) Reset() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.entries = nil
	return os.WriteFile(s.path, nil, 0o644)
}

// Append records a new entry and appends it to the file.
func (s *Store) Append(e Entry) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if e.ID == "" {
		e.ID = newID()
	}
	if e.TS.IsZero() {
		e.TS = time.Now()
	}
	s.entries = append(s.entries, e)
	if s.DryRun {
		return nil
	}
	return s.flushLocked()
}

func (s *Store) flushLocked() error {
	f, err := os.OpenFile(s.path, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
	if err != nil {
		return err
	}
	defer f.Close()
	enc := json.NewEncoder(f)
	enc.SetEscapeHTML(false)
	return enc.Encode(s.entries[len(s.entries)-1])
}

// All returns all entries in chronological order.
func (s *Store) All() []Entry {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make([]Entry, len(s.entries))
	copy(out, s.entries)
	return out
}

// Reverse returns entries newest-first.
func (s *Store) Reverse() []Entry {
	all := s.All()
	for i, j := 0, len(all)-1; i < j; i, j = i+1, j-1 {
		all[i], all[j] = all[j], all[i]
	}
	return all
}

// ForModule returns entries for a specific module, newest-first.
func (s *Store) ForModule(name string) []Entry {
	var out []Entry
	for _, e := range s.Reverse() {
		if e.Module == name {
			out = append(out, e)
		}
	}
	return out
}

// Last returns the most recent entry for a module and action, if any.
func (s *Store) Last(module string, action Action) (Entry, bool) {
	for _, e := range s.Reverse() {
		if e.Module == module && e.Action == action {
			return e, true
		}
	}
	return Entry{}, false
}

// Installed reports whether the most recent install for a module succeeded.
func (s *Store) Installed(module string) bool {
	e, ok := s.Last(module, ActionInstall)
	return ok && e.Status == StatusOK
}

// Modules returns the sorted set of module names present in the journal.
func (s *Store) Modules() []string {
	seen := map[string]bool{}
	for _, e := range s.entries {
		seen[e.Module] = true
	}
	out := make([]string, 0, len(seen))
	for m := range seen {
		out = append(out, m)
	}
	sort.Strings(out)
	return out
}

func newID() string {
	return fmt.Sprintf("%d-%d", time.Now().UnixNano(), os.Getpid())
}
