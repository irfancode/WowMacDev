package fontsmodule

import (
	"reflect"
	"testing"

	"github.com/omamac/omamac/internal/config"
)

func TestCasksFor(t *testing.T) {
	cfg := &config.Config{Fonts: []string{"JetBrains Mono", "Fira Code", "Hack", "Cascadia Code"}}
	want := []string{"font-jetbrains-mono-nerd-font", "font-fira-code-nerd-font", "font-hack-nerd-font", "font-cascadia-code-nf"}
	if got := CasksFor(cfg); !reflect.DeepEqual(got, want) {
		t.Errorf("CasksFor = %v, want %v", got, want)
	}
}

func TestCasksForSkipsManaged(t *testing.T) {
	cfg := &config.Config{
		Fonts:    []string{"JetBrains Mono", "Hack"},
		Homebrew: config.HomebrewConfig{Casks: []string{"font-hack-nerd-font"}},
	}
	got := CasksFor(cfg)
	if len(got) != 1 || got[0] != "font-jetbrains-mono-nerd-font" {
		t.Errorf("CasksFor with managed font = %v, want only jetbrains", got)
	}
}
