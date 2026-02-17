#!/bin/bash
# MoonTVPlus One-Click Install Script (Docker Compose)
# Port: 8073

DIR="/opt/moontvplus"

echo ">>> Installing MoonTVPlus..."

# 1. Check Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | bash
fi

# 2. Setup Directory
mkdir -p $DIR
cd $DIR

# 3. Generate Docker Compose
RAND_PASS=$(date +%s%N | md5sum | head -c 8)
echo "Generating docker-compose.yml..."

cat > docker-compose.yml <<EOF
services:
  moontv-core:
    image: ghcr.io/mtvpls/moontvplus:latest
    container_name: moontv-core
    restart: unless-stopped
    ports:
      - "8073:3000"
    environment:
      - USERNAME=admin
      - PASSWORD=$RAND_PASS
      - NEXT_PUBLIC_STORAGE_TYPE=kvrocks
      - KVROCKS_URL=redis://moontv-kvrocks:6666
      - NEXT_PUBLIC_ENABLE_SOURCE_SEARCH=true
    networks:
      - moontv-network
    depends_on:
      - moontv-kvrocks

  moontv-kvrocks:
    image: apache/kvrocks
    container_name: moontv-kvrocks
    restart: unless-stopped
    volumes:
      - kvrocks_data:/var/lib/kvrocks/data
    networks:
      - moontv-network

networks:
  moontv-network:
    driver: bridge

volumes:
  kvrocks_data:
EOF

# 4. Pull & Up
echo "Starting services..."
docker compose pull
docker compose up -d

# 5. Output Info
IP=$(curl -s4 ifconfig.me)
echo "--------------------------------"
echo "Deployment Complete!"
echo "URL:      http://$IP:8073"
echo "Username: admin"
echo "Password: $RAND_PASS"
echo "--------------------------------"
