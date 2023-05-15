#!/bin/bash
#
#Password reset Script for the following issue
#https://help.ovhcloud.com/csm/en-ca-vps-root-password?id=kb_article_view&sysparm_article=KB0047679#changing-the-password-if-you-have-lost-it
#Author: Christian Goeschel Ndjomouo
#Version:1.0


##VARIABLE DECLERATION
#
diskname="" #The determined main partition
username="" #Username that the customer uses on his main OS

#Creation and permission assignment of all temporary files that contain the partition names and sizes
sudo touch disklistfile.txt && sudo chmod 777 disklistfile.txt
sudo touch disk_sizes.txt && sudo chmod 777 disk_sizes.txt

#Start of script output
echo ""
echo "###################################################################################"
echo "This Bash script will handle the identification and mounting of your main partition"
echo "and help you update/reset your root password."
echo ""
echo ""
echo "Analyzing filesystem and determining the main partition ..."
sleep 2

#lsblk lists all partitions, this output is stored in a txt file temporarily for later processing 
lsblk > disklistfile.txt


#Extracting the partition size of each partition to which the algorithm below applies to 
#Only the partitions that have a partition size measured in Gigabytes are being considered
#The results are stored in a seperate temporary txt file
( sudo grep "part" disklistfile.txt | grep "G" | cut -d "G" -f 1 | cut -d "0" -f 2 > disk_sizes.txt )

#The variable that has the value of the biggest partition size 
biggest_disk_size="$(sort -n -r disk_sizes.txt | head -1 | cut -d " " -f 2)"

#Searching for the partition name that corresponds to the biggest patition size, extracting its name and saving it in a variable
diskname="$(grep "$biggest_disk_size" disklistfile.txt | grep "G" | cut -d "G" -f 1 | cut -d " " -f 1 | tr -cd '[:alnum:]')"


echo "Identified main partition: /dev/"$diskname
echo "Mounting main partition /dev/"$diskname" to /mnt/"$diskname
sleep 1

#Creation of the mount point directory and mounting of the primary partition
mkdir -p /mnt/$diskname
mount /dev/$diskname /mnt/$diskname
echo "Mounted!"
echo ""
sleep 1

#Username validation
echo "Please type in the username for which you want to change the password:"
read username

#The customer is asked to type in their username in order to change the
#correct user accounts password
#This for loop runs 2 times which gives the customer a total of three attempts
for attempt in `seq 1 3`;
do

#Checks whether the typed in username is in the /etc/passwd file
username_found="$(cat /mnt/$diskname/etc/passwd | grep $username | cut -d ":" -f 1)"

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

#Deletion of all temporary files
echo "Deleting script related files ..."
sleep 1
rm disklistfile.txt
rm disk_sizes.txt

#Unmounting the main partition from the mount point
echo "Unmounting /mnt/"$diskname" ..."
sleep 2
umount /mnt/$diskname

#Stopping the script
exit 130

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
chroot /mnt/$diskname/ passwd $username
echo ""
echo ""
sleep 1

#Deletion of all temporary files
echo "Deleting script related files ..."
sleep 1
rm disklistfile.txt
rm disk_sizes.txt

#Unmounting the main partition from the mount point
echo "Unmounting /mnt/"$diskname" ..."
sleep 1
umount /mnt/$diskname

#Final success message
echo ""
echo "YOUR ROOT PASSWORD HAS SUCCESSFULLY BEEN UPDATED!"
echo "You can now reboot your server from your main partition in the OVHcloud control panel."
echo "If you need further assistance feel free to contact the OVHcloud technical support."
echo "######################################################################################"
