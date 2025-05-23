#!/bin/bash
# Description: Installs the YouTube downloader script to system path
# Author: Akash Meshram (akashmeshram.com)

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Script name
SCRIPT_NAME="yt"
SOURCE_SCRIPT="$PWD/yt.sh"
TARGET_DIR="/usr/local/bin"
TARGET_PATH="$TARGET_DIR/$SCRIPT_NAME"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}This script needs to run with root privileges to install to $TARGET_DIR${NC}"
  echo -e "Please enter your password when prompted."

  # Try to use sudo to run this script
  exec sudo "$0" "$@"
  exit $?
fi

echo -e "${YELLOW}Installing YouTube Downloader script...${NC}"

# Check for dependencies
echo -e "Checking for required dependencies..."
MISSING_DEPS=()
OPTIONAL_DEPS=()

# Check required dependencies
for dep in yt-dlp ffmpeg; do
  if ! command -v "$dep" &> /dev/null; then
    MISSING_DEPS+=("$dep")
  fi
done

# Check optional dependencies
for opt_dep in AtomicParsley jq; do
  if ! command -v "$opt_dep" &> /dev/null; then
    OPTIONAL_DEPS+=("$opt_dep")
  fi
done

# Report missing required dependencies
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo -e "${RED}The following dependencies are missing:${NC}"
  for dep in "${MISSING_DEPS[@]}"; do
    echo -e "  - $dep"
  done

  # Provide installation instructions based on dependency
  echo -e "\n${YELLOW}Installation instructions:${NC}"

  if [[ " ${MISSING_DEPS[*]} " =~ " yt-dlp " ]]; then
    echo -e "For yt-dlp: ${GREEN}sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && sudo chmod a+rx /usr/local/bin/yt-dlp${NC}"
  fi

  if [[ " ${MISSING_DEPS[*]} " =~ " ffmpeg " ]]; then
    echo -e "For ffmpeg: ${GREEN}sudo apt install ffmpeg${NC} (Ubuntu/Debian)"
    echo -e "            ${GREEN}brew install ffmpeg${NC} (macOS)"
  fi

  echo -e "\n${YELLOW}Please install the missing dependencies and run this script again.${NC}"
  exit 1
fi

# Report missing optional dependencies
if [ ${#OPTIONAL_DEPS[@]} -gt 0 ]; then
  echo -e "\n${YELLOW}Optional dependencies not found:${NC}"
  for dep in "${OPTIONAL_DEPS[@]}"; do
    echo -e "  - $dep"
  done

  echo -e "\n${YELLOW}These are not required but enhance functionality:${NC}"
  echo -e "For AtomicParsley & jq: ${GREEN}sudo apt install atomicparsley jq${NC} (Ubuntu/Debian)"
  echo -e "                       ${GREEN}brew install atomicparsley jq${NC} (macOS)"
  echo -e "\nProceeding with installation anyway..."
fi

# Check if source script exists
if [ ! -f "$SOURCE_SCRIPT" ]; then
  echo -e "${RED}Error: Source script $SOURCE_SCRIPT not found.${NC}"
  echo -e "Make sure you are running this installer from the directory containing yt.sh"
  exit 1
fi

# Make source script executable if it's not already
chmod +x "$SOURCE_SCRIPT"

# Copy the script to target directory
echo -e "Copying script to $TARGET_DIR..."
cp "$SOURCE_SCRIPT" "$TARGET_PATH"

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to copy the script to $TARGET_DIR${NC}"
  exit 1
fi

# Make the script executable in target location
chmod +x "$TARGET_PATH"

if [ $? -ne 0 ]; then
  echo -e "${RED}Failed to make the script executable${NC}"
  exit 1
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "\nYou can now run the YouTube downloader by typing ${GREEN}$SCRIPT_NAME${NC} anywhere in your terminal."
echo -e "Example usage: ${GREEN}$SCRIPT_NAME https://www.youtube.com/watch?v=VIDEO_ID${NC}"
echo -e "For more options: ${GREEN}$SCRIPT_NAME --help${NC}"

exit 0
