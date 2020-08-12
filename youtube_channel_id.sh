#! /bin/bash

# command
# /usr/bin/youtube-dl


function is_command_existing() {
    local cmd_name="$1"

    if ! command -v "$cmd_name" &> /dev/null
    then
        echo "Command \"$cmd_name\" does not exist."
        exit
    fi
}

function get_channel_id() {
    local video_url_or_id="$1"
    local result;
    result=$(youtube-dl --get-filename -o '%(channel_id)s' "$video_url_or_id")
    echo "$result"
}

function main() {
    is_command_existing command
    is_command_existing youtube-dl
    video_url_or_id="$1"
    channel_id=$(get_channel_id "$video_url_or_id")
    echo "$channel_id"
}

main "$@"
