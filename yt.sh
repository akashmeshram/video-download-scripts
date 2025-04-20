#!/bin/bash
# Description: Download YouTube videos and audios using yt-dlp (Zenity Edition)
# Author: Akash Meshram (akashmeshram.com)
# Version: 1.2 (Enhanced with more options and better error handling)

# Check for required dependencies
check_dependencies() {
  local missing=()
  
  for cmd in zenity yt-dlp ffmpeg; do
    if ! command -v "$cmd" &> /dev/null; then
      missing+=("$cmd")
    fi
  done
  
  if [ ${#missing[@]} -gt 0 ]; then
    zenity --error --title="Missing Dependencies" \
      --text="The following required programs are missing:\n$(printf '• %s\n' "${missing[@]}")\n\nPlease install them and try again."
    exit 1
  fi
}

# Check dependencies before proceeding
check_dependencies

# Ask user for the YouTube URL
YOUTUBE_URL=$(zenity --entry \
  --title="YouTube Downloader" \
  --text="Enter the YouTube URL (video or playlist):" \
  --width=500)

# Exit if no URL
if [[ -z "$YOUTUBE_URL" ]]; then
  zenity --error --text="No URL provided. Exiting."
  exit 1
fi

# Ask if it's a playlist
IS_PLAYLIST=$(zenity --question --title="Playlist?" \
  --text="Is this a playlist that you want to download entirely?" \
  --ok-label="Yes, it's a playlist" --cancel-label="No, single video" \
  --width=300 && echo "yes" || echo "no")

# Ask user for type of download
OPTION=$(zenity --list \
  --radiolist \
  --title="Choose Download Type" \
  --text="Select what you want to download:" \
  --column="Select" --column="Option" \
  TRUE "Video" \
  FALSE "Audio" \
  FALSE "Music (MP3 with square thumbnail)" \
  --width=400 --height=250)

# Set default if none selected
if [[ -z "$OPTION" ]]; then
  OPTION="Video"
fi

# If video is selected, ask for quality
VIDEO_QUALITY="best"
if [[ "$OPTION" == "Video" ]]; then
  VIDEO_QUALITY=$(zenity --list \
    --radiolist \
    --title="Video Quality" \
    --text="Select video quality:" \
    --column="Select" --column="Quality" --column="Description" \
    TRUE "best" "Best available quality" \
    FALSE "1080p" "Full HD (1080p)" \
    FALSE "720p" "HD (720p)" \
    FALSE "480p" "SD (480p)" \
    --width=500 --height=250)
  
  # Default to best if canceled
  if [[ -z "$VIDEO_QUALITY" ]]; then
    VIDEO_QUALITY="best"
  fi
fi

# Ask for download location
DEFAULT_LOCATION="$HOME/Downloads"
DOWNLOAD_LOCATION=$(zenity --file-selection \
  --directory \
  --title="Select Download Location" \
  --filename="$DEFAULT_LOCATION")

# Default to Downloads if canceled
if [[ -z "$DOWNLOAD_LOCATION" ]]; then
  DOWNLOAD_LOCATION="$DEFAULT_LOCATION"
fi

# Common options
METADATA_OPTIONS=(
  --embed-chapters
  --parse-metadata "description:(?s)(?P<meta_comment>.+)"
  --parse-metadata "description:(?s)(?P<meta_year>\b\d{4}\b)"
  --parse-metadata "description:(?s)(?P<meta_date>\d{4}-\d{2}-\d{2})"
  --embed-metadata
)
THUMBNAIL_OPTIONS=(--embed-thumbnail --convert-thumbnails jpg)
SUBTITLE_OPTIONS=(--sub-lang "en.*" --embed-subs)
SQUARE_THUMBNAIL_OPTIONS=(--ppa "ffmpeg:-c:v mjpeg -vf crop='if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'")
OTHER_OPTIONS=(--ignore-errors --no-check-certificate)

# Format options based on quality selection
case "$VIDEO_QUALITY" in
  "1080p")
    VIDEO_FORMAT_OPTIONS=(-f "bv[height<=1080]+ba/b[height<=1080] / bv+ba/b" --audio-multistreams)
    ;;
  "720p")
    VIDEO_FORMAT_OPTIONS=(-f "bv[height<=720]+ba/b[height<=720] / bv+ba/b" --audio-multistreams)
    ;;
  "480p")
    VIDEO_FORMAT_OPTIONS=(-f "bv[height<=480]+ba/b[height<=480] / bv+ba/b" --audio-multistreams)
    ;;
  *)
    VIDEO_FORMAT_OPTIONS=(-f "bv+ba" --audio-multistreams)
    ;;
esac

