from fastapi import APIRouter, Depends, HTTPException
import subprocess
import json
import os

from app.api.endpoints.auth import get_current_user

router = APIRouter()

def run_command(cmd: list, check: bool = True) -> tuple:
    """Run a shell command and return output"""
    try:
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            check=check
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.CalledProcessError as e:
        return e.returncode, e.stdout, e.stderr
    except FileNotFoundError:
        return -1, "", "Command not found"

@router.get("/check-cli-tools")
async def check_cli_tools(current_user: dict = Depends(get_current_user)):
    """Check if Command Line Tools are installed"""
    # Check for git which is part of CLI tools
    returncode, _, _ = run_command(['which', 'git'], check=False)
    
    # Also check for clang
    clang_installed = False
    if returncode == 0:
        returncode2, _, _ = run_command(['which', 'clang'], check=False)
        clang_installed = returncode2 == 0
    
    is_installed = returncode == 0 and clang_installed
    
    return {
        "installed": is_installed,
        "message": "Command Line Tools are installed" if is_installed else "Command Line Tools are not installed"
    }

@router.post("/install-cli-tools")
async def install_cli_tools(current_user: dict = Depends(get_current_user)):
    """Install Command Line Tools"""
    try:
        # Trigger CLI tools installation
        result = subprocess.run(
            ['xcode-select', '--install'],
            capture_output=True,
            text=True
        )
        
        return {
            "success": True,
            "message": "Command Line Tools installation triggered. Please follow the dialog that appears.",
            "output": result.stdout,
            "error": result.stderr if result.stderr else None
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/check-brew")
async def check_brew(current_user: dict = Depends(get_current_user)):
    """Check if Homebrew is installed"""
    returncode, stdout, _ = run_command(['which', 'brew'], check=False)
    
    is_installed = returncode == 0
    
    brew_info = None
    if is_installed:
        # Get brew version and prefix
        _, version, _ = run_command(['brew', '--version'], check=False)
        _, prefix, _ = run_command(['brew', '--prefix'], check=False)
        
        brew_info = {
            "version": version.strip().split('\n')[0] if version else "Unknown",
            "prefix": prefix.strip() if prefix else "/usr/local",
            "path": stdout.strip()
        }
    
    return {
        "installed": is_installed,
        "info": brew_info,
        "message": "Homebrew is installed" if is_installed else "Homebrew is not installed"
    }

@router.post("/install-brew")
async def install_brew(current_user: dict = Depends(get_current_user)):
    """Install Homebrew"""
    try:
        # Download and run Homebrew installer script
        install_script = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        
        return {
            "success": True,
            "message": "Homebrew installation initiated. Please run the following command in your terminal:",
            "command": install_script,
            "note": "The installation requires manual confirmation and may take several minutes."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/packages")
async def get_brew_packages(current_user: dict = Depends(get_current_user)):
    """Get categorized list of recommended Homebrew packages"""
    
    packages = {
        "essentials": {
            "name": "Essential Tools",
            "description": "Must-have command line tools for every developer",
            "packages": [
                {"name": "git", "description": "Distributed version control system", "installed": False},
                {"name": "wget", "description": "Internet file retriever", "installed": False},
                {"name": "curl", "description": "Tool for transferring data with URLs", "installed": False},
                {"name": "ca-certificates", "description": "Mozilla CA certificate store", "installed": False},
                {"name": "gettext", "description": "GNU internationalization framework", "installed": False},
            ]
        },
        "terminal_enhancements": {
            "name": "Terminal Enhancements",
            "description": "Tools to improve your terminal experience",
            "packages": [
                {"name": "zsh-syntax-highlighting", "description": "Fish-like syntax highlighting for zsh", "installed": False},
                {"name": "zsh-autosuggestions", "description": "Fish-like suggestions for zsh", "installed": False},
                {"name": "powerlevel10k", "description": "A Zsh theme with powerful features", "installed": False},
                {"name": "starship", "description": "The minimal, blazing-fast prompt", "installed": False},
                {"name": "fish", "description": "User-friendly command line shell", "installed": False},
                {"name": "tmux", "description": "Terminal multiplexer", "installed": False},
                {"name": "fzf", "description": "Command line fuzzy finder", "installed": False},
                {"name": "bat", "description": "Cat clone with syntax highlighting", "installed": False},
                {"name": "eza", "description": "Modern replacement for ls", "installed": False},
                {"name": "lsd", "description": "Next-gen ls command", "installed": False},
                {"name": "fd", "description": "Simple, fast alternative to find", "installed": False},
                {"name": "ripgrep", "description": "Line-oriented search tool", "installed": False},
                {"name": "tldr", "description": "Simplified man pages", "installed": False},
                {"name": "htop", "description": "Interactive process viewer", "installed": False},
                {"name": "topgrade", "description": "Upgrade all the things", "installed": False},
            ]
        },
        "development_tools": {
            "name": "Development Tools",
            "description": "Tools for software development",
            "packages": [
                {"name": "neovim", "description": "Hyperextensible Vim-based text editor", "installed": False},
                {"name": "node", "description": "Platform for building JavaScript apps", "installed": False},
                {"name": "nvm", "description": "Node version manager", "installed": False},
                {"name": "python@3.13", "description": "Python 3.13", "installed": False},
                {"name": "pipx", "description": "Execute binaries from Python packages", "installed": False},
                {"name": "pnpm", "description": "Fast, disk space efficient package manager", "installed": False},
                {"name": "yarn", "description": "JavaScript package manager", "installed": False},
                {"name": "lua", "description": "Lua programming language", "installed": False},
                {"name": "luajit", "description": "Just-In-Time Compiler for Lua", "installed": False},
                {"name": "tree-sitter", "description": "Parser generator tool", "installed": False},
                {"name": "sqlite", "description": "Command line interface for SQLite", "installed": False},
            ]
        },
        "kubernetes_cloud": {
            "name": "Kubernetes & Cloud",
            "description": "Tools for container orchestration and cloud",
            "packages": [
                {"name": "kubernetes-cli", "description": "Kubernetes command line tool", "installed": False},
                {"name": "helm", "description": "Kubernetes package manager", "installed": False},
                {"name": "k9s", "description": "Kubernetes CLI to manage clusters", "installed": False},
                {"name": "docker", "description": "Platform for developing applications", "installed": False},
            ]
        },
        "ai_tools": {
            "name": "AI & Productivity",
            "description": "AI-powered and productivity tools",
            "packages": [
                {"name": "aichat", "description": "All-in-one AI CLI tool", "installed": False},
                {"name": "mas", "description": "Mac App Store command line interface", "installed": False},
                {"name": "macos-trash", "description": "Move files to macOS trash", "installed": False},
            ]
        },
        "libraries": {
            "name": "Libraries & Dependencies",
            "description": "Important libraries and dependencies",
            "packages": [
                {"name": "openssl@3", "description": "Cryptography and SSL/TLS toolkit", "installed": False},
                {"name": "readline", "description": "Library for command line editing", "installed": False},
                {"name": "pcre2", "description": "Perl compatible regular expressions", "installed": False},
                {"name": "libgit2", "description": "C library of Git core methods", "installed": False},
                {"name": "libevent", "description": "Asynchronous event notification", "installed": False},
                {"name": "libuv", "description": "Multi-platform support library", "installed": False},
                {"name": "libssh2", "description": "C library implementing SSH2 protocol", "installed": False},
                {"name": "lz4", "description": "Extremely Fast Compression algorithm", "installed": False},
                {"name": "zstd", "description": "Zstandard compression algorithm", "installed": False},
                {"name": "xz", "description": "General-purpose data compression", "installed": False},
                {"name": "brotli", "description": "Generic-purpose lossless compression", "installed": False},
                {"name": "icu4c@76", "description": "C/C++ libraries for Unicode", "installed": False},
            ]
        }
    }
    
    # Check which packages are installed
    try:
        # Get list of installed formulae
        returncode, stdout, _ = run_command(['brew', 'list', '--formula', '-1'], check=False)
        if returncode == 0:
            installed = set(stdout.strip().split('\n'))
            
            # Update installed status
            for category in packages.values():
                for pkg in category["packages"]:
                    pkg["installed"] = pkg["name"] in installed
    except:
        pass
    
    return packages

@router.get("/casks")
async def get_brew_casks(current_user: dict = Depends(get_current_user)):
    """Get categorized list of recommended Homebrew Casks (GUI apps)"""
    
    casks = {
        "development": {
            "name": "Development",
            "description": "Essential development tools and editors",
            "casks": [
                {"name": "visual-studio-code", "description": "Code editor with IDE features", "installed": False},
                {"name": "zed", "description": "High-performance, multiplayer code editor", "installed": False},
                {"name": "docker-desktop", "description": "Containerization platform", "installed": False},
                {"name": "ghostty", "description": "Fast, native terminal emulator", "installed": False},
                {"name": "warp", "description": "Modern, Rust-based terminal", "installed": False},
                {"name": "hyper", "description": "Terminal built on web technologies", "installed": False},
            ]
        },
        "browsers": {
            "name": "Browsers",
            "description": "Web browsers for testing and daily use",
            "casks": [
                {"name": "google-chrome", "description": "Google web browser", "installed": False},
                {"name": "firefox@developer-edition", "description": "Firefox for developers", "installed": False},
                {"name": "floorp", "description": "Firefox-based privacy browser", "installed": False},
                {"name": "librewolf", "description": "Privacy-focused Firefox fork", "installed": False},
                {"name": "thebrowsercompany-dia", "description": "Arc browser by The Browser Company", "installed": False},
                {"name": "zen", "description": "Privacy-focused browser", "installed": False},
            ]
        },
        "productivity": {
            "name": "Productivity",
            "description": "Apps to boost your productivity",
            "casks": [
                {"name": "raycast", "description": "Blazingly fast launcher", "installed": False},
                {"name": "rectangle", "description": "Window management app", "installed": False},
                {"name": "notion", "description": "All-in-one workspace", "installed": False},
                {"name": "readdle-spark", "description": "Email client by Readdle", "installed": False},
                {"name": "amazon-q", "description": "AI-powered productivity tool", "installed": False},
                {"name": "craft", "description": "Document editor", "installed": False},
            ]
        },
        "communication": {
            "name": "Communication",
            "description": "Messaging and video conferencing apps",
            "casks": [
                {"name": "zoom", "description": "Video conferencing", "installed": False},
                {"name": "whatsapp", "description": "WhatsApp desktop", "installed": False},
                {"name": "messenger", "description": "Facebook Messenger", "installed": False},
            ]
        },
        "fonts": {
            "name": "Fonts",
            "description": "Developer-friendly fonts",
            "casks": [
                {"name": "font-fira-code", "description": "Monospaced font with ligatures", "installed": False},
                {"name": "font-fira-code-nerd-font", "description": "Fira Code with icons", "installed": False},
                {"name": "font-jetbrains-mono-nerd-font", "description": "JetBrains Mono with icons", "installed": False},
            ]
        },
        "microsoft": {
            "name": "Microsoft",
            "description": "Microsoft Office and tools",
            "casks": [
                {"name": "microsoft-auto-update", "description": "Microsoft AutoUpdate", "installed": False},
                {"name": "microsoft-edge", "description": "Microsoft Edge browser", "installed": False},
                {"name": "microsoft-word", "description": "Microsoft Word", "installed": False},
                {"name": "microsoft-excel", "description": "Microsoft Excel", "installed": False},
                {"name": "microsoft-powerpoint", "description": "Microsoft PowerPoint", "installed": False},
                {"name": "microsoft-onenote", "description": "Microsoft OneNote", "installed": False},
                {"name": "onedrive", "description": "Microsoft OneDrive", "installed": False},
            ]
        },
        "ai_development": {
            "name": "AI & ML Development",
            "description": "Tools for AI and machine learning",
            "casks": [
                {"name": "lm-studio", "description": "Discover and run local LLMs", "installed": False},
            ]
        }
    }
    
    # Check which casks are installed
    try:
        returncode, stdout, _ = run_command(['brew', 'list', '--cask', '-1'], check=False)
        if returncode == 0:
            installed = set(stdout.strip().split('\n'))
            
            for category in casks.values():
                for cask in category["casks"]:
                    cask["installed"] = cask["name"] in installed
    except:
        pass
    
    return casks

@router.post("/install/{package_name}")
async def install_package(package_name: str, current_user: dict = Depends(get_current_user)):
    """Install a Homebrew package"""
    try:
        result = subprocess.run(
            ['brew', 'install', package_name],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode == 0:
            return {
                "success": True,
                "message": f"Successfully installed {package_name}",
                "output": result.stdout
            }
        else:
            return {
                "success": False,
                "message": f"Failed to install {package_name}",
                "error": result.stderr
            }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "message": f"Installation of {package_name} timed out",
            "error": "Operation took too long"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/install-cask/{cask_name}")
async def install_cask(cask_name: str, current_user: dict = Depends(get_current_user)):
    """Install a Homebrew Cask"""
    try:
        result = subprocess.run(
            ['brew', 'install', '--cask', cask_name],
            capture_output=True,
            text=True,
            timeout=600  # 10 minute timeout for larger apps
        )
        
        if result.returncode == 0:
            return {
                "success": True,
                "message": f"Successfully installed {cask_name}",
                "output": result.stdout
            }
        else:
            return {
                "success": False,
                "message": f"Failed to install {cask_name}",
                "error": result.stderr
            }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "message": f"Installation of {cask_name} timed out",
            "error": "Operation took too long"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/uninstall/{package_name}")
async def uninstall_package(package_name: str, current_user: dict = Depends(get_current_user)):
    """Uninstall a Homebrew package"""
    try:
        result = subprocess.run(
            ['brew', 'uninstall', package_name],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            return {
                "success": True,
                "message": f"Successfully uninstalled {package_name}",
                "output": result.stdout
            }
        else:
            return {
                "success": False,
                "message": f"Failed to uninstall {package_name}",
                "error": result.stderr
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/installed")
async def get_installed_packages(current_user: dict = Depends(get_current_user)):
    """Get list of all installed Homebrew packages"""
    try:
        # Get formulae
        returncode1, stdout1, _ = run_command(['brew', 'list', '--formula', '-1'], check=False)
        formulae = stdout1.strip().split('\n') if returncode1 == 0 and stdout1 else []
        
        # Get casks
        returncode2, stdout2, _ = run_command(['brew', 'list', '--cask', '-1'], check=False)
        casks = stdout2.strip().split('\n') if returncode2 == 0 and stdout2 else []
        
        return {
            "formulae": formulae,
            "casks": casks,
            "total_formulae": len(formulae),
            "total_casks": len(casks)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/update")
async def update_brew(current_user: dict = Depends(get_current_user)):
    """Update Homebrew and all packages"""
    try:
        # Update Homebrew itself
        result1 = subprocess.run(
            ['brew', 'update'],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        # Upgrade packages
        result2 = subprocess.run(
            ['brew', 'upgrade'],
            capture_output=True,
            text=True,
            timeout=600
        )
        
        return {
            "success": True,
            "message": "Homebrew updated successfully",
            "update_output": result1.stdout,
            "upgrade_output": result2.stdout
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/cleanup")
async def cleanup_brew(current_user: dict = Depends(get_current_user)):
    """Clean up Homebrew cache and old versions"""
    try:
        result = subprocess.run(
            ['brew', 'cleanup'],
            capture_output=True,
            text=True,
            timeout=120
        )
        
        return {
            "success": True,
            "message": "Homebrew cleanup completed",
            "output": result.stdout,
            "freed_space": result.stdout
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
