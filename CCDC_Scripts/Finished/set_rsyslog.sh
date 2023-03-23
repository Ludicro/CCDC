#!/bin/bash

#Author: Luke Leveque @Ludicro
#Date: 3/21/2023
#Desc: Sets up log fowarding to the Splunk machine via UDP
#Usage: ./<Script_Name> <IP>

IPAddress="$1"

echo "*.* @$IPAddress:514" >> /etc/rsyslog.conf

echo `systemctl restart rsyslog`
echo `service rsyslog restart`
