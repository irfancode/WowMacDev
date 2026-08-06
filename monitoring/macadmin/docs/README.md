# MacAdmin Documentation

## Overview

MacAdmin is a native macOS system administration tool designed specifically for macOS Tahoe/Sequoia (macOS 14/15). It provides a beautiful, native interface for managing your Mac system.

## Features

### System Monitoring
- Real-time CPU, Memory, Disk, and Network metrics
- Process management
- System information display
- Live updates via WebSocket

### User Management
- View and manage local user accounts
- Integration with macOS dscl

### Software Updates
- Check for available macOS updates
- View update details

### System Logs
- Unified Log viewer
- Filter and search capabilities

## Installation

### Using Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/irfancode/MacAdmin.git
cd MacAdmin

# Copy environment file
cp .env.example .env

# Start with Docker Compose
docker-compose up -d

# Access the application
open http://localhost:3000
```

### Native Installation

```bash
# Frontend
cd frontend
npm install
npm run dev

# Backend (in another terminal)
cd backend
pip install -r requirements.txt
python -m app.main
```

## API Documentation

### Authentication

All endpoints require authentication except `/api/auth/login`.

**Login:**
```bash
POST /api/auth/login
Content-Type: application/x-www-form-urlencoded

username=admin&password=admin
```

**Response:**
```json
{
  "access_token": "...",
  "token_type": "bearer",
  "user": {
    "id": "1",
    "username": "admin",
    "fullName": "Administrator",
    "role": "admin"
  }
}
```

### System Endpoints

#### GET /api/system/metrics
Returns real-time system metrics:
```json
{
  "cpu": {
    "percent": 12.5,
    "count": 8,
    "count_logical": 16
  },
  "memory": {
    "total": 17179869184,
    "available": 8589934592,
    "percent": 50.0
  },
  "disk": {
    "total": 1000240963584,
    "used": 250000000000,
    "free": 750240963584,
    "percent": 25.0
  }
}
```

#### GET /api/system/info
Returns system information including macOS version and hardware details.

#### GET /api/system/processes
Returns top 20 processes by CPU usage.

### Network Endpoints

#### GET /api/network/interfaces
Returns all network interfaces with IP addresses and statistics.

#### GET /api/network/stats
Returns network I/O statistics.

### User Endpoints

#### GET /api/users/
Returns list of local user accounts (excludes system users).

### Update Endpoints

#### GET /api/updates/
Checks for available macOS software updates.

### Log Endpoints

#### GET /api/logs/
Returns recent system logs (last hour).

Query parameters:
- `limit`: Number of log entries (default: 100)

## WebSocket

Connect to `ws://localhost:8000/ws` for real-time updates.

**Message format:**
```json
{
  "type": "metrics",
  "timestamp": 1705312200,
  "data": {
    "cpu": 12.5,
    "memory": 50.0,
    "disk": 25.0
  }
}
```

## macOS Integration

MacAdmin uses native macOS commands:

- **System Info:** `sw_vers`, `system_profiler`
- **Users:** `dscl`
- **Updates:** `softwareupdate`
- **Logs:** `log`

## Configuration

Edit `.env` file:

```env
# Security
SECRET_KEY=your-secret-key
JWT_SECRET_KEY=your-jwt-secret

# Development
DEBUG=true

# Frontend URLs
VITE_API_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000
```

## Security

- JWT token-based authentication
- Passwords validated against macOS user database (production)
- HTTPS recommended for production
- CORS configured for development

## Troubleshooting

### Port Already in Use
```bash
# Find and kill process
lsof -i :3000
kill -9 <PID>
```

### Docker Issues
```bash
# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Permission Denied
Ensure Docker has proper permissions:
```bash
sudo usermod -aG docker $USER
```

## Development

### Frontend
```bash
cd frontend
npm run dev        # Start dev server
npm run build      # Build for production
npm run typecheck  # Type checking
```

### Backend
```bash
cd backend
python -m app.main           # Start server
python -m pytest            # Run tests
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file
