package cli

import "testing"

func TestValidGroup(t *testing.T) {
	cases := []struct {
		name  string
		group string
		want  bool
	}{
		{name: "single lowercase", group: "a", want: true},
		{name: "word", group: "acme", want: true},
		{name: "kebab-case", group: "community-plugins", want: true},
		{name: "digits and underscore", group: "a0_b-1", want: true},
		{name: "empty", group: "", want: false},
		{name: "uppercase", group: "Acme", want: false},
		{name: "space", group: "a b", want: false},
		{name: "dot", group: "a.b", want: false},
		{name: "slash", group: "a/b", want: false},
		{name: "non-ascii", group: "café", want: false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := validGroup(tc.group); got != tc.want {
				t.Errorf("validGroup(%q) = %v, want %v", tc.group, got, tc.want)
			}
		})
	}
}
