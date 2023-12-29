#!/bin/bash

assoc() {
    local map_name=$1
    shift  # Skip the map name

    while [ $# -gt 0 ]; do
        local key=$1
        local value=$2
        local key_name

        key_name=$(get_key_name "$key")

        # Set or update the value for the key
        eval "$key_name=\"$value\""

        # Add the key to the map if it's not already there
        if ! contains "$map_name" "$key"; then
            eval "$map_name+=(\"$key\")"
        fi

        shift 2  # Move to the next key-value pair
    done
}

get() {
    local key=$1
    local key_name

    key_name=$(get_key_name "$key")

    eval "echo \${$key_name}"
}

dissoc() {
    local map_name=$1
    local key=$2
    local key_name
    local key_map

    key_map=$(get_key_map_name "$key")

    eval "$key_map=(\"\${$map_name[@]}\")"

    for i in "${!key_map[@]}"; do
        if [[ "${key_map[i]}" == "$key" ]]; then
            unset 'key_map[i]'
        fi
    done

    eval "$map_name=(\"\${key_map[@]}\")"

    key_name=$(get_key_name "$key")
    eval "unset $key_name"
}

contains() {
    local contains_map_name=$1
    local key=$2
    local key_map

    key_map=$(get_key_map_name "$key")

    eval "local -a ${key_map}=(\"\${$contains_map_name[@]}\")"

    for k in "${key_map[@]}"; do
        if [[ "$k" == "$key" ]]; then
            return 0
        fi
    done

    return 1
}

keys() {
    local map_name=$1
    eval "echo \${$map_name[@]}"
}

size() {
    local map_name=$1
    local key_map

    key_map=$(get_key_map_name "$key")

    eval "$key_map=(\"\${$map_name[@]}\")"

    echo "${#key_map[@]}"
}

clear() {
    local map_name=$1
    local keys

    # Retrieve all keys
    eval "keys=(\"\${$map_name[@]}\")"

    # Iterate and remove each key and its value
    for k in "${keys[@]}"; do
        local key_name=$(get_key_name "$k")
        eval "unset $key_name"  # Clear the value
        dissoc "$map_name" "$k"  # Remove the key from the map
    done

    # Reset the map array
    eval "$map_name=()"
}

# Name of an array that stores the actual values associated with a key. This
# name serves as a key in the key map.
get_key_name() {
    local key=$1
    local safe_key="${key/:/}"
    local name="${safe_key}_values"

    echo "$name"
}

# Primary array that stores names of other arrays, where names represent keys.
get_key_map_name() {
    echo "key_map"
}

clear_key_map() {
    local key_map
    local keys

    key_map=$(get_key_map_name "$key")

    eval "local -a tmp=(\"\${$key_map[@]}\")"
    for k in "${tmp[@]}"; do
        dissoc key_nap "$k"
    done
    unset '$key_map[@]'
    unset $key_map
}

print_map() {
    local map_name=$1
    local specific_key=$2

    eval "local -a key_map=(\"\${$map_name[@]}\")"

    if [[ -n "$specific_key" ]]; then
        local key_name=$(get_key_name "$specific_key")
        eval "local value=\"\${$key_name}\""
        echo "$specific_key -> $value"
    else
        for key in "${key_map[@]}"; do
            local key_name=$(get_key_name "$key")
            eval "local value=\"\${$key_name}\""
            echo "$key -> $value"
        done
    fi
}
