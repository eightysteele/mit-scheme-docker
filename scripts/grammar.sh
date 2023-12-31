#!/bin/bash

source ./assoc.sh

grammar=()

rules=(:msd_command :action :primary_action :WS)

assoc_set grammar :msd_command "'msd' WS action"

assoc_set grammar :action "primary_action (primary_options)? WS image_name WS runtime WS file_path (docker_command_sequence)?"

assoc_set grammar :primary_action "'build' / 'run' / 'squash' / 'deploy'"

assoc_set grammar :WS ' '

grammar_rule_names() {
    echo "${rules[@]}"
}

grammar_rule_definition() {
    local name="$1"
    local definition

    definition=$(get "$name")
    if [[ -n "$definition" ]]; then
       echo "$definition"
       return 0
    else
        echo "couldn't snag the rule definition for $name"
        return 1
    fi

    
}
