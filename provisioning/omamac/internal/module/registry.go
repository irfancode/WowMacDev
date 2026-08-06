package module

import (
	"fmt"
	"sort"
	"strings"

	"github.com/irfancode/omamac/internal/config"
)

// Registry collects built-in modules and discovered plugins.
type Registry struct {
	modules []Module
	byName  map[string]Module
}

// New returns an empty registry.
func New() *Registry {
	return &Registry{byName: map[string]Module{}}
}

// Register adds a built-in module. Later registrations with the same name
// replace earlier ones (enabling tests and overrides).
func (r *Registry) Register(m Module) {
	if m == nil {
		return
	}
	if _, dup := r.byName[m.Name()]; !dup {
		r.modules = append(r.modules, m)
	}
	r.byName[m.Name()] = m
}

// RegisterAll registers many modules at once.
func (r *Registry) RegisterAll(ms ...Module) {
	for _, m := range ms {
		r.Register(m)
	}
}

// All returns modules sorted by priority then name.
func (r *Registry) All() []Module {
	out := make([]Module, len(r.modules))
	copy(out, r.modules)
	sort.SliceStable(out, func(i, j int) bool {
		if out[i].Priority() != out[j].Priority() {
			return out[i].Priority() < out[j].Priority()
		}
		return out[i].Name() < out[j].Name()
	})
	return out
}

// Get returns a module by name.
func (r *Registry) Get(name string) (Module, error) {
	m, ok := r.byName[name]
	if !ok {
		return nil, fmt.Errorf("unknown module %q (run `omamac list`)", name)
	}
	return m, nil
}

// Has reports whether a module name is registered.
func (r *Registry) Has(name string) bool {
	_, ok := r.byName[name]
	return ok
}

// Filter returns modules that should run given config plus CLI include/exclude
// lists. The result is priority-sorted. A module runs only if it passes all
// of: CLI include (if any), config whitelist (if any), module.Enabled, and is
// not excluded by CLI exclude or config disable.
func (r *Registry) Filter(cfg *config.Config, include, exclude []string) ([]Module, error) {
	incl := set(include)
	excl := set(exclude)
	whitelist := set(cfg.Modules)
	disabled := set(cfg.Disable)

	var out []Module
	for _, m := range r.All() {
		name := m.Name()
		if incl.Len() > 0 && !incl.Has(name) {
			continue
		}
		if whitelist.Len() > 0 && !whitelist.Has(name) {
			continue
		}
		if excl.Has(name) || disabled.Has(name) {
			continue
		}
		if !m.Enabled(cfg) {
			continue
		}
		out = append(out, m)
	}

	// Validate requested modules exist.
	for _, n := range append(incl.Keys(), whitelist.Keys()...) {
		if !r.Has(n) {
			return nil, fmt.Errorf("unknown module %q (run `omamac list`)", n)
		}
	}
	return out, nil
}

type stringSet struct{ m map[string]struct{} }

func set(items []string) *stringSet {
	s := &stringSet{m: map[string]struct{}{}}
	for _, i := range items {
		if i = strings.TrimSpace(i); i != "" {
			s.m[i] = struct{}{}
		}
	}
	return s
}

func (s *stringSet) Has(k string) bool { _, ok := s.m[k]; return ok }
func (s *stringSet) Len() int          { return len(s.m) }
func (s *stringSet) Keys() []string {
	out := make([]string, 0, len(s.m))
	for k := range s.m {
		out = append(out, k)
	}
	return out
}
