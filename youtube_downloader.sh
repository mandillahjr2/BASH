#using below instead of /bin/bash to make it more portable to various shells
#!/usr/bin/env /bash

#function to download song
download_song(){
    local url="$1"
    local format="$2"
    local metadata="$3"
    local thumbnail="$4"

    echo "Downloading song..."

    #Build youtube-dl command on user preference
    command="yt-dlp -x --audio-format $format -o '$HOME/Music/%(title)s.%(ext)s'"

    #Embed metadata if enabled
    if [[ "$metadata" == "y" ]]; then
        command+=" --add-metadata"
    fi

    #Embed thumbnail if available
    if [[ "$thumbnail" == "y" ]]; then
        command+=" --embed-thumbnail"
    fi

    #Add URL to command and execute
    command+=" $url"
    eval $command

    if [ $? -eq 0 ]; then
        echo "Download complete!"
    else
        echo "Download failed! Check URL and try again."
    fi
}

#Main script
echo "Welcome to the YT Downloader!"

read -p "Enter the URL of the song you want to download: " url

echo "Choose the audio format:"
echo "1. MP3 (320kbps)"
echo "2. AAC (256kbps)"
echo "3. OPUS (160kbps)"
echo "4. M4A (256kbps)"
read -p "Enter your choice(1/2/3/4): " format_choice

#hardcode highest bitrate based on user format_choice
case "$format_choice" in
    1) format="mp3" bitrate="320k" ;;
    2) format="aac" bitrate="256k";;
    3) format="opus" bitrate="160k";;
    4) format="m4a" bitrate="256k";;
esac

read -p "Do you want to add metadata? (y/n): " metadata
read -p "Do you want to embed thumbnail? (y/n): " thumbnail

#start the download
download_song "$url" "$format" "$metadata" "$thumbnail"

