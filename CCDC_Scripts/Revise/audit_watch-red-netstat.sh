#!/usr/bin/env bash
#By: Luke Leveque @Ludicro
# Description:
#  Watchs for any changes to the netstat command every 5 seconds
#  Based off Noah's "audit_watch-red-team"
# Usage:
# ./<SCRIPT NAME>

LOGFILE="/var/log/logconnections.log"
TEMPFILE1="/tmp/tmp1.log"
TEMPFILE2="/tmp/tmp2.log"

netstat -tulpn > $LOGFILE

while true; do
	sleep 5s
	netstat -tulpn > $TEMPFILE2
	cat $LOGFILE | grep -ie "^tcp" -ie "^udp" -ie "tpc6" > $TEMPFILE1
	diff -b $TEMPFILE1 $TEMPFILE2 | grep ">" | grep -e tcp -e udp | sed 's/^..//' >> $LOGFILE
	if [[ $(diff -b $TEMPFILE1 $TEMPFILE2 | grep ">" | grep -e tcp -e udp | sed 's/^..//')  ]]; 
	then
		date >> $LOGFILE
	fi
done
rm $TEMPFILE1
rm $TEMPFILE2
