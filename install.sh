#!/bin/bash
# MoonTVPlus One-Click Install Script (Caddy Version)
# Port: 8073

PORT=8073
REPO="https://github.com/cshaizhihao/MoonTVPlus"
DIR="/opt/moontv"

echo ">>> Installing MoonTVPlus on Port $PORT..."

# 1. Install Dependencies
if ! command -v git &> /dev/null; then
    apt update && apt install git -y
fi

if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | bash
fi

# 2. Clone Repository
echo "Cloning repository..."
rm -rf $DIR
git clone $REPO $DIR

# 3. Run Container (Caddy with File Browser)
echo "Starting container..."
docker stop moontv 2>/dev/null
docker rm moontv 2>/dev/null

docker run -d --name moontv \
  -p $PORT:80 \
  -v $DIR:/usr/share/caddy \
  --restart always \
  caddy \
  caddy file-server --browse --root /usr/share/caddy --listen :80

# 4. Success Output
IP=$(curl -s ifconfig.me || curl -s 4.icanhazip.com)
echo ">>> Deployment Successful!"
echo "Access URL: http://$IP:$PORT"
