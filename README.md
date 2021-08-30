# update-go
Tiny script to update go to latest stable version.

The script will install go to /usr/local/go/bin and
this path should be added to your PATH.

## Requires
Currently only works on debian-based distroes (uses dpkg)
Uses jq, curl, dpkg, shasum and tar

`apt install jq curl`
