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
    if [ ! -f "$config/config" ]; then 
        printf "Configuration does not exist. Creating one now\nPlease input username/email:\n"
        read -r username
        printf "Please input password:\n"
        read -r -s password
        printf "Enable macchanger to randomise MAC-address upon each connection? [Y/n]: "
        read -r mac_enable

        # Keep prompting for input, if nonzero and non-conforming to booleans
        while [[ ! "$mac_enable" =~ ^[yYnN]$ ]] && [[ -n $mac_enable ]]
        do
            printf "Input '%s' for macchanger enabling does not match boolean pattern [yYnN].\nEnable macchanger? [Y/n]: " "$mac_enable"
            read -r mac_enable
        done

        # Convert answer to lowercase
        mac_enable=$(echo "$mac_enable" | tr '[:upper:]' '[:lower:]')

        # Set mac_enable to default of true if unset
        mac_enable="${mac_enable:-y}"
        printf "\nReceived username: %s and macchanger: %s.\nCreating config at %s/config\n" "$username" "$mac_enable" "$config"

        profiles=""
        # Grab other profiles and concatenate in string, using comma as delimiter
        for entry in "/etc/netctl"/*; do
            if [ -f "$entry" ]; then
                profiles+=$(echo "$entry" | sed -e 's/\/etc\/netctl\///g')','
            fi
        done
        # Remove final comma from string
        profiles=${profiles::-1}

        # Copy config.sample into dir
        cp /usr/lib/chwifi/config.sample "$config/config"
        # Regex username and password into config
        sed -i "s/\"username\"$/\"$username\"/" "$config/config"
        sed -i "s/\"password\"$/\"$password\"/" "$config/config"
        # Regex macchanger boolean into config
        sed -i "s|\$MAC_ENABLED|$mac_enable|" "$config/config"
        # Regex config directory, using pipe for separator
        sed -i "s|\$XDG_CONFIG_HOME|$config|" "$config/config"
        # Regex other profiles into config
        sed -i "s/\"a-profile,another-profile,last-profile\"$/\"$profiles\"/" "$config/config"
        
        if [ -f "$config/config" ]; then
            printf "Successfully created config at: %s/config\n\n" "$config"
        else
            printf "Something went wrong during config-creation. Check error-messages above or submit an issue at:\nhttps://github.com/cogitantium/chwifi\n\n"
        fi
    fi
}
