#!/bin/bash

# validates action name from token, returning 0 if valid, otherwise exits.
validate_action_token() {
    local token="$1"

    case "$token" in
        build|run|squash|deploy)
            return 0
            ;;
        *)
            common_bail "Unsupported action: $token"
            ;;
    esac
}

# validates build options, returning true if valid, otherwise exits.
validate_build_option_tokens() {
    local option=""
    local regex="^(-d|-h)$"

    while [[ $# -gt 0 ]]; do
        option="$1"
        if [[ $option =~ $regex ]]; then
            shift
        else
            common_bail "Unsupported option: $option"
        fi
    done

    return 0
}

# validates build action arguments, returning true if valid, otherwise exits.
validate_build_arg_tokens() {
    local image_name_token="$1"
    local runtime_token="$2"
    local file_path_token="$3"

    validate_image_name_token "$image_name_token"
    validate_runtime_token "$runtime_token"
    validate_file_path_token "$file_path_token"

    return 0
}

# validates image_name from token, returning true if valid, otherwise exits.
validate_image_name_token() {
    local token="$1"
    local regex="^([a-zA-Z0-9_.-]+)(:([a-zA-Z0-9]+))?$"

    if [[ "$token" =~ $regex ]]; then
        return 0
    else
        common_bail "invalid image_name: $token"
    fi
}

# validates runtime from token, returning true if valid, otherwise exits.
validate_runtime_token() {
    local token="$1"

    if [[ "$token" == "mit-scheme" || "$token" == "mechanics" ]]; then
        return 0
    else
        common_bail "Invalid runtime: $token"
    fi
}

# validates file_path from token, returning true if valid, otherwise exits.
validate_file_path_token() {
    local token="$1"
    local resolved_path=""

    resolved_path=$(realpath "$token" 2>/dev/null)

    if [[ -f "$resolved_path" && -r "$resolved_path" ]]; then
        return 0
    else
        common_bail "Invalid or inaccessible Dockerfile: $resolved_path"
    fi
}
