# Video-download-scripts

### Handy Scripts files to download videos from YouTube.com and other video sites. 

## Background

[Youtube-dl](https://ytdl-org.github.io/youtube-dl/index.html) is a famous program used for downloading videos from youtube and many [other sites](http://ytdl-org.github.io/youtube-dl/supportedsites.html). Though alone it handels most cases but for videos of higher quality where audio is present seperatly we also need [FFmpeg](https://ffmpeg.org/) to merge video and audio in single file (.mp4, .mkv etc.) in addition to this we also need [Atomic Parsley](http://atomicparsley.sourceforge.net/) which is used for adding metadata (Thumbail, etc.) to downloaded video.

Since all this are command line programs which can be cubersome to write each time, So I have written scripts files useful for most general cases -
* Highest Quality Audio and Video download
* English Subtitle Addition 
* Tumbnail and xattrs embedding 
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

* `yt-m <video link>` // for mp3 file download of single video

* `yt-ml <Playlist link>` // for mp3 files download of Playlist

## Author
[Akash Meshram](https://github.com/akashmeshram)