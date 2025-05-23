#!/bin/bash
# Description: Download YouTube videos and audios using yt-dlp
# Author: Akash Meshram (akashmeshram.com)
# Version: 1.3 

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Unicode symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="→"
INFO="ℹ"
MUSIC_NOTE="♪"
VIDEO_ICON="▶"
DOWNLOAD_ICON="⬇"
PROCESSING_ICON="⚙"
METADATA_ICON="📋"

# Function to print colored output
log() {
    local level=$1
    shift
    case $level in
        ERROR)
            echo -e "${RED}${CROSS_MARK} ERROR: $*${NC}" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}${CHECK_MARK} $*${NC}"
            ;;
        INFO)
            echo -e "${BLUE}${INFO} $*${NC}"
            ;;
        WARN)
            echo -e "${YELLOW}! WARNING: $*${NC}"
            ;;
        PROCESS)
            echo -e "${CYAN}${PROCESSING_ICON} $*${NC}"
            ;;
        DOWNLOAD)
            echo -e "${PURPLE}${DOWNLOAD_ICON} $*${NC}"
            ;;
        *)
            echo "$*"
            ;;
    esac
}

# Function to print section headers
print_header() {
    echo ""
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${WHITE}═══════════════════════════════════════════════════════════════${NC}"
}

# Function to print sub-headers
print_subheader() {
    echo ""
    echo -e "${CYAN}▸ $1${NC}"
    echo -e "${CYAN}$(printf '─%.0s' {1..60})${NC}"
}

# Function to display usage
usage() {
    print_header "YouTube Video/Audio Downloader v2.0"
    echo ""
    echo "Usage: $0 [OPTIONS] <URL>"
    echo ""
    echo -e "${WHITE}VIDEO OPTIONS:${NC}"
    echo "  -o, --output DIR     Output directory (default: current directory)"
    echo "  -f, --format FORMAT  Container format: mp4, mkv, webm (default: mp4)"
    echo "  -s, --subtitles      Download subtitles"
    echo "  -S, --subtitles-all  Download all available subtitles"
    echo "  -t, --thumbnail      Embed thumbnail (default: enabled)"
    echo "  --no-thumbnail       Disable thumbnail embedding"
    echo "  -m, --metadata       Embed metadata (default: enabled)"
    echo "  --no-metadata        Disable metadata embedding"
    echo "  -p, --playlist       Download entire playlist"
    echo "  -r, --resolution RES Preferred resolution (e.g., 1080, 1440, 2160/4K)"
    echo "  -c, --codec CODEC    Preferred video codec (e.g., h264, av1, vp9)"
    echo "  -n, --filename NAME  Custom filename (without extension)"
    echo "  -k, --keep-files     Keep intermediate files after merging"
    echo "  -v, --verbose        Show detailed download information"
    echo ""
    echo -e "${WHITE}AUDIO OPTIONS:${NC}"
    echo "  -a, --audio-only     Download best quality audio only"
    echo "  --mp3                Download as MP3 with square thumbnail (implies -a)"
    echo "  -q, --quality QUAL   Audio quality for MP3 (0-9, 0=best, default: 0)"
    echo "  --square-thumb       Force square thumbnail for video files too"
    echo ""
    echo -e "${WHITE}METADATA OPTIONS:${NC}"
    echo "  --artist NAME        Override artist/creator name"
    echo "  --album NAME         Override album/show name"
    echo "  --year YEAR          Override year"
    echo "  --genre GENRE        Set genre"
    echo "  --comment TEXT       Set comment"
    echo "  --compilation        Mark as compilation"
    echo ""
    echo "  -h, --help           Show this help message"
    echo ""
    echo -e "${WHITE}EXAMPLES:${NC}"
    echo -e "  ${GREEN}# Download video (metadata and thumbnail enabled by default)${NC}"
    echo "  $0 https://www.youtube.com/watch?v=VIDEO_ID"
    echo ""
    echo -e "  ${GREEN}# Download video without metadata or thumbnail${NC}"
    echo "  $0 --no-metadata --no-thumbnail https://www.youtube.com/watch?v=VIDEO_ID"
    echo ""
    echo -e "  ${GREEN}# Download as MP3 with square thumbnail (default)${NC}"
    echo "  $0 --mp3 https://www.youtube.com/watch?v=VIDEO_ID"
    echo ""
    echo -e "  ${GREEN}# Download playlist as MP3 album${NC}"
    echo "  $0 --mp3 -p --album 'Best Hits 2024' https://www.youtube.com/playlist?list=PLAYLIST_ID"
    echo ""
    echo -e "  ${GREEN}# Download 1080p video with custom metadata${NC}"
    echo "  $0 -r 1080 --artist 'Creator Name' https://www.youtube.com/watch?v=VIDEO_ID"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    local optional_deps=()
    
    print_subheader "Checking Dependencies"
    
    # Check required dependencies
    if ! command -v yt-dlp &> /dev/null; then
        missing_deps+=("yt-dlp")
    else
        log SUCCESS "yt-dlp found $(yt-dlp --version 2>/dev/null || echo '')"
    fi
    
    if ! command -v ffmpeg &> /dev/null; then
        missing_deps+=("ffmpeg")
    else
        log SUCCESS "ffmpeg found $(ffmpeg -version 2>/dev/null | head -n1 | cut -d' ' -f3 || echo '')"
    fi
    
    # Check optional dependencies
    if ! command -v AtomicParsley &> /dev/null; then
        optional_deps+=("AtomicParsley")
        log WARN "AtomicParsley not found (optional - for better MP4 metadata)"
        HAS_ATOMICPARSLEY=0
    else
        log SUCCESS "AtomicParsley found"
        HAS_ATOMICPARSLEY=1
    fi
    
    if ! command -v jq &> /dev/null; then
        optional_deps+=("jq")
        log WARN "jq not found (optional - for better metadata parsing)"
        HAS_JQ=0
    else
        log SUCCESS "jq found $(jq --version 2>/dev/null || echo '')"
        HAS_JQ=1
    fi
    
    # Exit if required dependencies are missing
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        log ERROR "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Installation instructions:"
        echo "  yt-dlp:  pip install yt-dlp"
        echo "  ffmpeg:  apt install ffmpeg (Ubuntu/Debian)"
        echo "           brew install ffmpeg (macOS)"
        exit 1
    fi
    
    # Show optional dependency installation hints
    if [ ${#optional_deps[@]} -gt 0 ]; then
        echo ""
        echo "Optional dependencies for enhanced features:"
        for dep in "${optional_deps[@]}"; do
            case $dep in
                AtomicParsley)
                    echo "  AtomicParsley: brew install atomicparsley (macOS)"
                    echo "                 apt install atomicparsley (Ubuntu/Debian)"
                    ;;
                jq)
                    echo "  jq: brew install jq (macOS)"
                    echo "      apt install jq (Ubuntu/Debian)"
                    ;;
            esac
        done
    fi
}

