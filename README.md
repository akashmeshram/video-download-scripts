# Video Download Scripts

A collection of scripts for downloading videos, music, and audio from YouTube and other platforms using yt-dlp.

## Table of Contents

- [Overview](#overview)
- [Linux GUI Downloader (yt.sh)](#youtube-downloader-gui-for-linux-ytsh)
- [Windows Batch Script (yt.bat)](#youtube-downloader-batch-script-ytbat)
- [Legacy Scripts](#legacy-scripts)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Contributing](#contributing)

## Overview

This repository contains various scripts to simplify downloading content from YouTube and other video platforms. The scripts serve as user-friendly wrappers around yt-dlp (upstream of youtube-dl), providing both GUI and command-line interfaces depending on your operating system.

## YouTube Downloader GUI for Linux (yt.sh)

This bash script provides a graphical interface for downloading videos, audios, or music from YouTube using yt-dlp and Zenity.

### Features

- ✅ Graphical user interface
- ✅ Download progress indicator
- ✅ Playlist support
- ✅ Video quality selection
- ✅ Custom download location
- ✅ Metadata and thumbnail embedding
- ✅ Subtitle integration (English)
- ✅ Error handling and reporting

### Requirements

- Linux operating system (tested on Ubuntu/Debian)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube video downloader
- [Zenity](https://wiki.gnome.org/Projects/Zenity) - GUI dialog display
- [FFmpeg](https://ffmpeg.org/) - For video/audio processing

### Installation

#### Automatic Installation

1. Download or clone this repository
2. Open a terminal in the repository directory
3. Make the installer script executable and run it:
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```
4. The script will be installed to `/usr/local/bin/yt` and available system-wide

#### Manual Installation

1. Ensure you have the required dependencies installed:

   ```bash
   sudo apt install zenity ffmpeg
   sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
   sudo chmod a+rx /usr/local/bin/yt-dlp
   ```

2. Make the script executable:

   ```bash
   chmod +x yt.sh
   ```

3. Optionally, create a symbolic link to make it available system-wide:
   ```bash
   sudo ln -s $(pwd)/yt.sh /usr/local/bin/yt
   ```

### Usage

1. If installed system-wide, simply type `yt` in your terminal
2. Otherwise, navigate to the script directory and run `./yt.sh`
3. Follow the on-screen prompts:
   - Enter a YouTube URL
   - Specify if it's a playlist (if applicable)
   - Select download type (Video/Audio/Music)
   - Choose video quality (for video downloads)
   - Select a download location
   - Monitor download progress
   - Optionally open the download location when complete

## YouTube Downloader Batch Script (yt.bat)

A Windows batch script for downloading content from YouTube with a simple command-line interface.

### Features

- ✅ Simple command-line interface
- ✅ Metadata parsing
- ✅ Thumbnail embedding
- ✅ Subtitle integration (English)
- ✅ Square thumbnail for music

### Requirements

- Windows operating system (tested on Windows 10)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube video downloader

### Installation

1. Make sure you have [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed on your system
2. Clone or download this repository

### Usage

1. Open Command Prompt or PowerShell in the directory with the script
2. Run the script with a YouTube URL:

   ```
   yt.bat [YouTube-URL]
   ```

3. Choose an option when prompted:
   - `1` for Video
   - `2` for Audio
   - `3` for Music (with square thumbnail)
4. Invalid inputs default to Video (Option 1)
5. Files are saved in the same directory as the script

## Legacy Scripts

These are the original scripts that use youtube-dl instead of yt-dlp.

### Requirements

- Windows operating system
- [Youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html)
- [FFmpeg](https://ffmpeg.org/)
- [Atomic Parsley](http://atomicparsley.sourceforge.net/)

### Installation

1. Download [Youtube-dl](http://ytdl-org.github.io/youtube-dl/download.html), [FFmpeg](https://ffmpeg.org/), and [Atomic Parsley](https://sourceforge.net/projects/atomicparsley/files/)
2. Place `.exe` files in the `./bin` directory
3. Add both folders (`/bin` and `/scripts`) to your Windows PATH environment variable

### Usage

In Command Prompt or PowerShell:

- `yt <video link>` - Download a single video
- `yt-pl <Playlist link>` - Download a playlist
- `yt-m <video link>` - Download audio (m4a) from a video
- `yt-ml <Playlist link>` - Download audio (m4a) from a playlist
- `yt-sc <SoundCloud link>` - Download SoundCloud audio (m4a)
- `yt-m-sqthumb <YouTube link>` - Download YouTube audio with square thumbnail

## Troubleshooting

### Common Issues

- **Download fails with HTTP error**: Check your internet connection or try again later
- **Script not found**: Ensure the script is executable and/or in your PATH
- **Dependencies missing**: Verify all required dependencies are installed
- **Permission denied**: Run the installation scripts with sudo (Linux) or administrator privileges (Windows)

### Updates

To update yt-dlp:

```bash
# Linux
sudo yt-dlp -U

# Windows (Command Prompt as Admin)
yt-dlp -U
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - The core tool that makes these scripts possible
- [youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html) - The original downloader
- [FFmpeg](https://ffmpeg.org/) - For video/audio processing
- [Atomic Parsley](http://atomicparsley.sourceforge.net/) - For metadata embedding
