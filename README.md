# Video-download-scripts

# Update (29-07-2023)
# YouTube Downloader Batch Script (yt.bat)

This batch script allows you to download videos, audios, or music from YouTube using yt-dlp (an improved version of youtube-dl). It provides a simple command-line interface to choose the type of content you want to download and automatically handles invalid selections by defaulting to Option 1 (Video).

## Requirements

- Windows operating system (tested on Windows 10)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube video downloader (a more feature-rich alternative to youtube-dl)

## How to Use

1. Make sure you have [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed on your system.

2. Clone or download this repository.

3. Open a Command Prompt or PowerShell window in the directory where the batch script is located.

4. To run the script, use the following command: 
  ```
    yt.bat [YouTube-URL]
  ```
   Replace `[YouTube-URL]` with the URL of the video or audio you want to download.

6. The script will prompt you to choose an option:
- Enter `1` for Video
- Enter `2` for Audio
- Enter `3` for Music (with square thumbnail)

6. If you don't enter any option or provide an invalid option, the script will automatically default to downloading the video (Option 1).

7. The downloaded files will be saved in the same directory as the batch script.

## Command Options

The batch script uses yt-dlp to download content from YouTube. The script includes various options to enhance the downloaded files:

- Metadata Parsing: Extracts video metadata such as comments, year, and date.
- Thumbnail Embedding: Embeds the video thumbnail as the cover art in audio files.
- Subtitle Embedding: Embeds subtitles into video or audio files (English only).
- Square Thumbnail for Music: Generates a square thumbnail for music downloads.
- Other Options: Ignores errors and bypasses SSL certificate verification.

## Notes

- Make sure to comply with YouTube's terms of service when using this script.
- Use this script responsibly and respect copyright laws.
- The script is intended for personal and educational purposes only.

## Acknowledgments

- This batch script is based on the [yt-dlp](https://github.com/yt-dlp/yt-dlp) project, which provides an excellent tool for downloading YouTube videos and audio.

Feel free to contribute, report issues, or suggest improvements!




# Old Version 
### Handy Scripts files to download videos from YouTube.com and other video sites. 

## Background

[Youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html) is a famous program used for downloading videos from YouTube and many [other sites](http://ytdl-org.github.io/youtube-dl/supportedsites.html). Though alone it handles most cases but for videos of higher quality where audio is present separately we also need [FFmpeg](https://ffmpeg.org/) to merge video and audio in single file (.mp4, .mkv, etc.) in addition to this we also need [Atomic Parsley](http://atomicparsley.sourceforge.net/) which is used for adding metadata (Thumbnail, etc.) to downloaded video.

Since all this are command line programs which can be cumbersome to write each time, So I have written scripts files useful for most general cases -
* Highest Quality Audio and Video download
* English Subtitle Addition 
* Thumbnail, Metadata and xattrs embedding 
* Adding numbering to playlist videos

## Installation
1) [Download](https://github.com/akashmeshram/yt-scripts/archive/master.zip) the whole repository. 
2) Download [Youtube-dl](http://ytdl-org.github.io/youtube-dl/download.html), [FFmpeg](https://ffmpeg.org/) and [Atomic Parsley](https://sourceforge.net/projects/atomicparsley/files/).
3) Put downloaded `.exe` file of youtube-dl, `ffmpeg.exe` file from FFmpeg zip extract and `AtomicParsley.exe` file from Atomic Parsley zip extract in `./bin`.
3) Add PATH of both folders (`/bin` and `/scripts`) to Environment Variables in windows OS. ( see [How to add to path](https://helpdeskgeek.com/windows-10/add-windows-path-environment-variable/))

## Running
In cmd/Powershell type

* `yt <video link>` // for single video download

* `yt-pl <Playlist link>` // for Playlist download

* `yt-m <video link>` // for audio (m4a) file download of single video

* `yt-ml <Playlist link>` // for audio (m4a) files download of Playlist

* `yt-sc <SoundCLoud link>` // for SoundCloud (m4a) file download

* `yt-m-sqthumb <SOundCLoud link>` // for youtube audio (m4a) file download of single video with square thumbnail

## Author
[Akash Meshram](https://github.com/akashmeshram)
