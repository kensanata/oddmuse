#!/bin/bash
if test -z "$2" -o ! -z "$3"; then
    echo "Usage: delete.sh USERNAME WIKI"
    exit 1
fi

username=$1
wiki=$2

for p in $(curl --silent "https://campaignwiki.org/wiki/$wiki?action=index;raw=1"); do
    echo "Deleting: $p"
    curl -F frodo=1 -F "title=$p" -F text=DeletedPage -F summary=Deleted -F username="$username" "https://campaignwiki.org/wiki/$wiki"
    sleep 5
done
