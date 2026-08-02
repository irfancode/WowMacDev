// Package fsutil provides small, safe filesystem helpers used by modules for
// writing configuration files, appending managed blocks and managing
// symlinks.
package fsutil

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// WriteFile creates parent directories and writes content with the given
// permission, in a dry-run-aware way when dryRun is set (logging only).
func WriteFile(path, content string, perm os.FileMode, dryRun bool) error {
	if dryRun {
		return nil
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return fmt.Errorf("create dir for %s: %w", path, err)
	}
	if err := os.WriteFile(path, []byte(content), perm); err != nil {
		return fmt.Errorf("write %s: %w", path, err)
	}
	return nil
}

// WriteFileIfChanged only writes when content differs, keeping mtimes stable
// and re-runs cheap.
func WriteFileIfChanged(path, content string, perm os.FileMode) (bool, error) {
	existing, err := os.ReadFile(path)
	if err == nil && string(existing) == content {
		return false, nil
	}
	if err := WriteFile(path, content, perm, false); err != nil {
		return false, err
	}
	return true, nil
}

// AppendBlock appends a marked block to a file only if the opening marker is
// not already present, preserving any user content around it.
func AppendBlock(path, marker, block string, dryRun bool) error {
	if data, err := os.ReadFile(path); err == nil {
		if strings.Contains(string(data), marker) {
			return nil
		}
	} else if !os.IsNotExist(err) {
		return err
	}
	if dryRun {
		return nil
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	f, err := os.OpenFile(path, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
	if err != nil {
		return err
	}
	defer f.Close()
	if _, err := f.WriteString("\n" + block); err != nil {
		return err
	}
	return nil
}

// ReplaceBlock replaces the managed block delimited by markers, or appends it
// if missing.
func ReplaceBlock(path, marker, block string, dryRun bool) error {
	openMarker := "# >>> omamac " + marker + " >>>"
	closeMarker := "# <<< omamac " + marker + " <<<"
	content, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		content = nil
	} else if err != nil {
		return err
	}
	start := strings.Index(string(content), openMarker)
	end := strings.Index(string(content), closeMarker)
	if start >= 0 && end > start {
		replacement := openMarker + "\n" + block + closeMarker
		newContent := string(content[:start]) + replacement + string(content[end+len(closeMarker):])
		content = []byte(newContent)
	} else {
		content = []byte(string(content) + "\n" + openMarker + "\n" + block + closeMarker + "\n")
	}
	return WriteFile(path, string(content), 0o644, dryRun)
}

// AppendLine adds a line to a file if not already present.
func AppendLine(path, line string, dryRun bool) error {
	if data, err := os.ReadFile(path); err == nil {
		for _, l := range strings.Split(string(data), "\n") {
			if strings.TrimSpace(l) == line {
				return nil
			}
		}
	}
	return AppendBlock(path, line, line, dryRun)
}

// RemoveAll removes a directory tree (or file) in a dry-run-aware way.
func RemoveAll(path string, dryRun bool) error {
	if dryRun {
		return nil
	}
	return os.RemoveAll(path)
}

// Symlink creates a symlink at dst pointing to src, replacing any existing
// symlink but leaving real files untouched.
func Symlink(src, dst string, dryRun bool) (bool, error) {
	if info, err := os.Lstat(dst); err == nil {
		if info.Mode()&os.ModeSymlink != 0 {
			if existing, err := os.Readlink(dst); err == nil && existing == src {
				return false, nil
			}
		} else {
			return false, nil // real file; never clobber
		}
	}
	if dryRun {
		return true, nil
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return false, err
	}
	if err := os.Symlink(src, dst); err != nil {
		return false, err
	}
	return true, nil
}
