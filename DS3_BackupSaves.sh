#!/bin/bash
#!/bin/echo
#!/usr/bin/7z

GAMESAVE_DIR="/media/moon/26509ADF509AB4D1/Users/Mar/AppData/Roaming/DarkSoulsIII"
ARCHIVE_PATH="$HOME""/Documents/Projekty/BACKUPS/Dark_Souls_III__AppData_SL${1}.7z"

function check_game_save_directory() {
    local saves_dir="$1"

    if [ ! -d "$saves_dir" ]; then
        print_in_red "Game save directory does not exist!"
        exit 1
    fi
}

function archive_game_saves() {
    local source="$1"
    local target="$2"
    local evaluate=$(7z a -t7z -mx=9 -m0=lzma -md=128m -mfb=273 -mmt=4 -ms=on "$target" "$source")
}

function print_in_green() {
    local text="$1"
    local green='\033[0;32m'
    local no_color='\033[0m'
    echo -e "${green}$text${no_color}"
}

function print_in_red() {
    local text="$1"
    local red='\033[0;31m'
    local no_color='\033[0m'
    echo -e "${red}$text${no_color}"
}


function __main() {
    check_game_save_directory "$GAMESAVE_DIR"
    print_in_green "Archiving Dark Souls III gamesaves..."
    archive_game_saves "$GAMESAVE_DIR" "$ARCHIVE_PATH"
    print_in_green "Script done."
}


__main "$@"
