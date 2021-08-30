#! /bin/bash
TMPFILE="/tmp/new-golang.tar.gz"
SHATMPFILE="/tmp/new-golang.tar.gz.sha256"

DOWNLOADS=$(curl -s "https://golang.org/dl/?mode=json" | jq 'map(select(.stable==true)) | first')

OS="linux"
ARCH=$(dpkg --print-architecture)

VERSION=$(echo $DOWNLOADS | jq -r .version)
CURRENT=$(go version | cut -d ' ' -f 3)

echo "OS: $OS, Arch: $ARCH"
echo "Current version:  $CURRENT"
echo "Latest available: $VERSION"

if [ -n "$CURRENT" ]; then 
  if [ "$VERSION" = "$CURRENT" ]; then
	  echo "Version already latest (${CURRENT})"
    exit 0
  fi
fi

echo ""
echo "Updating Go to $VERSION..."

META=$(echo "$DOWNLOADS" | jq ".files[] | select(.os==\"${OS}\") | select( .arch==\"${ARCH}\")")
FILENAME=$(echo "$META" | jq -r '.filename')
SHA256=$(echo "$META" | jq -r '.sha256')

echo "${SHA256}  $TMPFILE" > $SHATMPFILE

if ! curl -L "https://golang.org/dl/${FILENAME}" -o "$TMPFILE"; then
	echo "FAILED to download the file, stopping update."
	exit 1
fi

if ! shasum -a 256 -c "$SHATMPFILE"; then
	echo "FAILED to match checksums, stopping update."
	exit 1
fi

sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$TMPFILE"

rm "$TMPFILE"
rm "$SHATMPFILE"
go version