# Function to display download summary
display_summary() {
    print_subheader "Download Configuration"
    
    if [ -n "$MP3_MODE" ]; then
        log INFO "Mode: ${MUSIC_NOTE} MP3 Audio with Square Thumbnail"
    elif [ -n "$AUDIO_ONLY" ]; then
        log INFO "Mode: ${MUSIC_NOTE} Audio Only"
    else
        log INFO "Mode: ${VIDEO_ICON} Video Download"
    fi
    
    log INFO "Output Directory: $OUTPUT_DIR"
    
    if [ -n "$MP3_MODE" ]; then
        log INFO "Format: MP3 (Quality: $AUDIO_QUALITY)"
    elif [ -z "$AUDIO_ONLY" ]; then
        log INFO "Container Format: $CONTAINER_FORMAT"
        [ -n "$PREFERRED_RES" ] && log INFO "Max Resolution: ${RES_HEIGHT}p"
        [ -n "$PREFERRED_CODEC" ] && log INFO "Preferred Codec: $PREFERRED_CODEC"
    fi
    
    [ -n "$PLAYLIST_MODE" ] && log INFO "Playlist Mode: Enabled"
    if [ -n "$EMBED_METADATA" ]; then
        log INFO "Metadata: Enabled (default)"
    else
        log INFO "Metadata: Disabled"
    fi
    if [ -n "$EMBED_THUMBNAIL" ]; then
        log INFO "Thumbnail: Enabled (default)"
    else
        log INFO "Thumbnail: Disabled"
    fi
    [ -n "$DOWNLOAD_SUBS" ] || [ -n "$DOWNLOAD_ALL_SUBS" ] && log INFO "Subtitles: Will be downloaded"
    
    # Show custom metadata if set
    if [ -n "$CUSTOM_ARTIST" ] || [ -n "$CUSTOM_ALBUM" ] || [ -n "$CUSTOM_YEAR" ] || [ -n "$CUSTOM_GENRE" ]; then
        echo ""
        log INFO "Custom Metadata:"
        [ -n "$CUSTOM_ARTIST" ] && echo "    Artist: $CUSTOM_ARTIST"
        [ -n "$CUSTOM_ALBUM" ] && echo "    Album: $CUSTOM_ALBUM"
        [ -n "$CUSTOM_YEAR" ] && echo "    Year: $CUSTOM_YEAR"
        [ -n "$CUSTOM_GENRE" ] && echo "    Genre: $CUSTOM_GENRE"
    fi
}

