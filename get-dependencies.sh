#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	sdl2	 	   \
	vulkan-headers

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use X64 and ARM64 for the zip links
	x86_64)  zip_arch=Linux-X64-Release;;
	aarch64) zip_arch=Linux-ARM64-Release;;
esac
TAG=$(wget -qO- "https://gitlab.com/api/v4/projects/sonicdcer%2FMarioKart64Recomp/releases?per_page=1" \
      | sed 's/[()",{} ]/\n/g' | grep -A2 '^tag_name$' | tail -n1)
ZIP_LINK="https://gitlab.com/api/v4/projects/sonicdcer%2FMarioKart64Recomp/packages/generic/mariokart64recompiled$(echo "${zip_arch%-Release}" | tr -d '-' | tr '[:upper:]' '[:lower:]')/${TAG#v}/MarioKart64Recompiled-${TAG}-${zip_arch}.zip"
echo "${TAG#v}" > ~/version
wget --retry-connrefused --tries=30 "$ZIP_LINK" -O /tmp/app.zip

mkdir -p ./AppDir/bin
bsdtar -xvf /tmp/app.zip -C .
bsdtar -xvf ./MarioKart64Recompiled.tar.gz -C ./AppDir/bin
wget -q -O ./AppDir/bin/recompcontrollerdb.txt https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt
