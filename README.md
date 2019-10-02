<p align="center">
  <img alt="GitHub release" src="https://img.shields.io/github/release/cogitantium/chwifi.svg">
  <img alt="GitHub" src="https://img.shields.io/github/license/cogitantium/chwifi.svg">
  <img alt="AUR votes" src="https://img.shields.io/aur/votes/chwifi-git.svg?label=AUR%20votes">
  <img alt="GitHub last commit (master)" src="https://img.shields.io/github/last-commit/cogitantium/chwifi/master.svg?label=last%20update">
</p>

# chwifi
This tool automates network-switching for users who connect wirelessly at home and at a workplace employing a rolling-password model for their wireless networks by automatically configuring network profiles according to locally cached passwords. Device-specific bytes of MAC-address are randomised during each connection routine. 

Through scripting CAS-login, downloading currently available passwords, caching them locally, and matching daily password with given date, automatic network-manager profile configuration is achieved for following days specified by service. 
In the case of Aalborg University; if chwifi has been invoked within the previous three days, the current daily password will be cached and available for automatic configuration, thus ensuring no manual input for consecutive five-day workweeks.

Note that this script has been developed specifically for use at Aalborg University's campuses but should be easily adaptable to other CAS-like authentication systems.

## Installation
- Installing chwifi through a package manager is advisable, currently `chwifi` is packaged for AUR and can be easily installed by an AUR-helper
    ```shell
    yay -S chwifi-git
    ```

- Manual installation is possible, but requires some work. Note that updates needs to be applied manually when installing manually.
    ```shell
    # Clone the repository and cd into it
    git clone https://github.com/cogitantium/chwifi.git
    cd chwifi
    
    # Make directory structure
    mkdir -p /usr/lib/chwifi
    mkdir -p /usr/bin
    
    # Install script to /usr/lib/chwifi
    install chwifi passwordhandler.sh cashandler.sh setup.sh config.sample -t /usr/lib/chwifi
    
    # Symlink script from /usr/lib to /usr/bin
    ln -s /usr/lib/chwifi/chwifi /usr/bin/chwifi
    ```

- Upon first run a configuration will be generated. A setup script prompts for username and password for CAS and puts the generated config at `$XDG_CONFIG_HOME/.config/chwifi/config`.

## Usage
A help message is displayed when passing no arguments, `-h`, or `--help`.
```
user@hostname ~> chwifi
Usage: chwifi [OPTION]... <PROFILE>
Connect to home or work wireless networks, caching rolling passwords at work

Optional arguments:
  -s, show [index|today|tomorrow]	display the daily password of the given index or day
  -r, restart [profile]			restarts the given profile
  -p, profile [profile]			connects to any profile under netctl
  -u, update				update profiles under netctl
  -h, --help				display this help and exit

chwifi is released under GPL-2.0 and comes with ABSOLUTELY NO WARRANTY, for details read LICENSE
Configuration of this script is done through the 'config' file, for documentation read README.md
```

To connect to home, pass argument `home`.
```shell
chwifi home
```

To connect to work with cached password, pass argument `work`.
```shell
chwifi work
```

To connect to a given profile under netctl, pass either `-p` or `profile` followed by the profile-name.
```shell
chwifi -p profile-name
chwifi profile profile-name
```

To show a specific password pass '-s' or 'show' followed by an index, e.g., where 1 is tomorrow's password. Using the keywords 'today' and 'tomorrow' is also supported.
```shell
chwifi -s 3
chwifi show today
```

To restart a given profile, pass either `-r` or `restart` followed by the profile-name.
```shell
chwifi -r home
chwifi restart work
```

To update recognised profiles, pass either `-u` or `update`.
```shell
chwifi -u
chwifi update
```

## Configuration
All configuration is located in the `config` file which is installed into the home config upon first run, after prompting the user for username and password. Note that most can be left to defaults but if changes are necessary, the config can be found at `$XDG_CONFIG_HOME/.config/chwifi/config`.

```shell
# Credentials for CAS-authentication system.
username="username"
password="password"
```

Rolling password syntax, set with a regex.
```shell
password_syntax="[a-z]+[0-9]+[a-z]+"
```

System specific settings for network manager and wireless adapter follows. Adjust according to system configuration. Default is `wlp3s0` for network adapter and `netctl` as network manager and assumes profiles named 'home' and 'work'.
```shell
wireless_adapter="adapter"
network_manager="netctl"
network_manager_location="/etc/netctl/"
network_manager_connect="start"
network_manager_disconnect="stop"
network_manager_stopall="stop-all"
network_manager_restart="restart"
network_manager_home_profile="home"
network_manager_work_profile="work"
network_manager_other_profiles="a-profile,another-profile,last-profile"
```

Options for macchanger, default is enabled which is set during setup and is either `y` or `n`, `-e` is the default option, which randomises only device-specific bytes and retains vendor-information.
```shell
macchanger_enabled="$MAC_ENABLED"
macchanger_options="-e"
```

Settings for `passwordhandler.sh`, edit if other CAS-destination or temp-filenames are desired.
```shell
dest="https://wifipassword.aau.dk/oneday"
password_html_file="passwords.html"
password_file="$XDG_HOME_CONFIG/passwords"
```

Host to ping for network connection test. Sensible to set to organisations homepage, since if network is restricted to organisation's local network and password-portal is still available, update of local cache is still possible during outage of public network access.
```shell
network_up_host="aau.dk"
```

> If required for specific use-case, a config-option is available to disable internal sudo-prefix to priviledged commands. This is **not advised**.

Set internal `sudo` for priviledged commands. Defaults to true. Set `sudo` for true, and null for false, e.g.; `sudo=""`.
```shell
sudo="sudo"
```

## Example
Example shows chwifi call, with work keyword, printing cached password if foun, and username used for updating cached passwords.
```
user@hostname ~> chwifi work
Work-keyword found, checking for cached password
Daily work password is: amount42wind
Stopping all profiles
New MAC-address: 00:1a:e9:cb:55:ef 
Connecting to profile: work
Waiting for network connection...
Connection took: 5.293s
Network connection established, updating cached passwords
Sourced credentials with username: username
Successfully updated cached passwords
```

## Dependencies
Following lists dependencies with most recently tested version of commands appended to name:
- `bash` `GNU bash, version 5.0.0(1)-release` required to run script
- `sudo` `v1.8.27` required to execute priviledged commands
- `netctl` `v1.20` or other network manager that takes arguments of the form `network_manager` `operation` `profile`
- `ip` `Linux v4.20.13-arch1-1-ARCH` required for resetting adapter between operations
- `date` `v8.30` required for matching valid date of password with given date, and measuring connection times
- `perl` `rev5 v28 subv1` required for regex search and replace
- `curl` `v7.64.0` required for accessing CAS-secured password-list and testing for network connection
- `libxml2` `v2.9.9-2` supplies `xmllint` which is required for parsing resulting password-page html
- `macchanger` `1.7.0` required for MAC-address spoofing

