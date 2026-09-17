package productivitymodule

import (
	"reflect"
	"testing"

	"github.com/irfancode/omamac/internal/config"
)

func TestSelected(t *testing.T) {
	cfg := &config.Config{Productivity: config.ProductivityConfig{
		Rectangle: map[string]any{"enable": false},
		HiddenBar: map[string]any{"enable": true},
		Stats:     map[string]any{},
	}}
	want := []string{"hiddenbar"}
	if got := selected(cfg); !reflect.DeepEqual(got, want) {
		t.Errorf("selected = %v, want %v", got, want)
	}
}