# Function to process square thumbnail
process_square_thumbnail() {
    local input_thumb="$1"
    local output_thumb="$2"
    
    if [ -f "$input_thumb" ]; then
        log PROCESS "Creating square thumbnail (1400x1400)..."
        ffmpeg -i "$input_thumb" -vf "crop='min(iw,ih)':'min(iw,ih)',scale=1400:1400" -q:v 2 -y "$output_thumb" 2>/dev/null
        if [ -f "$output_thumb" ]; then
            log SUCCESS "Square thumbnail created"
            return 0
        else
            log WARN "Failed to create square thumbnail"
        fi
    else
        log WARN "Thumbnail file not found"
    fi
    return 1
}

# Function to display file info
display_file_info() {
    local file="$1"
    local file_size=$(ls -lh "$file" 2>/dev/null | awk '{print $5}')
    local file_name=$(basename "$file")
    
    echo -e "  ${GREEN}${CHECK_MARK}${NC} $file_name ${CYAN}[$file_size]${NC}"
}

# Function to display metadata
display_metadata() {
    local file="$1"
    local format="$2"
    
    echo -e "\n  ${METADATA_ICON} Metadata for: $(basename "$file")"
    
    if [ "$format" = "mp3" ]; then
        if [ "$HAS_JQ" -eq 1 ]; then
            local metadata=$(ffprobe -v quiet -print_format json -show_format "$file" 2>/dev/null | jq -r '.format.tags // {}')
            if [ -n "$metadata" ] && [ "$metadata" != "{}" ]; then
                echo "$metadata" | jq -r 'to_entries[] | "    \(.key): \(.value)"' 2>/dev/null | head -10
            else
                echo "    No metadata found"
            fi
        else
            ffprobe -v quiet -show_entries format_tags "$file" 2>/dev/null | grep -E "TAG:" | sed 's/TAG:/    /' | head -10
        fi
    elif [ "$format" = "mp4" ] && [ "$HAS_ATOMICPARSLEY" -eq 1 ]; then
        AtomicParsley "$file" -t 2>/dev/null | grep -E "Atom|Artist|Album|Year|Genre|Comment" | sed 's/^/    /' | head -10
    fi
}

# Function to create spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Default values
OUTPUT_DIR="."
CONTAINER_FORMAT="mp4"
DOWNLOAD_SUBS=""
DOWNLOAD_ALL_SUBS=""
EMBED_THUMBNAIL="--write-thumbnail"  # Enabled by default
EMBED_METADATA="--embed-metadata --write-info-json"  # Enabled by default
PLAYLIST_MODE=""
AUDIO_ONLY=""
MP3_MODE=""
AUDIO_QUALITY="0"
SQUARE_THUMB=""
PREFERRED_RES=""
PREFERRED_CODEC=""
CUSTOM_FILENAME=""
KEEP_FILES=""
VERBOSE=""
CUSTOM_ARTIST=""
CUSTOM_ALBUM=""
CUSTOM_YEAR=""
CUSTOM_GENRE=""
CUSTOM_COMMENT=""
IS_COMPILATION=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--format)
            CONTAINER_FORMAT="$2"
            shift 2
            ;;
        -s|--subtitles)
            DOWNLOAD_SUBS="--write-subs --sub-langs en,en-US"
            shift
            ;;
        -S|--subtitles-all)
            DOWNLOAD_ALL_SUBS="--write-subs --all-subs"
            shift
            ;;
        -t|--thumbnail)
            EMBED_THUMBNAIL="--write-thumbnail"  # Already enabled by default
            shift
            ;;
        --no-thumbnail)
            EMBED_THUMBNAIL=""  # Disable thumbnail
            shift
            ;;
        -m|--metadata)
            EMBED_METADATA="--embed-metadata --write-info-json"  # Already enabled by default
            shift
            ;;
        --no-metadata)
            EMBED_METADATA=""  # Disable metadata
            shift
            ;;
        -p|--playlist)
            PLAYLIST_MODE="--yes-playlist"
            shift
            ;;
        -a|--audio-only)
            AUDIO_ONLY="1"
            shift
            ;;
        --mp3)
            MP3_MODE="1"
            AUDIO_ONLY="1"
            # Metadata and thumbnail already enabled by default
            shift
            ;;
        -q|--quality)
            AUDIO_QUALITY="$2"
            shift 2
            ;;
        --square-thumb)
            SQUARE_THUMB="1"
            shift
            ;;
        -r|--resolution)
            PREFERRED_RES="$2"
            shift 2
            ;;
        -c|--codec)
            PREFERRED_CODEC="$2"
            shift 2
            ;;
        -n|--filename)
            CUSTOM_FILENAME="$2"
            shift 2
            ;;
        -k|--keep-files)
            KEEP_FILES="--keep-video"
            shift
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        --artist)
            CUSTOM_ARTIST="$2"
            shift 2
            ;;
        --album)
            CUSTOM_ALBUM="$2"
            shift 2
            ;;
        --year)
            CUSTOM_YEAR="$2"
            shift 2
            ;;
        --genre)
            CUSTOM_GENRE="$2"
            shift 2
            ;;
        --comment)
            CUSTOM_COMMENT="$2"
            shift 2
            ;;
        --compilation)
            IS_COMPILATION="1"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

