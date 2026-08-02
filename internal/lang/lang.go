// Package lang provides the shared enable-check for the language modules:
// a language module runs only when its name appears in config.languages.
package lang

import "github.com/omamac/omamac/internal/config"

// Enabled reports whether lang appears in cfg.Languages (or "*"/"all").
func Enabled(cfg *config.Config, lang string) bool {
	for _, l := range cfg.Languages {
		if l == lang || l == "*" || l == "all" {
			return true
		}
	}
	return false
}
