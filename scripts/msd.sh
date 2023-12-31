#!/bin/bash-3.2.57 

source ./parse.sh

msd_build_ast() {
    echo "hi"
}

msd_interpret_ast() {

    case "$action" in
        build)
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
    local -a ast_root=()
    parse_command_line ast_root "$@"
    print_map_multi ast_root
}

command_line="$@"
IFS=' ' read -r -a command_line_args <<< "$command_line"
msd_execute "${command_line_args[@]}"


# foo() {
#     local -a ast=(1 2 3)
#     local ast_str=$(IFS=,; echo "${ast[*]}")
#     eval "$1=\"$ast_str\""
# }

# bar() {
#     local my_ast_str
#     local -a my_ast
#     foo my_ast_str

#     IFS=, read -r -a my_ast <<< "$my_ast_str"
#     echo "${my_ast[@]}"
# }

#bar
foo() {
    local ast_ref="$1"
    local -a ast=(1 2 3)
    eval "$ast_ref=(\"\${ast[@]}\")"
}

bar() {
    local -a ast2=()
    foo ast2
    echo "${ast2[@]}"
}

#bar