# Add start time for duration calculation
start_time=$(date +%s)

# Clear screen for better presentation
clear

print_header "YouTube Downloader - Starting"

# Check if URL is provided
if [ -z "$URL" ]; then
    log ERROR "No URL provided"
    usage
    exit 1
fi

# Validate container format (only for video mode)
if [ -z "$AUDIO_ONLY" ] && [[ ! "$CONTAINER_FORMAT" =~ ^(mp4|mkv|webm)$ ]]; then
    log ERROR "Invalid container format. Use 'mp4', 'mkv', or 'webm'"
    exit 1
fi

# Check dependencies
check_dependencies

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
if [ $? -eq 0 ]; then
    log SUCCESS "Output directory ready: $OUTPUT_DIR"
else
    log ERROR "Failed to create output directory: $OUTPUT_DIR"
    exit 1
fi

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
log INFO "Temporary directory: $TEMP_DIR"

# Display download configuration
display_summary

# Build format selection string
if [ -n "$MP3_MODE" ]; then
    FORMAT_SELECTION="bestaudio[ext=m4a]/bestaudio[ext=webm]/bestaudio[ext=opus]/bestaudio"
elif [ -n "$AUDIO_ONLY" ]; then
    FORMAT_SELECTION="bestaudio[ext=m4a]/bestaudio[ext=webm]/bestaudio[ext=opus]/bestaudio"
else
    FORMAT_SELECTION=""
    CODEC_PREF=""
    if [ -n "$PREFERRED_CODEC" ]; then
        case "$PREFERRED_CODEC" in
            h264|avc1) CODEC_PREF="[vcodec^=avc1]" ;;
            h265|hevc) CODEC_PREF="[vcodec^=hev1]" ;;
            av1) CODEC_PREF="[vcodec^=av01]" ;;
            vp9) CODEC_PREF="[vcodec^=vp9]" ;;
        esac
    fi
    
    if [ -n "$PREFERRED_RES" ]; then
        case "$PREFERRED_RES" in
            4K|4k|2160) RES_HEIGHT="2160" ;;
            1440|2K|2k) RES_HEIGHT="1440" ;;
            1080|FHD|fhd) RES_HEIGHT="1080" ;;
            720|HD|hd) RES_HEIGHT="720" ;;
            *) RES_HEIGHT="$PREFERRED_RES" ;;
        esac
        FORMAT_SELECTION="bestvideo[height<=${RES_HEIGHT}]${CODEC_PREF}+bestaudio/best[height<=${RES_HEIGHT}]${CODEC_PREF}/bestvideo${CODEC_PREF}+bestaudio/best"
    else
        FORMAT_SELECTION="bestvideo${CODEC_PREF}+bestaudio/best${CODEC_PREF}/bestvideo+bestaudio/best"
    fi
fi

# Build output filename template
if [ -n "$CUSTOM_FILENAME" ]; then
    OUTPUT_TEMPLATE="$TEMP_DIR/${CUSTOM_FILENAME}.%(ext)s"
