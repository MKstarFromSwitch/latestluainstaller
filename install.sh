#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT SIGINT SIGTERM

echo "latestluainstaller 1.0"
echo "Installs the latest version of the Lua coding language (as the ones in your distro's repos could be outdated)"
read -p "Press any key to install the latest Lua..."
echo
echo "Running dependency check..."
for cmd in curl sudo make gcc; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command $cmd is not installed."
    echo "Please install it and try again."
    exit 1
  fi
done

echo
echo "Checking for sudo access (which might request your password)..."
sudo -v
echo
echo "Fetching the latest version..."
latestver=$(curl -fsSL https://raw.githubusercontent.com/MKstarFromSwitch/latestluainstaller/HEAD/latest)

if [[ -z $latestver ]]; then
  echo "ERROR: No latest version found."
  echo "Please try again later, or open a GitHub issue at https://github.com/MKstarFromSwitch/latestluainstaller/issues/"
  exit 1
fi

echo "Fetched latest version. Installing Lua..."
curl -L -R https://www.lua.org/ftp/lua-$latestver.tar.gz -o "$tmpdir/lua-$latestver.tar.gz"
tar zxf "$tmpdir/lua-$latestver.tar.gz" -C "$tmpdir"
cd "$tmpdir/lua-$latestver"

os=$(uname | tr '[:upper:]' '[:lower:]')
[[ "$os" == "darwin" ]] && os=macosx
make $os
make test || echo "Tests skipped or failed"
sudo make install
echo
echo "Done!"
exit 0
