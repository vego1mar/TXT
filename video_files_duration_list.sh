#!/bin/bash
#!/bin/grep
#!/bin/sed
#!/bin/ls
#!/usr/bin/ffmpeg
#!/usr/bin/ffprobe
#!/usr/bin/printf
#!/usr/bin/echo
#!/usr/bin/cut
#!/usr/bin/bc
#!/usr/bin/wc

# Searches for .mp4 or .webm video files in the current directory.
# Outputs files durations.
NUMBER_OF_FILES="$(ls -1 | wc -l)"
CURRENT_DURATION=None
FILENAMES=()
DURATIONS=()

function populate_filenames() {
    # "$1" should be a video file extension
    for entry in ./*."$1"
    do
        local length=${#entry}
        local substring=${entry:2:length}

        if [ -f "$substring" ]; then
            FILENAMES+=("$substring")
        fi
    done
}

function set_mp4_duration() {
    local filename="$1"
    local evaluate=$(ffmpeg -i "$filename" 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//)
    local valid_length=${#evaluate}-3
    local valid_substring=${evaluate:0:valid_length}
    CURRENT_DURATION="$valid_substring"
}

function set_webm_duration() {
    local fn="$1"
    local evaluate=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$fn")
    convert_ffprobe_duration "$evaluate"
}

function convert_ffprobe_duration() {
    local seconds="$1"
    local minutes=$(echo "scale=2; $seconds / 60" | bc -l)
    local hours=$(echo "scale=2; $minutes / 60" | bc -l)
    local hours_int=$(echo "scale=0; $minutes / 60" | bc -l)
    local minutes_int=$(printf "%.0f\n" "$(echo "scale=2; ($hours - $hours_int) * 60" | bc -l)")
    local min_tdiv=$(echo "scale=0; $minutes / 1" | bc -l)
    local seconds_int=$(printf "%.0f\n" "$(echo "scale=2; ($minutes - $min_tdiv) * 60" | bc -l)")

    if [ $hours_int -le 9 ]; then
        hours_int=0"$hours_int"
    fi

    if [ $minutes_int -le 9 ]; then
        minutes_int=0"$minutes_int"
    fi

    if [ $seconds_int -le 9 ]; then
        seconds_int=0"$seconds_int"
    fi

    local result_string=$hours_int:$minutes_int:$seconds_int
    CURRENT_DURATION="$result_string"
}

function collect_durations() {
    # $1=webm or $1=mp4
    local filenames_size=${#FILENAMES[@]}

    for ((i = 0; i < $filenames_size; i++)); do
        if [ "$1" == "webm" ]; then
            set_webm_duration "${FILENAMES[$i]}"
            DURATIONS+=("$CURRENT_DURATION")
            continue
        fi

        set_mp4_duration "${FILENAMES[$i]}"
        DURATIONS+=("$CURRENT_DURATION")
    done
}

function clear_data_for_next_population {
    CURRENT_DURATION=None
    FILENAMES=()
    DURATIONS=()
}

function print_info {
    echo Number of files: "$NUMBER_OF_FILES"
    echo Files found: "${#FILENAMES[@]}"
    echo
}

function print_durations_info_1 {
    local durations_size=${#DURATIONS[@]}

    for ((i = 0; i < $durations_size; i++)); do
        echo "${DURATIONS[$i]}" "${FILENAMES[$i]}"
    done    

    echo
}

function print_durations_info_2 {
    local durations_size=${#DURATIONS[@]}

    for ((i = 0; i < $durations_size; i++)); do
        echo "${DURATIONS[$i]}"
        echo "${FILENAMES[$i]}"
        echo
    done    
}

function switch_info_printing() {
    if [ "$1" == 'info1' ]; then
        print_durations_info_1
        exit
    elif [ "$1" == 'info2' ]; then
        print_durations_info_2
        exit
    fi

    echo
    print_durations_info_1
    echo
    print_durations_info_2
}

function __main() {
    populate_filenames mp4
    collect_durations mp4
    print_info
    switch_info_printing "$@"
    clear_data_for_next_population
    populate_filenames webm
    collect_durations webm
    print_info
    switch_info_printing "$@"
}

__main "$@"