else
    if [ -n "$PLAYLIST_MODE" ]; then
        OUTPUT_TEMPLATE="$TEMP_DIR/%(playlist)s/%(playlist_index)03d - %(title)s.%(ext)s"
    else
        OUTPUT_TEMPLATE="$TEMP_DIR/%(title)s.%(ext)s"
    fi
fi

# Build the complete yt-dlp command
YT_DLP_CMD="yt-dlp"
YT_DLP_CMD="$YT_DLP_CMD --format \"$FORMAT_SELECTION\""
if [ -z "$MP3_MODE" ] && [ -z "$AUDIO_ONLY" ]; then
    YT_DLP_CMD="$YT_DLP_CMD --merge-output-format $CONTAINER_FORMAT"
fi
YT_DLP_CMD="$YT_DLP_CMD --output \"$OUTPUT_TEMPLATE\""
YT_DLP_CMD="$YT_DLP_CMD --no-playlist"
[ -n "$PLAYLIST_MODE" ] && YT_DLP_CMD="$YT_DLP_CMD $PLAYLIST_MODE"
[ -n "$DOWNLOAD_SUBS" ] && [ -z "$AUDIO_ONLY" ] && YT_DLP_CMD="$YT_DLP_CMD $DOWNLOAD_SUBS --embed-subs"
[ -n "$DOWNLOAD_ALL_SUBS" ] && [ -z "$AUDIO_ONLY" ] && YT_DLP_CMD="$YT_DLP_CMD $DOWNLOAD_ALL_SUBS --embed-subs"
[ -n "$EMBED_THUMBNAIL" ] && YT_DLP_CMD="$YT_DLP_CMD $EMBED_THUMBNAIL --convert-thumbnails jpg"
[ -n "$EMBED_METADATA" ] && YT_DLP_CMD="$YT_DLP_CMD $EMBED_METADATA"
[ -n "$KEEP_FILES" ] && YT_DLP_CMD="$YT_DLP_CMD $KEEP_FILES"
[ -n "$VERBOSE" ] && YT_DLP_CMD="$YT_DLP_CMD $VERBOSE"
YT_DLP_CMD="$YT_DLP_CMD --audio-quality 0"
if [ -z "$MP3_MODE" ] && [ -z "$AUDIO_ONLY" ]; then
    YT_DLP_CMD="$YT_DLP_CMD --remux-video $CONTAINER_FORMAT"
fi
# Force audio extraction for MP3 mode
if [ -n "$MP3_MODE" ]; then
    YT_DLP_CMD="$YT_DLP_CMD --extract-audio --keep-video"
fi
YT_DLP_CMD="$YT_DLP_CMD --retries 10"
YT_DLP_CMD="$YT_DLP_CMD --fragment-retries 10"
YT_DLP_CMD="$YT_DLP_CMD --concurrent-fragments 4"
YT_DLP_CMD="$YT_DLP_CMD --user-agent \"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\""

# Add progress bar
if [ -z "$VERBOSE" ]; then
    YT_DLP_CMD="$YT_DLP_CMD --progress --newline"
fi

# Execute the download
print_subheader "Downloading Content"
log DOWNLOAD "Starting download from: $URL"
echo ""

if [ -n "$VERBOSE" ]; then
    eval "$YT_DLP_CMD \"$URL\""
else
    eval "$YT_DLP_CMD \"$URL\"" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"[download]"* ]]; then
            # Extract percentage if present
            if [[ "$line" =~ ([0-9]+\.[0-9]+%) ]]; then
                percent="${BASH_REMATCH[1]}"
                echo -ne "\r${PURPLE}${DOWNLOAD_ICON}${NC} Downloading: ${CYAN}${percent}${NC} "
            elif [[ "$line" == *"Destination:"* ]]; then
                filename=$(echo "$line" | sed 's/.*Destination: //')
                filename=$(basename "$filename")
                echo -e "\n${BLUE}${INFO}${NC} File: $filename"
            fi
        elif [[ "$line" == *"[Merger]"* ]]; then
            echo -e "\n${CYAN}${PROCESSING_ICON}${NC} Merging video and audio streams..."
        elif [[ "$line" == *"ERROR"* ]]; then
            echo -e "\n${RED}${CROSS_MARK}${NC} $line"
        fi
    done
    echo ""
fi

