package homebrew

import (
	"fmt"
	"os"
	"testing"

	"github.com/omamac/omamac/internal/logging"
	"github.com/omamac/omamac/internal/util"
)

// fakeBrew returns a Brew whose "brew" binary is a shell stub answering
// `brew list --formula`/`--cask` with the given whitespace-separated names.
// The stub dir is prepended to PATH so brew resolution finds it.
func fakeBrew(t *testing.T, formulae, casks string) *Brew {
	t.Helper()
	dir := t.TempDir()
	stub := dir + "/brew"
	script := fmt.Sprintf(`#!/bin/bash
if [[ "$1" == "list" && "$2" == "--formula" ]]; then
  echo '%s'
fi
if [[ "$1" == "list" && "$2" == "--cask" ]]; then
  echo '%s'
fi
`, formulae, casks)
	if err := os.WriteFile(stub, []byte(script), 0o755); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", dir+":"+os.Getenv("PATH"))
	log, err := logging.New(logging.Options{Level: logging.LevelError, DisableTime: true})
	if err != nil {
		t.Fatal(err)
	}
	r := &util.Runner{Log: log}
	return New(r, log)
}

func TestParseList(t *testing.T) {
	b := fakeBrew(t, "git\njq\n", "arc\n")
	if !b.HasFormula("git") || !b.HasFormula("jq") {
		t.Error("formulae not detected")
	}
	if b.HasFormula("nope") {
		t.Error("unexpected formula")
	}
	if !b.HasCask("arc") {
		t.Error("cask not detected")
	}
}

func TestMissingLists(t *testing.T) {
	b := fakeBrew(t, "", "")
	if got := b.MissingFormulae([]string{"git", "gh"}); len(got) != 2 {
		t.Errorf("MissingFormulae = %v", got)
	}
	if got := b.MissingCasks([]string{"arc"}); len(got) != 1 {
		t.Errorf("MissingCasks = %v", got)
	}
}

func TestEmptyOutputTreatedAsNone(t *testing.T) {
	b := fakeBrew(t, "", "")
	if b.HasFormula("git") {
		t.Error("git should not be detected as installed")
	}
	if b.Formulae() == nil {
		t.Error("Formulae should be empty slice, not nil")
	}
}
