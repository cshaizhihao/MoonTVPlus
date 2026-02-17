#!/bin/bash
# MoonTVPlus One-Click Install Script (Web App Version)
# Port: 8073

PORT=8073
REPO="https://github.com/cshaizhihao/MoonTVPlus"
DIR="/opt/moontv"

echo ">>> Installing MoonTVPlus Web App on Port $PORT..."

# 1. Install Docker
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | bash
fi

# 2. Clone Repository
rm -rf $DIR
git clone $REPO $DIR
cd $DIR

# 3. Build & Run Docker Container
echo "Building Docker image (this may take a few minutes)..."
docker stop moontv 2>/dev/null
docker rm moontv 2>/dev/null

# Use the project's own Dockerfile
docker build -t moontv .

# Run container mapping host 8073 to container 3000 (default for Next.js)
docker run -d --name moontv \
  -p $PORT:3000 \
  --restart always \
  moontv

# 4. Success Output
IP=$(curl -s ifconfig.me || curl -s 4.icanhazip.com)
echo ">>> Deployment Successful!"
echo "Access Web App: http://$IP:$PORT"
