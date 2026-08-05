# MacAdmin - Native macOS System Management

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-Tahoe%2FSequoia-000000?logo=apple)](https://www.apple.com/macos/)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](https://reactjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com/)

A beautiful, native macOS system administration tool designed specifically for macOS Tahoe/Sequoia. Built with SwiftUI-inspired design principles and native macOS aesthetics.

![MacAdmin Preview](docs/preview.png)

## ✨ Features

### System Management
- **Real-time Dashboard** - CPU, memory, disk, and network metrics with native macOS charts
- **Process Manager** - View and manage running applications and processes
- **Storage Management** - Visual disk usage with Finder-like interface
- **Network Configuration** - Wi-Fi, Ethernet, and VPN management
- **User Management** - Local user accounts and permissions
- **Software Updates** - macOS update management and installation

### macOS Native Design
- **Authentic macOS UI** - Native buttons, controls, and window chrome
- **Blur & Vibrancy Effects** - True macOS visual effects
- **SF Symbols** - Apple's native icon system
- **Responsive Layout** - Adapts to any screen size
- **Accent Colors** - Respects system accent color preferences

### Advanced Tools
- **Terminal Integration** - Built-in Terminal access
- **Log Viewer** - Unified Log viewer with filtering
- **File Browser** - Finder-like file management
- **Startup Items** - Login items and LaunchAgents management
- **Firewall** - Application firewall configuration
- **Time Machine** - Backup management and monitoring

## 🚀 Quick Start

### Prerequisites
- macOS 14.0+ (Tahoe/Sequoia)
- Homebrew (optional, for development)
- Docker Desktop for Mac

### Installation

```bash
# Clone the repository
git clone https://github.com/irfancode/MacAdmin.git
cd MacAdmin

# Copy environment file
cp .env.example .env

# Start with Docker
docker-compose up -d

# Or install natively
./scripts/install-macos.sh
```

### Development

```bash
# Frontend
cd frontend && npm run dev

# Backend
cd backend && python -m app.main
```

## 🏗️ Architecture

### Frontend (React + TypeScript)
- **React 18** with hooks
- **Vite** for fast builds
- **Tailwind CSS** with native macOS theme
- **Framer Motion** for smooth animations
- **Lucide Icons** + SF Symbols

### Backend (FastAPI + Python)
- **FastAPI** async framework
- **psutil** for system metrics
- **SQLite** for local data storage
- **WebSocket** for real-time updates
- **Native macOS APIs** via pyobjc

### Design System
- **Native macOS Controls** - Buttons, sliders, switches
- **Blur & Vibrancy** - True NSVisualEffectView styling
- **SF Pro Font** - Apple's system font
- **Semantic Colors** - Light/Dark/Auto modes

## 📚 Documentation

- [Installation Guide](docs/installation.md)
- [User Manual](docs/user-manual.md)
- [API Documentation](docs/api.md)
- [Contributing](CONTRIBUTING.md)

## 🛠️ macOS Integration

MacAdmin leverages native macOS technologies:

- **System Profiler** - Hardware information
- **pmset** - Power management
- **networksetup** - Network configuration
- **diskutil** - Disk management
- **log** - Unified Logging system
- **launchctl** - Service management
- **softwareupdate** - System updates

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple for the beautiful macOS design language
- Built for the macOS power user community

---

**Note:** MacAdmin requires administrator privileges for certain system-level operations.

Made with ❤️ for macOS by [Irfan Shaikh](https://github.com/irfancode)
