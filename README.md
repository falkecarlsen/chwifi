# rolling-netctl-manager
This script eases network-switching for users who connect wirelessly at home and at a workplace employing a rolling-password model for their wireless networks by automatically configuring network profiles according to locally cached passwords. 

Through scripting CAS-login, downloading currently available four passwords, caching them locally, and matching daily password with given date, automatic network-manager profile configuration is achieved for following three days. If `chwifi` has been invoked within the previous three days, the current daily password will be cached and available for automatic configuration.

Note that this script has been developed specifically for use at Aalborg University's campuses but should be easily adaptable to other CAS-like authentication systems.

## Usage
To connect to home, pass no arguments:

```sh
./chwifi
```

To connect to work with cached password, pass `work`:

```sh
./chwifi work
```

To manually enter new, daily password for work-profile, pass a single argument of the form `[a-z]+[0-9]+[a-z]+`:

```sh
./chwifi foo42bar
```

> To avoid typing your `sudo` password multiple times, you *can* run the script with `sudo`, and the script should operate nicely, but you do so at your own risk.

To run whole script as `sudo`, removing the need to type your password multiple times, form script-call as:

```sh
sudo ./chwifi args
```

## Dependencies
Following lists dependencies with most recently tested version of commands appended to name
- `bash` `GNU bash, version 5.0.0(1)-release` required to run script
- `ip` `Linux v4.20.13-arch1-1-ARCH` required for resetting adapter between operations
- `date` `v8.30` required for matching valid date of password with given date, and measuring connection times
- `netctl` `v1.20` or other network manager that takes arguments of the form `network_manager` `operation` `profile`
- `perl` `rev5 v28 subv1` required for regex search and replace
- `curl` `v7.64.0` required for accessing CAS-secured password-list and testing for network connection
- `libxml` `v1.8.17-1` supplies `xmllint` which is required for parsing resulting password-page html

## Todo
- [X] Allow using other network managers. Implemented, as long as they follow a `command` `operation` `profile` structure.
- [ ] Implement a way to portably cache or reuse `sudo` session for `netctl` operations
- [ ] Relax matching of parameters to manual input of password to allow for non-AAU use-cases
- [ ] Relinquish control of prompt upon connection, but still execute network-wait- and password-update-routine 
