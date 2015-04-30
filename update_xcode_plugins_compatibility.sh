#!/bin/sh

bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
blue=$(tput setaf 4)
yellow=$(tput setaf 3)

# Get current Xcode UUID
XCODE_UUID=`defaults read /Applications/Xcode.app/Contents/Info DVTPlugInCompatibilityUUID`

WELCOME_MESSAGE="${bold}Scanning Xcode plugin to check for compatibility with UUID: $XCODE_UUID"
WELCOME_STARS=`printf -v spaces '%*s' ${#WELCOME_MESSAGE} ''; printf '%s\n' ${spaces// /=}`

echo
echo "$WELCOME_STARS"
echo "$WELCOME_MESSAGE"
echo "$WELCOME_STARS"
echo "${normal}"

UPDATED_FILES_COUNT=0
#get all the plugins Info.plist to check if they need an update
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | while read f; do

	# is the uuid already there?
	found_uuid=`defaults read "$f" DVTPlugInCompatibilityUUIDs | grep $XCODE_UUID`
	if [ -z "${found_uuid}" ]; then
		
		DELIM_COUNT=`echo "${f}" | tr -dc '/' | wc -c`
		PLUGIN_NAME_INDEX=$(($DELIM_COUNT - 1))
		PLUGIN_NAME=`echo "${f}" | cut -d / -f${PLUGIN_NAME_INDEX}`
		
		echo ""
		echo "${red}${bold}${PLUGIN_NAME}${normal} needs to be updated."
		echo "Do you wish to proceed? (y/n)${bold}[n]${normal}"
		read answer </dev/tty
		if [ "${answer}" == "y" ]; then
			echo "${green}-> Updating $f${normal}"
			#defaults write "$f" DVTPlugInCompatibilityUUIDs -array-add $XCODE_UUID
			
			UPDATED_FILES_COUNT=$(($UPDATED_FILES_COUNT + 1))
		else
			echo "${blue}${f} was skipped.${normal}"
		fi
		
	else
		echo "${cyan}${f} is already up-to-date.${normal}"
	fi
done

echo ""
echo "Done! ${yellow}${bold}${UPDATED_FILES_COUNT}${normal} files were updated!"
echo ""