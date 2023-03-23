#!/bin/bash

#Author: Luke Leveque @Ludicro
#Date: 3/21/2023
#Desc: Gathers the standard data for a Linux device inventory report and outputs it to a file in the directory the script was run in
#Usage: ./<Script_Name>

InventoryReport="inventoryReport.txt"
Hostname=`cat /etc/hostname`
IPAddress=`ip a | awk 'FNR == 9 {print $2}'`
OSLevel=`cat /etc/*release | cut -d "=" -f2 | awk 'FNR == 1'`
KernelVersion=`uname -a`

echo "Hostname: $Hostname" > $InventoryReport
echo "IP Address: $IPAddress" >> $InventoryReport
echo "OS Level: $OSLevel" >> $InventoryReport
echo "Kernel: $KernelVersion" >> $InventoryReport
