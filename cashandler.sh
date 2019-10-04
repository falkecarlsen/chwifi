#!/bin/bash

# Usage: cas-get.sh {url} {username} {password} 
# Original script yanked from gist: https://gist.github.com/gkazior/4cf7e4c38fbcbc310267
# The service to be called
dest="$1"

# Authentication details. This script only supports username/password login, but curl can handle certificate login if required
username=$2
password=$3

# Remove previous temporary files with force to supress warnings on nonexistent files
rm -f $cookie
rm -f $header_dump

# Visit CAS and get a login form. This includes a unique ID for the form, which we will store in cas_id and attach to our form submission. jsessionid cookie will be set here
cas_id=`curl -s -k -c $cookie https://$cas_hostname/cas/login?service=$dest | grep name=.lt | sed 's/.*value..//' | sed 's/\".*//'`

if [[ "$cas_id" = "" ]]; then
   printf '%s\n' "Login ticket is empty."
   exit 1
fi

# Submit the login form, using the cookies saved in the cookie jar and the form submission ID just extracted. We keep the headers from this request as the return value should be a 302 including a "ticket" param which we'll need in the next request
curl -s -k --data "username=$username&password=$password&lt=$cas_id&execution=e1s1&_eventId=submit" -i -b $cookie -c $cookie https://$cas_hostname/cas/login?service=$dest -D $header_dump -o /dev/null

# Visit the URL with the ticket param to finally set the casprivacy and, more importantly, MOD_AUTH_CAS cookie. Now we've got a MOD_AUTH_CAS cookie, anything we do in this session will pass straight through CAS
curl_dest=`grep Location $header_dump | sed 's/Location: //'`

if [[ "$curl_dest" = "" ]]; then
    printf '%s\n' "Cannot login. Check if you can login in a browser using user = $username and the following url: https://$cas_hostname/cas/login?service=$dest"
    exit 1
fi

curl -s -k -b $cookie -c $cookie $curl_dest

# Visit the place we actually wanted to go to, note the '-L' flag to follow redirects, which is needed at wifipassword.aau.dk
curl -s -k -L -b $cookie "$dest"
