# chwifi
This tool automates network-switching for users who connect wirelessly at home and at a workplace employing a rolling-password model for their wireless networks by automatically configuring network profiles according to locally cached passwords. Device-specific bytes of MAC-address are randomised during each connection routine. 

Through scripting CAS-login, downloading currently available passwords, caching them locally, and matching daily password with given date, automatic network-manager profile configuration is achieved for following days specified by service. 
In the case of Aalborg University; if `chwifi` has been invoked within the previous three days, the current daily password will be cached and available for automatic configuration, thus ensuring no manual input for consecutive five-day workweeks.

Note that this script has been developed specifically for use at Aalborg University's campuses but should be easily adaptable to other CAS-like authentication systems.

## Configuration
All configuration is located in the `config` file. Note that most can be left to defaults. 

For `chwifi` to automatically cache passwords, edit `config` with appropriate credentials.
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
wireless_adapter="wlp3s0"
network_manager="netctl"
network_manager_location="/etc/netctl/"
network_manager_connect="start"
network_manager_disconnect="stop"
network_manager_stopall="stop-all"
network_manager_restart="restart"
network_manager_home_profile="home"
network_manager_work_profile="work"
```

Options for macchanger, `-e` is default, which randomises only device-specific bytes and retains vendor-information.
```shell
macchanger_options="-e"
```

Settings for `passwordhandler.sh`, edit if other CAS-destination or temp-filenames are desired.
```shell
dest="https://wifipassword.aau.dk/oneday"
password_html_file="passwords.html"
password_file="passwords"
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

## Usage
To connect to home, pass argument `home`.
```shell
./chwifi home
```

To connect to work with cached password, pass argument `work`.
```shell
./chwifi work
```

To restart a given profile, pass either `-r` or `restart` followed by the profile-name.
```shell
./chwifi -r home
./chwifi restart work
```

To manually enter new, daily password for work-profile, pass a single argument of the form `^[a-z]+[0-9]+[a-z]+$`.
```shell
./chwifi foo42bar
```

## Example
Example shows call from another directory, with work keyword, printing cached password, and username for fetching passwords.
```
user@hostname ~> projects/chwifi/chwifi work
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
- `libxml` `v1.8.17-1` supplies `xmllint` which is required for parsing resulting password-page html
- `macchanger` `1.7.0` required for MAC-address spoofing

