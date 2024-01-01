#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/parse.sh"
source "$DIR/assoc_multi.sh"
source "$DIR/build_action.sh"

msd_exit() {
    local fn="$1"
    local status="${2:-0}"
    local msg=""

    msg=$("$fn")
    echo "$msg"
    exit "$status"
}

msd_interpret() {
    local ast="$1"
    local action=""

    action=$(assoc_multi_get "$ast" :action)

    case "$action" in
        build)
            msd_interpret_build "$ast"
            ;;
        *)
            echo "No valid action specified"
            exit 1
            ;;
    esac
}

msd_interpret_build() {
    local ast="$1"
    local options=()

    assoc_multi_print "$ast"

    read -r -a options <<< "$(assoc_multi_get "$ast" :primary_options)"

    for option in "${options[@]}"; do
        case "$option" in
            -h)
                msd_exit build_action_help
                ;;
            -d)
                echo "dry run!"
                ;;
            *)
                echo "no options, gtg!"
                ;;
        esac
    done
}

msd_execute() {
    local -a command_line_tokens=()
    local -a ast=()

    IFS=' ' read -r -a command_line_tokens <<< "$@"
    parse_command_line ast "${command_line_tokens[@]}"
    msd_interpret ast
}

msd_execute "$@"

# 142
# 126
# 144
# 154
# 180
