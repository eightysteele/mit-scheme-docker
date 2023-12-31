#!/bin/bash

assoc_set() {
    local caller_map=$1
    shift

    while [ $# -gt 0 ]; do
        local key=$1
        local value=$2
        local internal_key

        internal_key=$(_get_internal_key_name "$caller_map" "$key")

        # Set or update the value for the key
        eval "$internal_key=\"$value\""

        # Add the key to the map if it's not already there
        if ! assoc_contains "$caller_map" "$key"; then
            local internal_map=$(_get_internal_map_name "$caller_map")
            eval "$internal_map+=(\"$key\")"
            eval "$caller_map+=(\"$key\")"
        fi

        shift 2
    done
}

assoc_get() {
    local caller_map=$1
    local key=$2
    local internal_key

    internal_key=$(_get_internal_key_name "$caller_map" "$key")

    eval "echo \${$internal_key}"
}

assoc_remove() {
    local caller_map=$1
    local key=$2
    local internal_key
    local internal_map

    internal_map=$(_get_internal_map_name "$caller_map")

    eval "tmp=(\"\${$internal_map[@]}\")"

    for i in "${!tmp[@]}"; do
        if [[ "${tmp[i]}" == "$key" ]]; then
            unset 'tmp[i]'
        fi
    done

    eval "$internal_map=(\"\${tmp[@]}\")"
    eval "$caller_map=(\"\${tmp[@]}\")"

    internal_key=$(_get_internal_key_name "$caller_map" "$key")
    eval "unset $internal_key"
}

assoc_contains() {
    local contains_caller_map=$1
    local key=$2
    local internal_map

    internal_map=$(_get_internal_map_name "$contains_caller_map")

    eval "local -a tmp=(\"\${$internal_map[@]}\")"

    for k in "${tmp[@]}"; do
        if [[ "$k" == "$key" ]]; then
            return 0
        fi
    done

    return 1
}

assoc_keys() {
    local caller_map=$1
    local internal_map=""

    internal_map=$(_get_internal_map_name "$caller_map")

    eval "echo \${$internal_map[@]}"
}

assoc_size() {
    local caller_map=$1
    local internal_map=""

    internal_map=$(_get_internal_map_name "$caller_map")

    eval "local -a tmp=(\"\${$internal_map[@]}\")"

    echo "${#tmp[@]}"
}

assoc_clear() {
    local caller_map=$1
    local internal_map=""

    internal_map=$(_get_internal_map_name "$caller_map")

    eval "local -a tmp=(\"\${$internal_map[@]}\")"
    for k in "${tmp[@]}"; do
        assoc_remove "$caller_map" "$k"
    done
    unset '$internal_map[@]'
    unset $internal_map
    eval "$caller_map=()"
}

assoc_print() {
    local caller_map=$1
    local specific_key=$2
    local internal_map=""

    internal_map=$(_get_internal_map_name "$caller_map")

    eval "local -a tmp=(\"\${$internal_map[@]}\")"

    if [[ -n "$specific_key" ]]; then
        local internal_key=$(_get_interal_key_name "$caller_map" "$specific_key")
        eval "local value=\"\${$internal_key}\""
        echo "$specific_key -> $value"
    else
        for key in "${tmp[@]}"; do
            local internal_key=$(_get_interal_key_name "$caller_map" "$key")
            eval "local value=\"\${$internal_key}\""
            echo "$key -> $value"
        done
    fi
}

# Name of an array that stores the actual values associated with a key. This
# name serves as a key in the key map.
_get_internal_key_name() {
    local caller_map=$1
    local key=$2
    local safe_key="${key/:/}"
    local name="${caller_map}_${safe_key}_values"

    echo "$name"
}

# Primary array that stores names of other arrays, where names represent keys.
_get_internal_map_name() {
    local caller_map=$1
    echo "assoc_map_${caller_map}"
}

