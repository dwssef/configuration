#!/bin/bash

# Updating the apt_install function to quote "$1" for better error handling.

apt_install() {
    if [ -z "$1" ]; then
        echo "Error: Package name not provided."
        return 1
    fi

    sudo apt-get install -y "$1"
}

# Other improvements in this script can be added here.
