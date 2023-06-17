#!/bin/bash
#
#Password reset Script for the following issue
#https://help.ovhcloud.com/csm/en-ca-vps-root-password?id=kb_article_view&sysparm_article=KB0047679#changing-the-password-if-you-have-lost-it
#Author: Christian Goeschel Ndjomouo
#Version:1.1

#Start of script output
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "|                                                                                  |"
echo "|  This script will handle the identification and mounting of your main partition  |"
echo "|  and help you update/reset your forgotten password.                              |"
echo "|                                                                                  |"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "Starting..."
sleep 2


#Tune2fs package availability check, this tool will help to identify the main partition

t2fs=$(which tune2fs)
echo ""
echo "Checking for tune2fs..."
sleep 1

if [[ $t2fs == *"tune2fs"* ]];
then

echo ""
echo "tune2fs already installed!"

else

echo ""
echo "Installing tune2fs..."
apt install e2fslibs -y
sleep 1

fi

#Server information

ip=$(ip -o a | grep -E 'eth0.*inet' | grep -v 'inet6' | cut -d '/' -f 1 | cut -d 't' -f 3 | cut -c 2-)
server_name=$(dig -x $ip | grep "86400" | grep -E 'PTR' | cut -d 'R' -f 2)

echo ""
echo "+++++++++++++++++++++++++++++++++++++"
echo "|                                   |"
echo "|  Server Name: $server_name        |"
echo "|  IPv4 Address: $ip                |"
echo "|                                   |"
echo "+++++++++++++++++++++++++++++++++++++"


pot_part=$(lsblk | grep -E 'sd|nv' | grep 'part' | cut -d ' ' -f 1 | tr -cd '[.a-zA-Z.\n.1-9]')
dsk_rslts=$( echo $pot_part | wc -l )

echo "Here are the partitions that potentially store your main OS:"
echo $pot_part


for partitions in $(echo $pot_part);
do

mntpnt=$(tune2fs -l /dev/$partitions | grep 'mounted' | cut -d ":" -f 2)


	if [[ $(echo $mntpnt) == "/" ]] || [[ $(echo $mntpnt) == *"/mnt"* ]];
	then

	echo "Main partition detected! Mounting /dev/$partitions to /mnt/$partitions"

	mkdir -p /mnt/$partitions
	mount /dev/$partitions /mnt/$partitions
	echo "Mounted!"
	echo ""

	sleep 1
	break

	else
	continue

	fi
done

echo ""
echo ""

#Username validation
echo "Please type in the username for which you want to change the password:"
read username

#The customer is asked to type in their username in order to change the
#correct user accounts password
#This for loop runs 2 times which gives the customer a total of three attempts
for attempt in `seq 1 3`;
do

#Checks whether the typed in username is in the /etc/passwd file
username_found="$(cat /mnt/$partitions/etc/passwd | grep $username | cut -d ":" -f 1)"

if [ "$username" == "$username_found" ];
then

echo ""
echo "Thank you!"
break 2

elif [ "$attempt" == "3" ];
then

echo ""
echo "We could not identify a user account with the username:" $username
echo "Please make sure to find your username in your records or in the initial VPS installation email."
echo "For further assistance please contact the OVHcloud technical support team."
echo ""
echo ""

#Unmounting the main partition from the mount point
echo "Unmounting /mnt/"$partitions" ..."
sleep 2
umount /mnt/$partitions

#Stopping the script
exit 1

else

echo ""
echo "The username could not be found!"

#Outputs the amount of attempts that are left
echo $(( 3 - $attempt ))" attempts left"
echo "Please type in your username:"
read username

fi

done

#Password change announcement
echo ""
echo "##########################################################################################################"
echo "You will now be asked to enter a new password and re-enter it. Please make sure to remember your password."
sleep 2

#Chroot into mount point
chroot /mnt/$partitions/ passwd $username
echo ""
echo ""
sleep 1

#Unmounting the main partition from the mount point
echo "Unmounting /mnt/"$partitions" ..."
sleep 1
umount /mnt/$partitions

#Final success message
echo ""
echo "YOUR ROOT PASSWORD HAS SUCCESSFULLY BEEN UPDATED!"
echo "You can now reboot your server from your main partition in the OVHcloud control panel."
echo "If you need further assistance feel free to contact the OVHcloud technical support."
echo "######################################################################################"
