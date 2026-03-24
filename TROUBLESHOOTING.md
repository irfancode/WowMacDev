# Troubleshooting Guide

Common issues and solutions for Mac App Sync.

## Installation Issues

### Homebrew Not Found

**Error:**
```
./mac-app-sync.sh: line X: brew: command not found
```

**Solution:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# For Apple Silicon Macs, add to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

---

### Xcode Command Line Tools Missing

**Error:**
```
xcode-select: error: command line tools are not installed
```

**Solution:**
```bash
# Install Xcode CLI tools
xcode-select --install

# Follow the GUI prompt to complete installation
```

---

### Git Not Found

**Error:**
```
./mac-app-sync.sh: git: command not found
```

**Solution:**
```bash
# Install Git via Homebrew
brew install git

# Or use Xcode CLI tools (includes Git)
xcode-select --install
```

---

## Export Issues

### Empty Export Files

**Problem:** Exported files are empty or contain no apps.

**Solutions:**

1. **Homebrew not exporting:**
   ```bash
   # Verify Homebrew is working
   brew doctor
   
   # Check if you have packages
   brew list
   ```

2. **npm not exporting:**
   ```bash
   # Check if you have global packages
   npm list -g --depth=0
   ```

3. **App Store apps not exporting:**
   ```bash
   # Sign in to App Store CLI
   mas signin
   
   # Check account
   mas account
   ```

---

### Permission Denied

**Error:**
```
Permission denied: exports/homebrew_formulas.txt
```

**Solution:**
```bash
chmod 755 *.sh
mkdir -p exports configs
chmod 755 exports configs
```

---

## Installation (New Mac) Issues

### Installation Hangs on Homebrew

**Problem:** Homebrew installation seems stuck.

**Solution:**
```bash
# Check if download is in progress
# Try with verbose mode:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" -v

# Or install without prompting:
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

### Package Installation Fails

**Problem:** Individual packages fail to install.

**Common Causes & Solutions:**

1. **Package renamed or removed:**
   ```bash
   # Search for the package
   brew search <package-name>
   
   # Check if name changed
   brew info <package-name>
   ```

2. **Requires different macOS version:**
   - Some packages require newer macOS
   - Check package requirements with `brew info <package>`

3. **Disk space issues:**
   ```bash
   # Check available space
   df -h /
   
   # Clean up Homebrew cache
   brew cleanup -s
   ```

4. **Network issues:**
   - Check internet connection
   - Try using a VPN if behind firewall

---

### mas CLI Sign-in Fails

**Error:**
```
Error: Could not sign in to Mac App Store
```

**Solutions:**
```bash
# Method 1: Use GUI
# Open App Store → Sign In → Complete authentication

# Method 2: Check mas status
mas signin

# Method 3: If 2FA enabled, might need app-specific password
# Generate at: https://appleid.apple.com → Security → App-Specific Passwords
```

---

### VS Code Extensions Not Installing

**Error:**
```
Extension xxx not found
```

**Solutions:**
1. **VS Code CLI not installed:**
   ```bash
   # In VS Code, press Cmd+Shift+P
   # Type: "Shell Command: Install 'code' command in PATH"
   # Press Enter
   ```

2. **Extension renamed or removed:**
   ```bash
   # Search for extension
   code --list-extensions | grep <search-term>
   
   # Check extension page on marketplace
   ```

---

### Rosetta 2 Required (Apple Silicon)

**Problem:** Some Intel apps fail on Apple Silicon Macs.

**Solution:**
```bash
# Install Rosetta 2
softwareupdate --install-rosetta

# Or allow automatic installation when prompted
```

---

## GitHub Sync Issues

### Not Logged In to GitHub

**Error:**
```
Error: You need to be authenticated to perform this action
```

**Solution:**
```bash
# Install GitHub CLI
brew install gh

# Login
gh auth login

# Choose HTTPS, Yes to git credentials, Login with web browser
```

---

### Repository Not Found

**Error:**
```
Error: Repository not found
```

**Solutions:**
1. **Repository doesn't exist:**
   ```bash
   # Create new repo
   gh repo create mac-app-sync --public --source=. --push
   ```

2. **Wrong remote URL:**
   ```bash
   # Check current remote
   git remote -v
   
   # Update if needed
   git remote set-url origin https://github.com/USERNAME/mac-app-sync.git
   ```

---

### Push Fails

**Error:**
```
error: failed to push some refs
```

**Solutions:**
```bash
# Fetch and merge first
git fetch origin
git merge origin/main --no-edit

# Or force push (use carefully)
git push --force origin main
```

---

## Verification Issues

### Verify Shows Missing Files

**Problem:** `./mac-app-sync.sh verify` shows missing files.

**Solution:**
```bash
# Re-run export
./mac-app-sync.sh export

# Check exports directory
ls -la exports/

# Verify files are created
cat exports/homebrew_formulas.txt
```

---

## Performance Issues

### Export Takes Too Long

**Possible Causes:**
- Large number of Docker images
- Slow network for some API calls
- Many npm/yarn packages

**Solutions:**
- Edit `export_apps.sh` to skip slow sections
- Remove `docker_images.txt` if not needed
- Use `brew install --quiet` flags

---

## Manual Recovery

If scripts fail completely, here's how to do it manually:

### Manual Homebrew Export
```bash
brew list --formula > homebrew_formulas.txt
brew list --cask > homebrew_casks.txt
```

### Manual Homebrew Install
```bash
# Install all formulae
brew install $(cat homebrew_formulas.txt)

# Install all casks
brew install --cask $(cat homebrew_casks.txt)
```

### Manual npm Export
```bash
npm list -g --depth=0 --json | jq -r '.dependencies | keys[]' > npm_packages.txt
```

### Manual npm Install
```bash
while read pkg; do npm install -g "$pkg"; done < npm_packages.txt
```

---

## Getting Help

If you're still stuck:

1. **Check the log files:**
   ```bash
   cat exports/export_log_*.txt
   cat exports/install_log_*.txt
   ```

2. **Run with verbose output:**
   ```bash
   bash -x ./mac-app-sync.sh export 2>&1 | less
   ```

3. **Search for solutions:**
   - [Homebrew Issues](https://github.com/Homebrew/brew/issues)
   - [mas Issues](https://github.com/mas-cli/mas/issues)

4. **Open an issue on GitHub:**
   - Include log files
   - Include macOS version
   - Include output of `brew doctor`