# Check if download was successful
if [ $? -eq 0 ]; then
    log SUCCESS "Download completed successfully!"
    
    # Process MP3 files
    if [ -n "$MP3_MODE" ]; then
        print_subheader "Converting to MP3"
        
        # Count files to process
        total_files=$(find "$TEMP_DIR" -type f \( -name "*.m4a" -o -name "*.webm" -o -name "*.opus" \) | wc -l)
        processed=0
        
        # Process each downloaded audio file
        find "$TEMP_DIR" -type f \( -name "*.m4a" -o -name "*.webm" -o -name "*.opus" \) | while read -r audio_file; do
            if [ -f "$audio_file" ]; then
                processed=$((processed + 1))
                base_name=$(basename "$audio_file" | sed 's/\.[^.]*$//')
                info_file="${audio_file%.*}.info.json"
                thumb_file="${audio_file%.*}.jpg"
                
                # Determine output path
                rel_path="${audio_file#$TEMP_DIR/}"
                rel_dir=$(dirname "$rel_path")
                if [ "$rel_dir" = "." ]; then
                    output_file="$OUTPUT_DIR/$base_name.mp3"
                else
                    mkdir -p "$OUTPUT_DIR/$rel_dir"
                    output_file="$OUTPUT_DIR/$rel_dir/$base_name.mp3"
                fi
                
                echo -e "\n${CYAN}[${processed}/${total_files}]${NC} Processing: $base_name"
                
                # Extract metadata from info.json
                if [ -f "$info_file" ] && [ "$HAS_JQ" -eq 1 ]; then
                    title=$(jq -r '.title // empty' "$info_file")
                    uploader=$(jq -r '.uploader // empty' "$info_file")
                    upload_date=$(jq -r '.upload_date // empty' "$info_file" | sed 's/\(....\).*/\1/')
                    description=$(jq -r '.description // empty' "$info_file" | head -c 255)
                    playlist_title=$(jq -r '.playlist_title // empty' "$info_file")
                    playlist_index=$(jq -r '.playlist_index // empty' "$info_file")
                    
                    if [[ "$title" =~ ^(.+)\ -\ (.+)$ ]]; then
                        parsed_artist="${BASH_REMATCH[1]}"
                        parsed_title="${BASH_REMATCH[2]}"
                    else
                        parsed_artist="$uploader"
                        parsed_title="$title"
                    fi
                else
                    parsed_artist=""
                    parsed_title=""
                    title=""
                    upload_date=""
                    description=""
                    playlist_title=""
                    playlist_index=""
                fi
                
                # Process thumbnail to square format
                square_thumb="${thumb_file%.jpg}_square.jpg"
                if [ -f "$thumb_file" ]; then
                    process_square_thumbnail "$thumb_file" "$square_thumb" && thumb_file="$square_thumb"
                fi
                
                # Build ffmpeg metadata arguments
                FFMPEG_METADATA_ARGS=""
                [ -n "${CUSTOM_ARTIST:-$parsed_artist}" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata artist=\"${CUSTOM_ARTIST:-$parsed_artist}\""
                [ -n "${CUSTOM_ALBUM:-$playlist_title}" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata album=\"${CUSTOM_ALBUM:-$playlist_title}\""
                [ -n "${parsed_title:-$title}" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata title=\"${parsed_title:-$title}\""
                [ -n "${CUSTOM_YEAR:-$upload_date}" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata date=\"${CUSTOM_YEAR:-$upload_date}\""
                [ -n "$CUSTOM_GENRE" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata genre=\"$CUSTOM_GENRE\""
                [ -n "${CUSTOM_COMMENT:-$description}" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata comment=\"${CUSTOM_COMMENT:-$description}\""
                [ -n "$playlist_index" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata track=\"$playlist_index\""
                [ -n "$IS_COMPILATION" ] && FFMPEG_METADATA_ARGS="$FFMPEG_METADATA_ARGS -metadata compilation=\"$IS_COMPILATION\""
                
                # Convert to MP3
                log PROCESS "Converting to MP3..."
                if [ -f "$thumb_file" ]; then
                    eval "ffmpeg -i \"$audio_file\" -i \"$thumb_file\" -map 0:a -map 1:v -c:a libmp3lame -q:a $AUDIO_QUALITY -id3v2_version 3 -c:v copy $FFMPEG_METADATA_ARGS -y \"$output_file\"" 2>/dev/null
                else
                    eval "ffmpeg -i \"$audio_file\" -c:a libmp3lame -q:a $AUDIO_QUALITY -id3v2_version 3 $FFMPEG_METADATA_ARGS -y \"$output_file\"" 2>/dev/null
                fi
                
                if [ $? -eq 0 ]; then
                    log SUCCESS "Converted to MP3: $(basename "$output_file")"
                else
                    log ERROR "Failed to convert: $(basename "$audio_file")"
                fi
            fi
        done
        
    # Process video/audio files
    else
        print_subheader "Processing Downloaded Files"
        
        # Move files from temp to output directory
        find "$TEMP_DIR" -type f \( -name "*.$CONTAINER_FORMAT" -o -name "*.m4a" -o -name "*.webm" -o -name "*.opus" \) | while read -r media_file; do
            rel_path="${media_file#$TEMP_DIR/}"
            dest_file="$OUTPUT_DIR/$rel_path"
            dest_dir=$(dirname "$dest_file")
            mkdir -p "$dest_dir"
            
            log PROCESS "Moving: $(basename "$media_file")"
            mv "$media_file" "$dest_file"
            
            # Process with AtomicParsley if available and format is MP4
            if [ "$HAS_ATOMICPARSLEY" -eq 1 ] && [ "$CONTAINER_FORMAT" = "mp4" ] && [ -n "$EMBED_METADATA" ] && [[ "$dest_file" == *.mp4 ]]; then
                info_file="${media_file%.*}.info.json"
                thumb_file="${media_file%.*}.jpg"
                
                # Process square thumbnail if requested
                if [ -n "$SQUARE_THUMB" ] && [ -f "$thumb_file" ]; then
                    square_thumb="${thumb_file%.jpg}_square.jpg"
                    process_square_thumbnail "$thumb_file" "$square_thumb" && thumb_file="$square_thumb"
                fi
                
                # Apply metadata with AtomicParsley
                if [ -f "$info_file" ] && [ "$HAS_JQ" -eq 1 ]; then
                    log PROCESS "Embedding metadata with AtomicParsley..."
                    
                    # Extract metadata
                    title=$(jq -r '.title // empty' "$info_file")
                    uploader=$(jq -r '.uploader // empty' "$info_file")
                    upload_date=$(jq -r '.upload_date // empty' "$info_file" | sed 's/\(....\).*/\1/')
                    description=$(jq -r '.description // empty' "$info_file" | head -c 255)
                    playlist_title=$(jq -r '.playlist_title // empty' "$info_file")
                    
                    # Build AtomicParsley command
                    AP_CMD="AtomicParsley \"$dest_file\" --overWrite"
                    [ -n "${CUSTOM_ARTIST:-$uploader}" ] && AP_CMD="$AP_CMD --artist \"${CUSTOM_ARTIST:-$uploader}\""
                    [ -n "${CUSTOM_ALBUM:-$playlist_title}" ] && AP_CMD="$AP_CMD --album \"${CUSTOM_ALBUM:-$playlist_title}\""
                    [ -n "$title" ] && AP_CMD="$AP_CMD --title \"$title\""
                    [ -n "${CUSTOM_YEAR:-$upload_date}" ] && AP_CMD="$AP_CMD --year \"${CUSTOM_YEAR:-$upload_date}\""
                    [ -n "$CUSTOM_GENRE" ] && AP_CMD="$AP_CMD --genre \"$CUSTOM_GENRE\""
                    [ -n "${CUSTOM_COMMENT:-$description}" ] && AP_CMD="$AP_CMD --comment \"${CUSTOM_COMMENT:-$description}\""
                    [ -n "$uploader" ] && AP_CMD="$AP_CMD --albumArtist \"$uploader\""
                    
                    # Add thumbnail if available
                    if [ -f "$thumb_file" ]; then
                        AP_CMD="$AP_CMD --artwork \"$thumb_file\""
                    fi
                    
                    # Execute AtomicParsley
                    eval $AP_CMD 2>/dev/null
                    [ $? -eq 0 ] && log SUCCESS "Metadata embedded"
                fi
            fi
        done
    fi
    
    # Final summary
    print_subheader "Download Summary"
    
    # Count and display downloaded files
    if [ -n "$MP3_MODE" ]; then
        mp3_count=$(find "$OUTPUT_DIR" -name "*.mp3" -type f -mmin -5 | wc -l)
        log SUCCESS "Downloaded $mp3_count MP3 file(s)"
        
        if [ -n "$VERBOSE" ] || [ $mp3_count -le 10 ]; then
            echo ""
            echo "Downloaded files:"
            find "$OUTPUT_DIR" -name "*.mp3" -type f -mmin -5 | sort | while read -r mp3_file; do
                display_file_info "$mp3_file"
                [ -n "$VERBOSE" ] && display_metadata "$mp3_file" "mp3"
            done
        fi
    else
        file_count=$(find "$OUTPUT_DIR" -type f \( -name "*.$CONTAINER_FORMAT" -o -name "*.m4a" -o -name "*.webm" \) -mmin -5 | wc -l)
        log SUCCESS "Downloaded $file_count file(s)"
        
        if [ -n "$VERBOSE" ] || [ $file_count -le 10 ]; then
            echo ""
            echo "Downloaded files:"
            find "$OUTPUT_DIR" -type f \( -name "*.$CONTAINER_FORMAT" -o -name "*.m4a" -o -name "*.webm" \) -mmin -5 | sort | while read -r media_file; do
                display_file_info "$media_file"
                if [ -n "$VERBOSE" ]; then
                    ext="${media_file##*.}"
                    display_metadata "$media_file" "$ext"
                fi
            done
        fi
    fi
    
    # Storage summary
    echo ""
    total_size=$(find "$OUTPUT_DIR" -type f -mmin -5 \( -name "*.mp3" -o -name "*.$CONTAINER_FORMAT" -o -name "*.m4a" -o -name "*.webm" \) -exec du -ch {} + 2>/dev/null | grep total$ | awk '{print $1}')
    [ -n "$total_size" ] && log INFO "Total size: $total_size"
    log INFO "Location: $OUTPUT_DIR"
    
else
    log ERROR "Download failed!"
    print_subheader "Troubleshooting Tips"
    echo "1. Check if the URL is valid and accessible"
    echo "2. Ensure you have a stable internet connection"
    echo "3. Try updating yt-dlp: pip install -U yt-dlp"
    echo "4. Check if the video is age-restricted or private"
    echo "5. Run with -v flag for detailed error information"
fi

# Cleanup
print_subheader "Cleaning Up"
log PROCESS "Removing temporary files..."

# Clean up info.json files if not keeping intermediate files
if [ -z "$KEEP_FILES" ] && [ -n "$EMBED_METADATA" ]; then
    find "$OUTPUT_DIR" -name "*.info.json" -type f -mmin -5 -delete 2>/dev/null
    find "$TEMP_DIR" -name "*.info.json" -type f -delete 2>/dev/null
fi

# Clean up temporary thumbnails
find "$TEMP_DIR" -name "*.jpg" -type f -delete 2>/dev/null
find "$TEMP_DIR" -name "*.webp" -type f -delete 2>/dev/null

# Remove temp directory
if rm -rf "$TEMP_DIR" 2>/dev/null; then
    log SUCCESS "Cleanup completed"
else
    log WARN "Could not remove temp directory: $TEMP_DIR"
fi

# Show completion time
end_time=$(date +%s)
if [ -n "$start_time" ]; then
    duration=$((end_time - start_time))
    minutes=$((duration / 60))
    seconds=$((duration % 60))
    echo ""
    log INFO "Total time: ${minutes}m ${seconds}s"
fi

# Final message
print_header "Download Complete!"

# Show tips based on what was downloaded
if [ -n "$MP3_MODE" ]; then
    echo ""
    echo -e "${GREEN}Tips:${NC}"
    echo "• Your MP3 files include square album art and metadata"
    echo "• They're ready for any music player or library"
    echo "• Use a tool like MusicBrainz Picard for additional tagging"
else
    echo ""
    echo -e "${GREEN}Tips:${NC}"
    echo "• Metadata and thumbnails are embedded by default"
    echo "• Use --no-metadata or --no-thumbnail to disable"
    echo "• Videos are ready for media servers like Plex or Jellyfin"
fi

# Optional dependency reminder
if ([ "$HAS_ATOMICPARSLEY" -eq 0 ] || [ "$HAS_JQ" -eq 0 ]) && ([ "$CONTAINER_FORMAT" = "mp4" ] || [ -n "$MP3_MODE" ]); then
    echo ""
    echo -e "${YELLOW}Reminder:${NC} Install optional tools for better features:"
    [ "$HAS_ATOMICPARSLEY" -eq 0 ] && [ "$CONTAINER_FORMAT" = "mp4" ] && echo "  • AtomicParsley - Better MP4 metadata"
    [ "$HAS_JQ" -eq 0 ] && echo "  • jq - Better metadata extraction"
fi

echo ""
exit 0
