# Production Deployment Guide

This guide covers deploying MacAdmin to production environments.

## Prerequisites

- macOS 14+ (Tahoe/Sequoia)
- Administrative privileges
- Static IP or domain name
- SSL certificate (recommended)

## Method 1: Docker Deployment

### Step 1: Server Setup

```bash
# Install Docker Desktop for Mac
# Download from: https://www.docker.com/products/docker-desktop

# Clone repository
git clone https://github.com/irfancode/MacAdmin.git
cd MacAdmin
```

### Step 2: Configure Environment

```bash
cp .env.example .env

# Edit .env with production values
nano .env
```

Update these values:
```env
DEBUG=false
SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_KEY=$(openssl rand -hex 32)
VITE_API_URL=https://your-domain.com/api
VITE_WS_URL=wss://your-domain.com/ws
```

### Step 3: Start Services

```bash
docker-compose up -d
```

### Step 4: Verify

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

## Method 2: Native Deployment

### Frontend Build

```bash
cd frontend
npm ci
npm run build

# Copy to web server directory
sudo cp -r dist/* /var/www/macadmin/
```

### Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service
sudo nano /Library/LaunchDaemons/com.macadmin.backend.plist
```

Service file:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.macadmin.backend</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/MacAdmin/backend/venv/bin/uvicorn</string>
        <string>app.main:app</string>
        <string>--host</string>
        <string>127.0.0.1</string>
        <string>--port</string>
        <string>8000</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/path/to/MacAdmin/backend</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Start service:
```bash
sudo launchctl load /Library/LaunchDaemons/com.macadmin.backend.plist
sudo launchctl start com.macadmin.backend
```

## SSL/TLS Configuration

### Using Let's Encrypt

```bash
# Install certbot
brew install certbot

# Obtain certificate
sudo certbot certonly --standalone -d your-domain.com

# Update docker-compose.yml to use certificates
```

### Using Self-Signed Certificate

```bash
# Generate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout macadmin.key -out macadmin.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"

# Move to appropriate location
sudo mkdir -p /etc/ssl/macadmin
sudo mv macadmin.key macadmin.crt /etc/ssl/macadmin/
```

## Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/ssl/macadmin/macadmin.crt;
    ssl_certificate_key /etc/ssl/macadmin/macadmin.key;

    # Frontend
    location / {
        root /var/www/macadmin;
        try_files $uri $uri/ /index.html;
    }

    # API
    location /api {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket
    location /ws {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 86400;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## Security Considerations

### 1. Firewall Configuration

```bash
# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Allow MacAdmin ports
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which python3)
```

### 2. File Permissions

```bash
# Set proper permissions
chmod 600 .env
chmod 755 backend/
chmod 644 backend/app/*.py
```

### 3. Regular Updates

```bash
# Update system
softwareupdate -l
softwareupdate -i -a

# Update MacAdmin
cd /path/to/MacAdmin
git pull origin master
docker-compose down
docker-compose up -d --build
```

## Monitoring

### Log Rotation

```bash
# Install logrotate (if not present)
brew install logrotate

# Create config
sudo nano /usr/local/etc/logrotate.d/macadmin
```

Config:
```
/path/to/MacAdmin/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 admin admin
}
```

### Health Checks

Create monitoring script:

```bash
#!/bin/bash
# /usr/local/bin/macadmin-health.sh

if ! curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "MacAdmin backend is down!" | mail -s "MacAdmin Alert" admin@example.com
    # Restart service
    docker-compose -f /path/to/MacAdmin/docker-compose.yml restart backend
fi
```

Add to crontab:
```bash
*/5 * * * * /usr/local/bin/macadmin-health.sh
```

## Backup Strategy

### Configuration Backup

```bash
# Backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/macadmin"

mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/macadmin_config_$DATE.tar.gz \
  /path/to/MacAdmin/.env \
  /path/to/MacAdmin/docker-compose.yml

# Keep only last 7 days
find $BACKUP_DIR -name "macadmin_config_*.tar.gz" -mtime +7 -delete
```

## Troubleshooting

### Connection Refused

```bash
# Check if services are running
docker-compose ps

# Check logs
docker-compose logs backend

# Verify port availability
netstat -an | grep 8000
netstat -an | grep 3000
```

### SSL Certificate Issues

```bash
# Verify certificate
openssl x509 -in /etc/ssl/macadmin/macadmin.crt -text -noout

# Check certificate expiry
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates
```

### Performance Issues

```bash
# Monitor resources
htop

# Check Docker stats
docker stats

# View slow queries (if using database)
# Check application logs
docker-compose logs -f --tail=100 backend
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/irfancode/MacAdmin/issues
- Documentation: https://github.com/irfancode/MacAdmin/tree/master/docs
