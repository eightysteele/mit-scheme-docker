#!/bin/bash

assoc_multi() {
    local map_name=$1
    shift

    while [ $# -gt 0 ]; do
        local key=$1
        local value=$2
        local key_name

        if ! contains_multi "$map_name" "$key"; then
            eval "$map_name+=(\"$key\")"
        fi

        key_name=$(get_key_name_multi "$key")
        eval "$key_name+=(\"$value\")"

        shift 2
    done
}

get_multi() {
    local key=$1
    local key_name

    key_name=$(get_key_name_multi "$key")

    eval "echo \${$key_name[@]}"
}

dissoc_multi() {
    local map_name=$1
    local key=$2
    local key_name
    local key_map

    key_map=$(get_key_map_name_multi "$key")

    eval "$key_map=(\"\${$map_name[@]}\")"

    for i in "${!key_map[@]}"; do
        if [[ "${key_map[i]}" == "$key" ]]; then
            unset 'key_map[i]'
        fi
    done

    eval "$map_name=(\"\${key_map[@]}\")"

    key_name=$(get_key_name_multi "$key")
    eval "unset $key_name"
}

contains_multi() {
    local contains_map_name=$1
    local key=$2
    local key_map

    key_map=$(get_key_map_name_multi "$key")

    eval "local -a ${key_map}=(\"\${$contains_map_name[@]}\")"

    for k in "${key_map[@]}"; do
        if [[ "$k" == "$key" ]]; then
            return 0
        fi
    done

    return 1
}

keys_multi() {
    local map_name=$1
    eval "echo \${$map_name[@]}"
}

size_multi() {
    local map_name=$1
    local key_map

    key_map=$(get_key_map_name_multi "$key")

    eval "$key_map=(\"\${$map_name[@]}\")"

    echo "${#key_map[@]}"
}

clear_multi() {
    local map_name=$1
    local key_map
    local keys

    eval "keys=(\"\${$map_name[@]}\")"

    for k in "${keys[@]}"; do
        dissoc "$map_name" "$k"
    done

    eval "$map_name=()"
}


# Name of an array that stores the actual values associated with a key. This
# name serves as a key in the key map.
get_key_name_multi() {
    local key=$1
    local safe_key="${key/:/}"
    local name="${safe_key}_values"

    echo "$name"
}

# Primary array that stores names of other arrays, where names represent keys.
get_key_map_name_multi() {
    echo "key_map"
}

clear_key_map_multi() {
    local key_map
    local keys

    key_map=$(get_key_map_name_multi "$key")

    eval "local -a tmp=(\"\${$key_map[@]}\")"
    for k in "${tmp[@]}"; do
        dissoc key_nap "$k"
    done
    unset '$key_map[@]'
    unset $key_map
}

print_map_multi() {
    local map_name=$1
    local specific_key=$2

    eval "local -a key_map=(\"\${$map_name[@]}\")"

    if [[ -n "$specific_key" ]]; then
        local key_name=$(get_key_name_multi "$specific_key")
        eval "local -a values=(\"\${$key_name[@]}\")"
        echo "$specific_key -> (${values[*]})"
    else
        for key in "${key_map[@]}"; do
            local key_name=$(get_key_name_multi "$key")
            eval "local -a values=(\"\${$key_name[@]}\")"
            echo "$key -> (${values[*]})"
        done
    fi
}
