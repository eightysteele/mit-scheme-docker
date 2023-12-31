#!/bin/bash

assoc_set() {
    local map_name=$1
    shift

    while [ $# -gt 0 ]; do
        local key=$1
        local value=$2
        local key_name

        key_name=$(_get_internal_key_name "$map_name" "$key")

        # Set or update the value for the key
        eval "$key_name=\"$value\""

        # Add the key to the map if it's not already there
        if ! assoc_contains "$map_name" "$key"; then
            local key_map=$(_get_internal_map_name "$map_name")
            eval "$key_map+=(\"$key\")"
            eval "$map_name+=(\"$key\")"
        fi

        shift 2
    done
}

assoc_get() {
    local map_name=$1
    local key=$2
    local key_name

    key_name=$(_get_internal_key_name "$map_name" "$key")

    eval "echo \${$key_name}"
}

dissoc() {
    local map_name=$1
    local key=$2
    local key_name
    local key_map

    key_map=$(_get_internal_map_name "$map_name")

    eval "tmp=(\"\${$key_map[@]}\")"

    for i in "${!tmp[@]}"; do
        if [[ "${tmp[i]}" == "$key" ]]; then
            unset 'tmp[i]'
        fi
    done

    eval "$key_map=(\"\${tmp[@]}\")"
    eval "$map_name=(\"\${tmp[@]}\")"

    key_name=$(_get_internal_key_name "$map_name" "$key")
    eval "unset $key_name"
}

assoc_contains() {
    local contains_map_name=$1
    local key=$2
    local key_map

    key_map=$(_get_internal_map_name "$contains_map_name")

    eval "local -a tmp=(\"\${$key_map[@]}\")"

    for k in "${tmp[@]}"; do
        if [[ "$k" == "$key" ]]; then
            return 0
        fi
    done

    return 1
}

assoc_keys() {
    local map_name=$1
    local key_map=""

    key_map=$(_get_internal_map_name "$map_name")

    eval "echo \${$key_map[@]}"
}

assoc_size() {
    local map_name=$1
    local key_map=""

    key_map=$(_get_internal_map_name "$map_name")

    eval "local -a tmp=(\"\${$key_map[@]}\")"

    echo "${#tmp[@]}"
}

# Name of an array that stores the actual values associated with a key. This
# name serves as a key in the key map.
_get_internal_key_name() {
    local map_name=$1
    local key=$2
    local safe_key="${key/:/}"
    local name="${map_name}_${safe_key}_values"

    echo "$name"
}

# Primary array that stores names of other arrays, where names represent keys.
_get_internal_map_name() {
    local map_name=$1
    echo "assoc_map_${map_name}"
}

assoc_clear() {
    local map_name=$1
    local key_map=""

    key_map=$(_get_internal_map_name "$map_name")

    eval "local -a tmp=(\"\${$key_map[@]}\")"
    for k in "${tmp[@]}"; do
        dissoc "$map_name" "$k"
    done
    unset '$key_map[@]'
    unset $key_map
    eval "$map_name=()"
}

print_map() {
    local map_name=$1
    local specific_key=$2
    local key_map=$(_get_internal_map_name "$map_name")

    eval "local -a tmp=(\"\${$key_map[@]}\")"

    if [[ -n "$specific_key" ]]; then
        local key_name=$(_get_interal_key_name "$map_name" "$specific_key")
        eval "local value=\"\${$key_name}\""
        echo "$specific_key -> $value"
    else
        for key in "${tmp[@]}"; do
            local key_name=$(_get_interal_key_name "$map_name" "$key")
            eval "local value=\"\${$key_name}\""
            echo "$key -> $value"
        done
    fi
}
