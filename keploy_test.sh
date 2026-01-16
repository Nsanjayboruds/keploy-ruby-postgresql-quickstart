#!/bin/bash

# Keploy Test Script
echo "🧪 Starting Keploy in TEST mode..."
echo "======================================"
echo ""

# Check if running with Docker or locally
if [ "$1" == "docker" ]; then
    echo "📦 Using Docker Compose setup"
    keploy test -c "docker-compose up" --container-name "ruby-books-app" --delay 10
else
    echo "🖥️  Using local setup"
    keploy test -c "bundle exec ruby app.rb" --delay 10
fi
