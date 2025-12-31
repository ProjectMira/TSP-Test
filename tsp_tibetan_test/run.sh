#!/bin/bash

# TSP Tibetan Test - Local Development Runner
# Runs on both Android Emulator and iOS Simulator

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   TSP Tibetan Test - Running Android & iOS${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Kill existing Flutter processes
echo -e "${YELLOW}🔪 Killing existing Flutter processes...${NC}"
pkill -f "flutter run" 2>/dev/null || true
pkill -f "flutter_tools" 2>/dev/null || true
pkill -f "dart.*flutter" 2>/dev/null || true
sleep 2
echo -e "${GREEN}✓ Cleaned up existing processes${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies ready${NC}"
echo ""

# Find device IDs
echo -e "${YELLOW}📱 Finding devices...${NC}"

# Get Android device ID (emulator)
ANDROID_ID=$(flutter devices 2>/dev/null | grep -i "android" | head -1 | awk -F'•' '{print $2}' | xargs)

# Get iOS simulator device ID
IOS_ID=$(flutter devices 2>/dev/null | grep -i "iphone\|ipad" | head -1 | awk -F'•' '{print $2}' | xargs)

echo -e "  Android: ${GREEN}${ANDROID_ID:-Not found}${NC}"
echo -e "  iOS:     ${GREEN}${IOS_ID:-Not found}${NC}"
echo ""

# Check if we found both devices
if [ -z "$ANDROID_ID" ] || [ -z "$IOS_ID" ]; then
    echo -e "${RED}Error: Could not find both Android and iOS devices${NC}"
    echo -e "${YELLOW}Please make sure both emulator/simulator are running.${NC}"
    echo ""
    echo "Available devices:"
    flutter devices
    exit 1
fi

# Run on both devices
echo -e "${BLUE}🤖🍎 Launching on Android & iOS...${NC}"
flutter run -d "$ANDROID_ID" -d "$IOS_ID"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Done!${NC}"
echo -e "${GREEN}================================================${NC}"
