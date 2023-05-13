#!/bin/bash
#Password Reset Script for OVHcloud VPS running Linux Debian

###VARIABLE DECLERATION
#
diskname="" #The final diskname that has been determined as main partition
username="" #User defined username that he uses on his main OS
highest_disksize_cache=0 #The highest disk size of all the potential disks/partitions


#Creation and writing of a file that contains the disks and partitions
sudo touch disklistfile.txt
sudo chmod 777 disklistfile.txt
sudo touch disk_sizes.txt
sudo chmod 777 disk_sizes.txt

echo "This script will help you reset your root password and gain back access to your VPS"
echo ""

echo "Analyzing filesystem and determining the main partition ..."
sleep 2
#Listing all partitions and extracting most relevant ones to determine the OS' partition based on the biggest size in Gigabytes
lsblk > disklistfile.txt


#Grabbing the partition size of each potential partition
( sudo grep "part" disklistfile.txt | grep "G" | cut -d "G" -f 1 | cut -d "0" -f 2 > disk_sizes.txt )

#Determines the biggest partition size and saves it in a variable
biggest_disk_size="$(sort -n -r disk_sizes.txt | head -1 | cut -d " " -f 2)"
#echo $biggest_disk_size

#Searching for the partition name that corresponds to the biggest patition size, extracting its name and saving it in a variable
diskname="$(grep "$biggest_disk_size" disklistfile.txt | grep "G" | cut -d "G" -f 1 | cut -d " " -f 1 | tr -cd '[:alnum:]')"
#echo $diskname

echo "Mounting main partition ..."
sleep 2
#Creation of the mount point and mounting of the primary partition
mkdir -p /mnt/$diskname
mount /dev/$diskname /mnt/$diskname
echo "Mounted!"
echo ""
sleep 1

#Username validation
echo "Please type in the username for which you want to change the password:"
read username

#Checks whether the typed in username is in the /etc/passwd file
username_found="$(cat /mnt/$diskname/etc/passwd | grep $username | cut -d ":" -f 1)"

if [ "$username" == "$username_found" ]
then

echo "Thank you!"

else

echo "The username could not be found, please type in the correct username:"
read username

fi

echo ""
#Password change announcement
echo "You will now be asked to enter a new password and re-enter it. Please make sure to remember your password."
sleep 2
#Chroot in mounted partition
chroot /mnt/$diskname/ passwd $username

echo ""
echo ""

#Deletion of disklistfile.txt
rm disklistfile.txt
rm disk_sizes.txt

echo "Unmounting /dev/"$diskname" ..."
sleep 2
#Unmounting of 
umount /mnt/$diskname
echo ""
echo ""
echo "Your root password has successfully been changed!"
echo "You can now reboot your server from your main partition in the OVHcloud control panel."
echo "If you need further assistance feel free to contact us at any given time."