#!/bin/bash

source ./assoc_multi.sh
source ./assoc.sh
source ./common.sh
source ./validate.sh

parse_command_line() {
    local ast_ref="$1"
    shift 1

    local -a ast=()
    local action=""
    local primary_option_tokens=()

    validate_action_token "$1"
    action="$1"
    assoc_multi ast :action "$action"
    shift 1

    read -r -a primary_option_tokens <<< "$(_parse_primary_options "$@")"
    shift "${#primary_option_tokens[@]}"

    case "$action" in
        build)
            validate_build_option_tokens "${primary_option_tokens[@]}"
            for option in "${primary_option_tokens[@]}"; do
                assoc_multi ast :primary_option_tokens "$option"
            done

            validate_build_arg_tokens "$@"
            assoc_multi ast :image_name "$1"
            assoc_multi ast :runtime "$2"
            assoc_multi ast :file_path "$3"
            shift 3
    esac

    _parse_passthrough_options "$@"

    #print_map_multi ast

    eval "$ast_ref=(\"\${ast[@]}\")"
    #local ast_str=$(IFS=,; echo "${ast[*]}")
    #eval "$ast_ref=\"$ast_str\""
}


# parses any passthrough options for docker and the repl, and updates the AST.
_parse_passthrough_options() {
    local tokens=()
    local str=""
    local count=0

    # docker...
    read -r -a tokens <<< "$(_parse_passthrough_option_tokens "$@")"
    str=$(IFS=" "; echo "${tokens[*]}")
    count="${#tokens[@]}"

    assoc_multi ast :docker_options "$str"

    if [[ $count -ne 0 ]]; then
        (( count++ ))
        shift "$count"
    fi

    # repl...
    read -r -a tokens <<< "$(_parse_passthrough_option_tokens "$@")"
    str=$(IFS=" "; echo "${tokens[*]}")
    count="${#tokens[@]}"

    assoc_multi ast :repl_options "$str"
}

# parses any passthrough options that exist between -- separators
_parse_passthrough_option_tokens() {
    local token=""
    local -a tokens=()

    if [[ "$1" == "--" ]]; then
        shift 1
    else
        echo ""
        return 0
    fi

    while [[ $# -gt 0 ]]; do
        token="$1"
        if [[ "$token" != "--" ]]; then
            tokens+=("$token")
            shift
        else
            break
        fi
    done

    echo "${tokens[@]}"
    return 0
}

# parses primary options passed into the action
_parse_primary_options() {
    local option=""
    local -a options=()
    local regex="^(-[a-zA-Z]|--[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*)$"

    while [[ $# -gt 0 ]]; do
        option="$1"
        if [[ $option =~ $regex ]]; then
            options+=("$option")
            shift
        else
            break
        fi
    done

    echo "${options[@]}"
    return 0
}

#cmdline="build -d -h eighty:dev mit-scheme ../mit-scheme/Dockerfile -- --memory 4000 -- --load foo.scm"
#cmdline="$@"
#IFS=' ' read -r -a cmdline_args <<< "$cmdline"  # Safely convert to array
#parse_command_line "${cmdline_args[@]}"

#print_map grammar
