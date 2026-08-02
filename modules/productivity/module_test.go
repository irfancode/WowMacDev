package productivitymodule

import (
	"reflect"
	"testing"

	"github.com/omamac/omamac/internal/config"
)

func TestSelected(t *testing.T) {
	cfg := &config.Config{Productivity: config.ProductivityConfig{
		Raycast:   map[string]any{"enable": true},
		Rectangle: map[string]any{"enable": false},
		HiddenBar: map[string]any{"enable": true},
		Stats:     map[string]any{},
	}}
	want := []string{"raycast", "hiddenbar"}
	if got := selected(cfg); !reflect.DeepEqual(got, want) {
		t.Errorf("selected = %v, want %v", got, want)
	}
}
