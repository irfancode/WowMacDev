package state

import (
	"os"
	"path/filepath"
	"testing"
)

func TestAppendAndRead(t *testing.T) {
	p := filepath.Join(t.TempDir(), "state.jsonl")
	s, err := Open(p)
	if err != nil {
		t.Fatal(err)
	}
	if err := s.Append(Entry{Action: ActionInstall, Module: "homebrew", Status: StatusOK, Detail: "git"}); err != nil {
		t.Fatal(err)
	}
	if err := s.Append(Entry{Action: ActionInstall, Module: "homebrew", Status: StatusOK, Detail: "gh"}); err != nil {
		t.Fatal(err)
	}

	s2, err := Open(p)
	if err != nil {
		t.Fatal(err)
	}
	all := s2.All()
	if len(all) != 2 {
		t.Fatalf("entries = %d, want 2", len(all))
	}
	if all[0].Module != "homebrew" || all[0].Status != StatusOK {
		t.Errorf("entry[0] = %+v", all[0])
	}
}

func TestDryRunAppendNotPersisted(t *testing.T) {
	p := filepath.Join(t.TempDir(), "state.jsonl")
	s, err := Open(p)
	if err != nil {
		t.Fatal(err)
	}
	if err := s.Append(Entry{Action: ActionInstall, Module: "homebrew", Status: StatusOK}); err != nil {
		t.Fatal(err)
	}

	// A dry-run store must keep entries in-memory but never flush them.
	dry := s
	dry.DryRun = true
	if err := dry.Append(Entry{Action: ActionRemove, Module: "shell", Status: StatusDryRun}); err != nil {
		t.Fatal(err)
	}
	if got := len(dry.All()); got != 2 {
		t.Fatalf("dry-run store in-memory entries = %d, want 2", got)
	}

	reopened, err := Open(p)
	if err != nil {
		t.Fatal(err)
	}
	if got := len(reopened.All()); got != 1 {
		t.Fatalf("persisted entries after dry-run append = %d, want 1", got)
	}
}

func TestReverseAndLast(t *testing.T) {
	p := filepath.Join(t.TempDir(), "state.jsonl")
	s, _ := Open(p)
	s.Append(Entry{Action: ActionInstall, Module: "m", Status: StatusOK})
	s.Append(Entry{Action: ActionInstall, Module: "m", Status: StatusFailed})

	rev := s.Reverse()
	if len(rev) != 2 || rev[0].Status != StatusFailed {
		t.Errorf("reverse order wrong: %+v", rev)
	}
	last, ok := s.Last("m", ActionInstall)
	if !ok || last.Status != StatusFailed {
		t.Errorf("Last = %+v, %v", last, ok)
	}
	if s.Installed("m") {
		t.Error("Installed should be false when last install failed")
	}
}

func TestCorruptLineIgnored(t *testing.T) {
	p := filepath.Join(t.TempDir(), "state.jsonl")
	if err := os.WriteFile(p, []byte("{not json}\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	s, err := Open(p)
	if err != nil {
		t.Fatal(err)
	}
	if len(s.All()) != 0 {
		t.Errorf("corrupt lines should be skipped, got %d", len(s.All()))
	}
	// valid append after corrupt line still works
	if err := s.Append(Entry{Module: "x", Action: ActionApply, Status: StatusOK}); err != nil {
		t.Fatal(err)
	}
	if len(s.All()) != 1 {
		t.Errorf("entries = %d, want 1", len(s.All()))
	}
}

func TestForModuleAndModules(t *testing.T) {
	s, _ := Open(filepath.Join(t.TempDir(), "s.jsonl"))
	s.Append(Entry{Module: "a", Action: ActionInstall, Status: StatusOK})
	s.Append(Entry{Module: "b", Action: ActionInstall, Status: StatusOK})
	s.Append(Entry{Module: "a", Action: ActionUpdate, Status: StatusOK})

	ms := s.Modules()
	if len(ms) != 2 || ms[0] != "a" || ms[1] != "b" {
		t.Errorf("Modules = %v", ms)
	}
	fa := s.ForModule("a")
	if len(fa) != 2 || fa[0].Action != ActionUpdate {
		t.Errorf("ForModule(a) = %+v", fa)
	}
}
