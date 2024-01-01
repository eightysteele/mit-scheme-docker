#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

common_bail() {
    echo -e "Error: $1 \nHelp: msd -h" >&2
    exit 1
}