AUDIO_FORMAT_OPTIONS=(-f "251/bestaudio")
MUSIC_FORMAT_OPTIONS=(--xattrs -x --audio-format mp3 -f "251/bestaudio")

# Output templates
FILE_NAME_FORMAT=(-o "$DOWNLOAD_LOCATION/%(title)s [%(id)s].%(ext)s")
MUSIC_FILE_NAME_FORMAT=(-o "$DOWNLOAD_LOCATION/%(title)s.%(ext)s")

# Playlist options
if [[ "$IS_PLAYLIST" == "yes" ]]; then
  PLAYLIST_OPTS=(--yes-playlist -o "$DOWNLOAD_LOCATION/%(playlist)s/%(playlist_index)s - %(title)s [%(id)s].%(ext)s")
else
  PLAYLIST_OPTS=(--no-playlist)
fi

# Build yt-dlp command
YT_DLP_CMD=(yt-dlp "${METADATA_OPTIONS[@]}" "${THUMBNAIL_OPTIONS[@]}" "${OTHER_OPTIONS[@]}" "${PLAYLIST_OPTS[@]}")

case "$OPTION" in
  "Video")
    YT_DLP_CMD+=("${SUBTITLE_OPTIONS[@]}" "${VIDEO_FORMAT_OPTIONS[@]}" "${FILE_NAME_FORMAT[@]}" "$YOUTUBE_URL")
    ;;
  "Audio")
    YT_DLP_CMD+=("${AUDIO_FORMAT_OPTIONS[@]}" "${FILE_NAME_FORMAT[@]}" "$YOUTUBE_URL")
    ;;
  "Music (MP3 with square thumbnail)")
    YT_DLP_CMD+=("${SQUARE_THUMBNAIL_OPTIONS[@]}" "${MUSIC_FORMAT_OPTIONS[@]}" "${MUSIC_FILE_NAME_FORMAT[@]}" "$YOUTUBE_URL")
    ;;
esac

# Temporary file for progress tracking
PROGRESS_FILE=$(mktemp)

# Run the command and capture output for progress reporting
(
  echo "0"
  echo "# Preparing download..."
  
  # Run yt-dlp with progress hook
  "${YT_DLP_CMD[@]}" --newline --progress-template "download:%(progress.downloaded_bytes)s/%(progress.total_bytes)s [%(progress.eta)s]" 2>&1 | 
  while IFS= read -r line; do
    # Extract download percentage from yt-dlp output
    if [[ "$line" =~ \[download\]\ +([0-9.]+)% ]]; then
      PERCENT=${BASH_REMATCH[1]}
      echo "$PERCENT"
      echo "# Downloading: $PERCENT%"
    # Extract the progress from download template
    elif [[ "$line" =~ download:(.*)/(.*)\ \[(.*)\] ]]; then
      DOWNLOADED=${BASH_REMATCH[1]}
      TOTAL=${BASH_REMATCH[2]}
      ETA=${BASH_REMATCH[3]}
      
      # Calculate percentage if possible
      if [[ -n "$TOTAL" && "$TOTAL" != "NA" && "$TOTAL" -gt 0 ]]; then
        PERCENT=$(( (DOWNLOADED * 100) / TOTAL ))
        echo "$PERCENT"
        echo "# Downloading: $PERCENT% (ETA: $ETA)"
      else
        echo "# Downloading... (ETA: $ETA)"
      fi
    elif [[ "$line" == *"Downloading"* || "$line" == *"Extracting"* ]]; then
      echo "# $line"
    fi
    
    # Capture all output for debugging
    echo "$line" >> "$PROGRESS_FILE"
  done

  echo "100"
  echo "# Done!"
) | zenity --progress \
  --title="Downloading with yt-dlp" \
  --text="Initializing..." \
  --percentage=0 \
  --auto-close \
  --width=400

# Check for errors in the output
if grep -q "ERROR" "$PROGRESS_FILE"; then
  zenity --warning \
    --title="Download Completed with Warnings" \
    --text="Download completed but some errors occurred. Check terminal for details." \
    --width=400
  
  # Option to view errors
  if zenity --question --text="Do you want to view the errors?" --width=300; then
    grep "ERROR" "$PROGRESS_FILE" | zenity --text-info --title="Download Errors" --width=600 --height=400
  fi
else
  zenity --info \
    --text="Download completed successfully to:\n$DOWNLOAD_LOCATION" \
    --title="Success 🎉" \
    --width=400
fi

# Open download folder option
if zenity --question \
  --text="Do you want to open the download folder?" \
  --title="Open Folder" \
  --width=300; then
  xdg-open "$DOWNLOAD_LOCATION"
fi

# Clean up
rm -f "$PROGRESS_FILE"
