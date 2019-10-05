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

        default_work_profile='work'
        printf "Please input the name of the work profile to use [%s]:" "$default_work_profile"
        read -r work_profile
        work_profile=${work_profile:-$default_work_profile}

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

        # Read filenames of wireless adapters into array, excluding localhost
        readarray adapters <<< "$(ls /sys/class/net/ | grep -v lo | grep -v enp)"
        i=1
        default_adapter=0
        # Print possible adapters to user to allow for selection
        for x in "${adapters[@]}" ; do
            # Regex out newlines from each element
            adapters[i-1]=$(echo "$x" | sed -e 's/\n//g')
            adapter_name="$(basename "$x")"
            printf "\t%s: %s\n" "$i" "$adapter_name"

            # Check if a 'wlp*' adapter exists, and remember index
            if [[ "$adapter_name" =~ "wlp" ]]; then
                default_adapter="$i"
            fi
            ((i++))
        done

        printf "Please choose a wireless adapter[%s]: " "$default_adapter"

        read -r wireless_adapter
        # If answer was null, choose default adapter
        wireless_adapter=${wireless_adapter:-$default_adapter}

        profiles=""
        # Grab other profiles and concatenate in string, using comma as delimiter
        for entry in "/etc/netctl"/*; do
            if [ -f "$entry" ] && [[ ! "$entry" =~ ^$work_profile$ ]] ; then
                profiles+=$(echo "$(basename $entry)")','
            fi
        done
        # Remove final comma from string
        profiles=${profiles::-1}

        printf "Detected the following profiles:\n\t%s\n" "$profiles"
        
        printf "Creating config at %s/config\n" "$config"

        # Copy config.sample into dir
        cp /usr/lib/chwifi/config.sample "$config/config"
        # Regex username and password into config
        sed -i "s/\"username\"$/\"$username\"/" "$config/config"
        sed -i "s/\"password\"$/\"$password\"/" "$config/config"
        # Regex work profile name into config
        sed -i "s/\"work-profile\"$/\"$work_profile\"/" "$config/config"
        # Regex macchanger boolean into config
        sed -i "s|\$MAC_ENABLED|$mac_enable|" "$config/config"
        # Regex config directory, using pipe for separator
        sed -i "s|\$XDG_CONFIG_HOME|$config|" "$config/config"
        # Regex other profiles into config
        sed -i "s/\"a-profile,another-profile,last-profile\"$/\"$profiles\"/" "$config/config"
        # Regex wireless adapter into config
        sed -i "s/\"adapter\"$/\"${adapters[wireless_adapter - 1]}\"/" "$config/config"
        
        if [ -f "$config/config" ]; then
            printf "Successfully created config at: %s/config\n\n" "$config"
        else
            printf "Something went wrong during config-creation. Check error-messages above or submit an issue at:\nhttps://github.com/cogitantium/chwifi\n\n"
        fi
    fi
}
