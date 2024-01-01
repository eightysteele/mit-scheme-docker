#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/parse.sh"
source "$DIR/assoc_multi.sh"

msd_interpret() {
    local interpret_ast="$1"
    local action=""

    action=$(assoc_multi_get "$interpret_ast" :action)

    case "$action" in
        build)
            echo "build!"
            assoc_multi_print "$interpret_ast"
            ;;
        *)
            echo "No valid action specified"
            exit 1
            ;;
    esac
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
