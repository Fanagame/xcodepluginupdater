#!/bin/sh

# Get current Xcode UUID
XCODE_UUID=`defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID`

WELCOME_MESSAGE="Scanning Xcode plugin to check for compatibility with UUID: $XCODE_UUID"
WELCOME_STARS=`printf -v spaces '%*s' ${#WELCOME_MESSAGE} ''; printf '%s\n' ${spaces// /=}`

echo
echo "$WELCOME_STARS"
echo "$WELCOME_MESSAGE"
echo "$WELCOME_STARS"
echo ""

#get all the plugins Info.plist to check if they need an update
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | while read f; do

	# is the uuid already there?
	found_uuid=`defaults read "$f" DVTPlugInCompatibilityUUIDs | grep $XCODE_UUID`
	if [ -z "${found_uuid}" ]; then
		echo "$f needs to be updated."
		echo "Do you wish to proceed? (y/n)[n]"
		read answer </dev/tty
		if [ "${answer}" == "y" ]; then
			echo "-> Updating $f"
			default write "$f" DVTPlugInCompatibilityUUIDs -array-add $XCODE_UUID
		else
			echo "-> Skipping $f"
		fi
		echo ""
		
	else
		echo ""
		echo "$f is already up-to-date."
	fi
done