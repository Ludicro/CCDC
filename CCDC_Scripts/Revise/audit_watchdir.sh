#!/usr/bin/env bash
#By: Luke Leveque @Ludicro
# Description:
#  Watchs for any changes to the given directory
# Dependencies:
# Have inotify installed
# Usage:
# ./<SCRIPT NAME> <directory>
#Will take up a terminal, so tmux is recommended


file_removed() {
	TIMESTAMP="$(date)"
	echo "[$TIMESTAMP]: $2 was removed from $1" >> /etc/dirmonitorlog.log
}

file_modified() {
	TIMESTAMP="$(date)"
	echo "[$TIMESTAMP]: The file $1$2 was modified" >> /etc/dirmonitorlog.log
}

file_created() {
	TIMESTAMP="$(date)"
	echo "[$TIMESTAMP]: The file $1$2 was created" >> /etc/dirmonitorlog.log
}

inotifywait -q -m -r -e modify,delete,create $1 | while read DIRECTORY EVENT FILE; do
	case $EVENT in
		MODIFY*)
			file_modified "$DIRECTORY" "$FILE";;
		CREATE*)
			file_created "$DIRECTORY" "$FILE";;
		DELETE*)
			file_removed "$DIRECTORY" "$FILE";;
	esac
done

#inotifywait -e modify,create,delete -r /var
