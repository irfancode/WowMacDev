# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-03-24

### Added
- Comprehensive export for 12+ package managers and sources
- Interactive installation with progress tracking
- GitHub sync functionality
- Configuration backup (gitconfig, shell configs)
- Docker images export
- VS Code extensions export
- Log files for troubleshooting
- Timestamp-based export files
- Quick Start guide
- Troubleshooting documentation
- Customization guide

### Improved
- Better error handling and logging
- Skip already-installed packages
- Individual package installation tracking
- Clearer console output with headers
- Comment support in export files
- File verification before operations

### Commands
- `export` - Export all apps
- `install` - Install from exports
- `update` - Update and install
- `sync` - Export and push to GitHub
- `list` - Show export summary
- `verify` - Check export files
- `clean` - Remove export files

## [1.0.0] - Initial Release

### Added
- Homebrew formula export
- Homebrew cask export
- App Store apps export
- npm packages export
- Basic installation script
