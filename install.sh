#!/bin/bash

#Abort if some command fail.
set -e
DESKTOPSHORTCUT="$(xdg-user-dir DESKTOP)/blink_record.desktop"
SYSTEMSHORTCUT='/usr/share/applications/blink_record.desktop'
BINARYPATH='/usr/local/bin/blink_record'

function ulog {
	{ : ;}
	#echo "$1" >> uninstall.log
}

function ilog {
	{ : ;}
	#echo "$1" >> install.log
}

#Get the tf2 dir as stated in the appmanifest.
function get_tf2_dir {
	tf2_dir=`cat $HOME/.steam/steam/SteamApps/appmanifest_440.acf | sed -n -e 's/.*\"appinstalldir\".*\"\(.\+\)\"/\1/p'`
	if [ -z "$tf2_dir" ]; then
		echo 'Could not find tf2 installation directory'
		echo 'Aborting...'
		exit 1
	fi
	echo $tf2_dir
}

#Uninstall blink_record
function uninstall {
	ulog "====UNINSTALL BEGIN===="
	rm $DESKTOPSHORTCUT || true
	gksudo -- rm $SYSTEMSHORTCUT || true
	gksudo -- rm $BINARYPATH || true
	tf2_dir=$(get_tf2_dir)
	rm -r "$tf2_dir/tf/custom/blink_record" || true
	find "$tf2_dir/tf/custom" -name autoexec.cfg |
	while read -r filename; do
		ulog "Removing ecex blink_record from file: $filename"
		sed -i '/^exec blink_record \/\/88b9a67a-815c-4e1a-b4b2-ffbac1fddff2$/d' "$filename"
	done
	echo 'Uninstall complete'
	ulog "====UNINSTALL DONE===="
}

#Install blink_record
function install {
	ilog "====INSTALLATION BEGIN===="
	tf2_dir=$(get_tf2_dir)
	cp -r tf2_cfg/blink_record "$tf2_dir/tf/custom/"
	#Check if unbindall is used and infor the user.
	if grep -r -q '^unbindall' "$tf2_dir/tf/custom" ; then
		echo 'Found unbindall. You need to bind blink_record in your config in the appropriate place(s).'
		ilog "Found unbindall in configs"
	else
		echo 'Did not find unbindall in custom configs. It should be enough to bind blink_record in console.'
		ilog "Did not find unbindall in configs"
	fi
	#Add config to autoexec
	found_autoexec=false
	#Could probably use something other than find.
	while read -r filename; do
		ilog "Found a autoexec @ $filename"
		found_autoexec=true
		if grep -q '^exec blink_record$' "$filename" ; then
			echo 'Config already added to autoexec.'
			ilog "Autoexec already contained exec blink_record"
		else
			ilog "Adding exec blink_record to $filename"
			echo 'exec blink_record //88b9a67a-815c-4e1a-b4b2-ffbac1fddff2' >> "$filename"
		fi
	done < <(find "$tf2_dir/tf/custom" -name autoexec.cfg)
	if [ $found_autoexec == false ]; then
		ilog "Did not find autoexec file. Adding one."
		echo 'exec blink_record //88b9a67a-815c-4e1a-b4b2-ffbac1fddff2' > "$tf2_dir/tf/custom/blink_record/cfg/autoexec.cfg"
		echo 'Did not find autoexec so added one to path'
		echo "$tf2_dir/tf/custom/blink_record/cfg/autoexec.cfg"
		echo 'If you have one. Feel free to add blink_record to it and remove this file.'
	fi
	#Install ruby if it's mising
	command -v ruby >/dev/null 2>&1 || { gksudo -- apt-get install --yes ruby; }
	#Add menu items/shortcuts
	gksudo -- cp bin/blink_record $BINARYPATH
	cp data/blink_record.desktop $DESKTOPSHORTCUT
	gksudo -- "cp data/blink_record.desktop $SYSTEMSHORTCUT"
	echo 'Installation complete.'
	ilog "====INSTALLATION DONE===="
}

function usage {
	echo 'Usage: install [-u]'
	exit 2
}

#Some minor usage check
if [ $# -gt 1 ]; then
	usage
elif [ $# -eq 1 ]; then
	if [ $1 == '-u' ]; then
		uninstall
	else
		usage
	fi
else
	install
fi
