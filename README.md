# rolling-netctl-manager
This script aims to ease workday mornings and afternoons by facilitating easy netctl-profile passphrase changes and profile switcing. 
Through scripting CAS-login, downloading next four passwords, caching them locally, and matching daily password with given date, automatic `netctl`-profile configuration is achieved.
Automatically resets wireless network adapter between operations.

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

## Todo
- [ ] Implement a way to portably cache or reuse `sudo` session for `netctl` operations
- [ ] Relax matching of parameters to manual input of password to allow for non-AAU use-cases
- [ ] Relinquish control of prompt upon connection, but still execute network-wait- and password-update-routine
- 
