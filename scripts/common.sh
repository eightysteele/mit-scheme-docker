#!/bin/bash

DEBUG_LOGGING=0
DEBUG_SCRIPT_NAME=""
DEBUG_FUNC_PREFIX=""

common_debug_enable() {
    echo "HI"
    DEBUG_LOGGING=1
    DEBUG_SCRIPT_NAME="${1:-}"
    DEBUG_FUNC_PREFIX="${2:-}"
}

common_debug_disable() {
    DEBUG_LOGGING=0
    DEBUG_SCRIPT_NAME=""
    DEBUG_FUNC_PREFIX=""
}

common_debug_log() {
    echo ""
    echo "YO"
    echo "debug $DEBUG_LOGGING"
    echo "debug_script $DEBUG_SCRIPT_NAME"
    echo "bash_source ${BASH_SOURCE[1]}"
    echo "function ${FUNCNAME[1]}"
    echo "prefix $DEBUG_FUNC_PREFIX"

    if [[ "$DEBUG_LOGGING" == "1" ]]; then
        local should_log=1

        # if [[ -n "$DEBUG_SCRIPT_NAME" && "${BASH_SOURCE[1]}" != *"$DEBUG_SCRIPT_NAME"* ]]; then
        #     should_log=0
        #     echo "no log 1"
        # fi

        # if [[ -n "$DEBUG_FUNC_PREFIX" && "${FUNCNAME[1]}" != "$DEBUG_FUNC_PREFIX"* ]]; then
        #     should_log=0
        #     echo "no log 2"
        # fi

        if [[ "$should_log" -eq 1 ]]; then
            echo "Function: ${FUNCNAME[1]}, Command: $BASH_COMMAND" #>> /path/to/debug.log
        fi
    fi
}

trap common_debug_log DEBUG

common_bail() {
    echo -e "Error: $1 \nHelp: msd -h" >&2
    exit 1
}
