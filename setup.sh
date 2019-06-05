#!/bin/bash

# Setup script for chwifi

config_dir() {
    if [ -z ${XDG_CONFIG_HOME+x} ]; then
        #XDG is unset, using: '$HOME/.config/chwifi/'
        mkdir -p "$HOME/.config/chwifi"
        echo "$HOME/.config/chwifi"
    else
        #XDG is set, using $XDG_CONFIG_HOME/.config/chwifi/
        mkdir -p "$XDG_CONFIG_HOME/.config/chwifi"
        echo "$XDG_CONFIG_HOME/.config/chwifi"
    fi
}

setup() {
    # Check for existence of config,
    if [ -f "$( config_dir)/config" ]; then 
        printf "Found config at %s/config\n" "$( config_dir)"
    else
        printf "Configuration does not exist. Creating one now\nPlease input username/email:\n"
        read -r username
        printf "Note that password will be visible! Please input password:\n"
        read -r password
        printf "Got username: %s, password: %s.\nCreating config at %s/config\n" "$username" "$password" "$( config_dir )"

        # Copy config.sample into dir
        cp /usr/lib/chwifi/config.sample "$( config_dir )/config"
        # Regex username and password into config
        sed -i "s/\"username\"$/\"$username\"/" "$( config_dir )/config"
        sed -i "s/\"password\"$/\"$password\"/" "$( config_dir )/config"
    fi
}
