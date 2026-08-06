package omamac

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// TestStaleRepoSlugAbsent guards against re-introducing the previous owner
// slug for this repository, which once made the bootstrap one-liner 404.
// The stale strings are built dynamically so this test does not match itself.
func TestStaleRepoSlugAbsent(t *testing.T) {
	staleSlug := "github.com/" + "omamac" + "/" + "omamac"
	staleBare := "omamac" + "/" + "omamac"
	staleDomain := "omamac" + ".dev"
	skipDirs := map[string]bool{
		"bin":  true,
		"dist": true,
		".git": true,
	}
	err := filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			if skipDirs[path] {
				return filepath.SkipDir
			}
			return nil
		}
		if strings.HasPrefix(info.Name(), ".") {
			return nil
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		content := string(data)
		if strings.Contains(content, staleSlug) || strings.Contains(content, staleBare) || strings.Contains(content, staleDomain) {
			t.Errorf("%s: stale owner slug or dead domain reference (repo lives under github.com/irfancode/omamac)", path)
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}

// TestBootstrapURLsMatchRemote ensures every user-facing URL — the install.sh
// default repo and the README/docs one-liners — points at the real GitHub
// repository, derived from the origin remote so this stays correct on any fork.
func TestBootstrapURLsMatchRemote(t *testing.T) {
	out, err := exec.Command("git", "remote", "get-url", "origin").Output()
	if err != nil {
		t.Skip("no origin remote configured (e.g. source tarball)")
	}
	remote := strings.TrimSpace(string(out))
	remote = strings.TrimSuffix(remote, ".git")
	remote = strings.TrimPrefix(remote, "https://github.com/")
	remote = strings.TrimPrefix(remote, "git@github.com:")
	if !strings.Contains(remote, "/") {
		t.Skipf("unexpected origin remote %q", remote)
	}

	installSh, err := os.ReadFile("install.sh")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(installSh), `OMAMAC_REPO="${OMAMAC_REPO:-`+remote+`}"`) {
		t.Errorf("install.sh OMAMAC_REPO default does not match origin remote %q", remote)
	}

	for _, path := range []string{"README.md", "docs/getting-started.md", "docs/blog-post.md"} {
		data, err := os.ReadFile(path)
		if err != nil {
			t.Fatal(err)
		}
		content := string(data)
		if !strings.Contains(content, "github.com/"+remote) && !strings.Contains(content, "raw.githubusercontent.com/"+remote) {
			t.Errorf("%s does not reference the repo github.com/%s", path, remote)
		}
	}
}
