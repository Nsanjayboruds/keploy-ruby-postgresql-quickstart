#!/bin/bash

# Keploy Record Script
echo "🎥 Starting Keploy in RECORD mode..."
echo "======================================"
echo ""

# Check if running with Docker or locally
if [ "$1" == "docker" ]; then
    echo "📦 Using Docker Compose setup"
    keploy record -c "docker-compose up" --container-name "ruby-books-app"
else
    echo "🖥️  Using local setup"
    keploy record -c "bundle exec ruby app.rb"
fi
