#!/bin/bash

assoc_set() {
    local caller_map=$1
    shift

    local internal_map=""
    local internal_key=""

    internal_map=$(_assoc_get_internal_map_name "$caller_map")

    while [ $# -gt 0 ]; do
        local key=$1
        local value=$2
        local internal_key

        internal_key=$(_assoc_get_internal_key_name "$caller_map" "$key")
        eval "$internal_key=\"$value\""

        if ! assoc_contains "$caller_map" "$key"; then
            eval "$internal_map+=(\"$key\")"
            eval "$caller_map+=(\"$key\")"
        fi

        shift 2
    done
}

assoc_get() {
    local caller_map=$1
    local caller_key=$2
    local internal_key

    internal_key=$(_assoc_get_internal_key_name "$caller_map" "$caller_key")

    eval "echo \${$internal_key}"
}

assoc_remove() {
    local caller_map=$1
    local caller_key=$2
    local internal_key
    local internal_map

    internal_map=$(_assoc_get_internal_map_name "$caller_map")

    eval "tmp=(\"\${$internal_map[@]}\")"

    for i in "${!tmp[@]}"; do
        if [[ "${tmp[i]}" == "$caller_key" ]]; then
            unset 'tmp[i]'
        fi
    done

    eval "$internal_map=(\"\${tmp[@]}\")"
    eval "$caller_map=(\"\${tmp[@]}\")"

    internal_key=$(_assoc_get_internal_key_name "$caller_map" "$caller_key")
    eval "unset $internal_key"
}

assoc_contains() {
    local contains_caller_map=$1
    local caller_key=$2
    local internal_map

    internal_map=$(_assoc_get_internal_map_name "$contains_caller_map")

    eval "local -a tmp=(\"\${$internal_map[@]}\")"

    for k in "${tmp[@]}"; do
        if [[ "$k" == "$caller_key" ]]; then
            return 0
        fi
    done

    return 1
}

assoc_clear() {
    local caller_map=$1
    local internal_map=""

    internal_map=$(_assoc_get_internal_map_name "$caller_map")

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
    local internal_key=""

    internal_map=$(_assoc_get_internal_map_name "$caller_map")

    eval "local -a tmp=(\"\${$internal_map[@]}\")"

    if [[ -n "$specific_key" ]]; then
        internal_key=$(_assoc_get_internal_key_name "$caller_map" "$specific_key")
        eval "local value=\"\${$internal_key}\""
        echo "$specific_key -> $value"
    else
        for key in "${tmp[@]}"; do
            internal_key=$(_assoc_get_internal_key_name "$caller_map" "$key")
            eval "local value=\"\${$internal_key}\""
            echo "$key -> $value"
        done
    fi
}

_assoc_get_internal_key_name() {
    local caller_map=$1
    local key=$2
    local safe_key="${key/:/}"
    local name="${caller_map}_${safe_key}_values"

    echo "$name"
}

_assoc_get_internal_map_name() {
    local caller_map=$1
    echo "assoc_map_${caller_map}"
}
