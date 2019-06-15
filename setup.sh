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
    config="$(config_dir)"
    # Check for existence of config,
    if [ -f "$config/config" ]; then 
        printf "Using config found at %s/config\n" "$config"
    else
        printf "Configuration does not exist. Creating one now\nPlease input username/email:\n"
        read -r username
        printf "Note that password will be visible! Please input password:\n"
        read -r -s password
        printf "Received username: %s, password: %s.\nCreating config at %s/config\n" "$username" "$password" "$config"

        # Copy config.sample into dir
        cp /usr/lib/chwifi/config.sample "$config/config"
        # Regex username and password into config
        sed -i "s/\"username\"$/\"$username\"/" "$config/config"
        sed -i "s/\"password\"$/\"$password\"/" "$config/config"
        # Regex config directory, using pipe for separator
        sed -i "s|\$XDG_CONFIG_HOME|$config|" "$config/config"
        
        if [ -f "$config/config" ]; then
            printf "Successfully created config at: %s/config\n\n" "$config"
        else
            printf "Something went wrong during config-creation. Check error-messages above or submit an issue at:\nhttps://github.com/cogitantium/chwifi\n\n"
        fi
    fi
}
