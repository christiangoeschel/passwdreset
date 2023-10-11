#!/bin/bash
#
#Password reset script to automate the main partition identification and mounting
#for the password update/reset
#
#Author: Christian Goeschel Ndjomouo
#Version:1.1

#############################################
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

##########################################################################################
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

##########################################################################################
#Dnsutils (dig) package availability check, this tool will help to identify the server type

digutil=$(which dig)
echo ""
echo "Checking for dnsutils (dig)..."
sleep 1

if [[ $digutil == *"dig"* ]];
then

echo ""
echo "dnsutils (dig) already installed!"

else

echo ""
echo "Installing dnsutil (dig)..."
apt install dnsutils -y
sleep 1

fi

#############################################
#Server type identification



ip=$(ip -o a | grep -E 'ens3.*inet|eth0.*inet' | grep -v 'inet6' | cut -d '/' -f 1 | cut -d ' ' -f 7)
server_name=$(dig -x $ip | grep -E 'ns|vps' | grep -E 'PTR' | cut -d 'R' -f 2)
server_type=""


for a in `seq 1 4`;
do

        if [[ $a == "3" ]];
        then

        echo "Too many ambigious inputs. Stopping script ..."
        sleep 2
        exit 0

        elif [[ $server_name == *"vps"* ]];
        then

        server_type="VPS"
        break

        elif [[ $server_name == *"ns"* ]];
        then

        server_type="Dedicated Server"
        break

        else

        echo -e "\nPlease indicated whether your server is a VPS ( V ) or a Dedicated server ( D ) with the respective character:"
        read server_type

                if [[ $server_type == "V" ]];
                then

                server_type="VPS"
                break

                elif [[ $server_type == "D" ]];
                then

                server_type="Dedicated Server"
                break

                else
                continue

                fi
        fi


done


#############################################
#Server information


echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "|                                                           |"
echo "|  Server Name: $server_name                                |"
echo "|  IPv4 Address: $ip                                        |"
echo "|  Server Type: $server_type                                |"
echo "|                                                           |"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


#############################################
#Server type dependent if statement

if [[ $server_type == "VPS" ]];
then

    #############################################
    #VPS Partition detection

    biggest_prt_size=0
    biggest_prt=""

    pot_part=$(lsblk | grep -E 'sd|nv' | grep 'part' | grep 'G' | cut -d ' ' -f 1 | tr -cd '[a-zA-Z.\n.1-9]')

    for partitions in $(echo $pot_part);
    do

            part_size=$(lsblk -l /dev/$partitions | grep "G" | cut -d "G" -f 1 | cut -d "0" -f 2 | tr -cd '[0-9..]')

            if [[ $part_size > $biggest_prt_size ]];
            then

                    biggest_prt_size=$part_size
                    biggest_prt=$partitions

            fi
    done

            echo ""
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Main partition detected! Mounting /dev/$partitions to /mnt/$partitions ..."
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

            mkdir -p /mnt/$partitions
            mount /dev/$partitions /mnt/$partitions
            echo ""
            echo "MOUNTED!"
            echo ""
            sleep 1


elif [[ $server_type == "Dedicated Server" ]];
then

    #############################################
    #Dedicated server partition detection

    pot_part=$(lsblk | grep -E 'sd|nv' | grep 'part' | cut -d ' ' -f 1 | tr -cd '[.a-zA-Z.\n.0-9]')
    dsk_rslts=$( echo $pot_part | wc -l )

    for partitions in $(echo $pot_part);
    do

    mntpnt=$(tune2fs -l /dev/$partitions | grep 'mounted' | cut -d ":" -f 2 )


        if [[ $(echo $mntpnt) == "/" ]] || [[ $(echo $mntpnt) == *"/mnt"* ]];
        then

            echo ""
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
            echo "Main partition detected! Mounting /dev/$partitions to /mnt/$partitions ..."
            echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

            mkdir -p /mnt/$partitions
            mount /dev/$partitions /mnt/$partitions
            echo ""
            echo "MOUNTED!"
            echo ""
            sleep 1
            break

        else
            continue

        fi
    done


else

        #############################################
        #Main partition detection failure

        echo "                                          FAILURE                                        "
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                echo "|                                                                                       |"
                echo "|  Unfortunately, we could not detect the main partition.                               |"
                echo "|  Please have a look at the partition list down below and determine which one it is.   |"
                echo "|                                                                                       |"
                echo "|  Once you have located the main partition, enter it in the prompt down below.         |"
                echo "|                                                                                       |"
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


                lsblk
                sleep 2
        echo ""
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                echo "Please type in the partition name:"
        read $partitions

        echo ""
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "Main partition detected! Mounting /dev/$partitions to /mnt/$partitions ..."
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

        mkdir -p /mnt/$partitions
        mount /dev/$partitions /mnt/$partitions
        echo ""
        echo "MOUNTED!"
        echo ""
        sleep 1


fi



#############################################
#Username validation

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
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

                echo "                                          FAILURE                                        "
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
                echo "|                                                                                       |"
                echo "|  We could not identify a user account with the username: $username                    |"
                echo "|  Please make sure to find the username in your records or in the                      |"
                echo "|  initial VPS installation email.                                                      |"
                echo "|                                                                                       |"
                echo "|  For further assistance please contact the OVHcloud technical support team.           |"
                echo "|                                                                                       |"
                echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

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

#############################################
#Password change announcement

echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "You will now be asked to enter a new password and re-enter it."
echo "Please make sure to remember your password."
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

sleep 1

#############################################
#Chroot into mount point
chroot /mnt/$partitions/ passwd $username
echo ""
echo ""
sleep 1

##########################################################
#Unmounting the main partition from the mount point
echo "Unmounting /mnt/"$partitions" ..."
sleep 1
umount /mnt/$partitions

#############################################
#Final success message
echo ""
echo "                                          SUCCESS                                        "
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "|                                                                                       |"
echo "|  YOUR PASSWORD HAS SUCCESSFULLY BEEN UPDATED!                                         |"
echo "|  You can now reboot your server from hard drive in the OVHcloud control panel.        |"
echo "|  If you need further assistance feel free to contact the OVHcloud technical support.  |"
echo "|                                                                                       |"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
