#!/bin/bash
#!/usr/bin/expr
#!/usr/bin/echo
#!/usr/bin/ffmpeg

# Use './script.sh --help' command for a brief info.
EXTENSION="webm"

function print_in_red() {
    local text="$1"
    local red='\033[0;31m'
    local no_color='\033[0m'
    echo -e "${red}$text${no_color}"
}

function print_in_green() {
    local text="$1"
    local green='\033[0;32m'
    local no_color='\033[0m'
    echo -e "${green}$text${no_color}"
}

function check_arg() {
    local file_name="$@"
    local length=${#file_name}

    if [[ "$file_name" == "--help" ]]; then
        print_help
        exit 3
    fi

    if [ ! -f "$file_name" ]; then
        print_in_red "An argument as a file name is required!"
        exit 1
    fi

    if [ $length -le 4 ]; then
        print_in_red "File name must go with their respective extension!"
        exit 2
    fi
}

function print_help {
    echo "Converts .webm and .mp4 video streams into an .ogg audio file.

Usage:
    ./convert.sh video_file.mp4
    ./convert.sh \"video file 2.webm\"
    ./convert.sh --help"
}

function is_file_with_extension_of() {
    local file="$@"
    local length=${#file}
    local to_cut=${#EXTENSION}
    local lhs=$(expr $length - $to_cut - 1)
    local extension=${file:lhs:length}
    local expected="."${EXTENSION}

    if [ $extension == $expected ]; then
        echo "True"
        return 1
    fi

    echo "False"
    return 0
}

function switch_convertion() {
    EXTENSION="webm"
    local is_webm=$(is_file_with_extension_of "$@")
    EXTENSION="mp4"
    local is_mp4=$(is_file_with_extension_of "$@")

    if [[ "$is_webm" == "True" ]]; then
        convert_webm_into_ogg "$@"
    elif [[ "$is_mp4" == "True" ]]; then
        convert_mp4_into_ogg "$@"
    fi
}

function convert_webm_into_ogg() {
    local file="$@"
    local evaluate=$(ffmpeg -i "${file}" -vn -y "${file}.ogg")
}

function convert_mp4_into_ogg() {
    local file="$@"
    local evaluate=$(ffmpeg -i "${file}" -vn -acodec libvorbis -y "${file}.ogg")
}

function __main() {
    check_arg "$@"
    switch_convertion "$@"
    print_in_green "Script done."
}


__main "$@"
