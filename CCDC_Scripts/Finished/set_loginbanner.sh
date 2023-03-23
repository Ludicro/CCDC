#!/bin/bash

#Author: Luke Leveque @Ludicro
#Date: 3/21/2023
#Desc: Creates a login banner for Linux devices EXCEPT for the Splunk machine.
#Usage: ./<Script_Name>

echo 'UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED' >> /etc/issue
echo '' >> /etc/issue
echo 'You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored.' >> /etc/issue
