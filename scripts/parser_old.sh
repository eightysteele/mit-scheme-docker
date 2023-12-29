#!/bin/bash

source ./assoc_multi.sh
source ./assoc.sh
source ./grammar.sh

elements=()

parser_parse() {
    local grammar_ref="$1"
    local command_ref="$2"

    local -a grammar_rules
    eval "$grammar_rules=(\"\${$grammar_ref[@]}\")"

    local -a command_args
    eval "$command_args=(\"\${$command_ref[@]}\")"

    local order=0
    local definition

    for name in "${grammar_rules[@]}"; do
        definition=$(grammar_rule_definition "$name")
        (( order++ ))

        case "$name" in
            :msd_command)
                parse_msd_command "$order" "$definition" "${command_args[@]}"

                ;;
        esac
    done

}

# msd_command = 'msd' WS action
parse_msd_command() {
    local order="$1"
    local defintion_str="$2"
    shift 2

    local token1="$1"
    local token2="$2"
    local -a definition=($defintion_str)
    local state=:START


    while [[ $state != :VALID_DEFINITION ]]; do
        case "$state" in
            :START)
                local command_name="${definition[0]}"
                if [[ "$command_name" == "$token1" ]]; then
                    state=:COMMAND_VALID
                    elements+=($token1)
                else
                    echo "[msd_command rule] command token doesn't match: $token1"
                    exit 1
                fi
                ;;
            :COMMAND_VALID)
                if [[ -n "$token2" ]]; then
                    state=:ACTION_MATCH
                    elements+=("$token2")
                fi
                ;;
            :ACTION_MATCH)
                state=:RULE_DEFINITION_MATCH
                ;;
        esac
    done
}
