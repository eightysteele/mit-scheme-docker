#!/bin/bash

common_bail() {
    echo -e "Error: $1 \nHelp: msd -h" >&2
    exit 1
}
