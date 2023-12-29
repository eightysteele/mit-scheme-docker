#!/bin/bash

source ./parse.sh

msd_build_ast() {
    echo "hi"
}

msd_interpret_ast() {

    case "$action" in
        create)
            validate_file_exists "$argument1"
            echo "Creating file: $argument1"
            touch "$argument1"
            ;;
        delete)
            validate_file_exists "$argument1"
            echo "Deleting file: $argument1"
            rm "$argument1"
            ;;
        rename)
            validate_file_exists "$argument1"
            if [[ -n "$argument3" ]]; then
                validate_directory_exists "$argument3"
                echo "Renaming file from $argument1 to $argument2 in directory $argument3"
                mv "$argument1" "$argument3/$argument2"
            else
                echo "Renaming file from $argument1 to $argument2"
                mv "$argument1" "$argument2"
            fi
            ;;
        *)
            echo "No valid action specified"
            exit 1
            ;;
    esac
}

# Main execution function
msd_execute() {
    local -a command=()
    local -a ast=()
    parse_command_line "ast" "$@"
    echo "${ast[@]}"
    local action=$(get :action)
    echo "action: $action"
    #build_ast "$@"
    #interpret_ast
}

command_line="$@"
IFS=' ' read -r -a command_line_args <<< "$command_line"
msd_execute "${command_line_args[@]}"

