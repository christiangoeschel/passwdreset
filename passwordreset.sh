#!/bin/bash
#
# [ Name ]:             Password Reset Automation 
# [ Version ]:          1.2
# [ Author ]:           Christian Goeschel Ndjomouo
# [ Created on ]:       May 13 2023
# [ Last updated on ]:  Oct 11 2023
# [ Tested on ]:        All Linux images offered by OVHcloud ( VPS and Dedicated server )
#
# [ Description ]:      This program will take care of the main partition detection, mount point creation and final mounting. 
#                       It will also detect the root directory of the customers main partition to make the password reset possible. 
#                       
#                       
#   
echo ""
echo "+------------------------------------------------------------------------------------+"
echo "|                                                                                    |"
echo "|  This program will handle the identification and mounting of your main partition   |"
echo "|  to then change the root directory in order to reset your lost password.           |"
echo "|                                                                                    |"
echo "+------------------------------------------------------------------------------------+"
echo ""
echo "Starting program now ..."
sleep 2

#   Tune2fs package availability check, this tool will help to identify the main partition
t2fs_path=$(which tune2fs)  # Checking whether 'tune2fs' is found in any of the in the $PATH variable specified directories
echo ""
echo "Checking for tune2fs ..."
sleep 1

#   If the 't2fs_path' variable value includes the string 'bin' it is safe to say that tune2fs binary has been installed
if [[ $t2fs_path == *"bin"* ]];
    then
    echo ""
    echo "tune2fs already installed!"

else
    echo ""
    echo "Installing tune2fs..."
    apt install e2fslibs -y
    sleep 1

fi

#   Server type identification
#   Here we will identify the server type via the hostname which we will receive from the 'uname -n' command
server_name=$(uname -n | grep -Eo "(^vps|^ns)")
server_type=""

#   The for loop runs 3 times and gives the user 3 chances to type in the server type manually.
#   This would only happen if the 'uname -n' output was not enough to determine the server type.
for a in `seq 1 3`;
do      

        # If user reaches his third attempt the program will exit and terminate
        if [ $a == "3" ];     
        then

        echo -e "\nToo many ambigious inputs. Stopping program ..."
        sleep 2
        exit 0

        elif [ $server_name == "vps" ];
        then

        server_type="V"
        break

        elif [ $server_name == "ns" ];
        then

        server_type="D"
        break

        #   This block would be executed if the 'uname -n' output was not sufficient to determine the server type
        else

        echo -e "\n[ Please indicated whether your server is a VPS ( V ) or a Dedicated server ( D ) with the respective character ]:"
        read server_type

                #   User input was V or v so the server type is set to V for (VPS)
                if [ $server_type == "V" ] || [ $server_type == "v" ];
                then

                server_type="V"
                break

                #   User input was D or d so the server type is set to D for (Dedicated server) 
                elif [ $server_type == "D" ] || [ $server_type == "d" ];
                then

                server_type="D"
                break

                #   If none of the above options ( V,v or D,d ) was entered the loop will continue to the next iteration
                else
                continue

                fi
        fi
done

#   This flow control depends on the server type
#
#   Code block will be executed if the server is a dedicated server
if [ $server_type == "V" ];
then
    #    VPS Partition detection 
    #    The biggest partition will finally be determined as the main partition
    biggest_prt_size=0
    biggest_prt=""
    
    #    This variable will extract all the potential partitions from lsblk
    potential_part=$(lsblk | grep -E 'sd|nv' | grep 'part' | grep 'G' | cut -d ' ' -f 1 | tr -cd '[a-zA-Z.\n.1-9]')

    #    The for loop will run through all the partitions listed in the potential_part variable
    for partition in $(echo $potential_part);
    do
            part_size=$(lsblk -l /dev/$partition | grep "G" | cut -d "G" -f 1 | cut -d "0" -f 2 | tr -cd '[0-9..]')

            if [ $part_size > $biggest_prt_size ];
            then
                    biggest_prt_size=$part_size
                    biggest_prt=$partition
            fi
    done
    #    Loop end
            echo -e "\nMain partition detected! \nMounting /dev/$partition to /mnt/$partition ..."
            #   Creating the mount point directory
            mkdir -p /mnt/$partition
            #   Mounting the main partition to the mount point directory
            mount /dev/$partition /mnt/$partition
            
            echo -e "\nMain partition /dev/$partition has been mounted successfully !!!"
            echo "Analyzing file system and determining root directory ..." 
            sleep 2

#   Code block will be executed if the server is a dedicated server
elif [[ $server_type == "D" ]];
then  
    #    Dedicated server partition detection
    #    The partition lastly mounted at "/" is the main partition
    #    This variable will extract all the potential partitions from lsblk
    potential_part=$(lsblk | grep -E 'sd|nv' | grep 'part' | cut -d ' ' -f 1 | tr -cd '[.a-zA-Z.\n.0-9]')
    
    #    The for loop will run through all the partitions listed in the potential_part variable
    for partition in $(echo $potential_part);
    do

    #    tune2fs will print the partitions information and it's last mount point
    #    the partition that was mounted at "/" will qualify as the main partition
    mounted_at=$(tune2fs -l /dev/$partition | grep 'mounted' | cut -d ":" -f 2 )

        #   If the currently selected partition's last mount point was "/" 
        #   it will qualify as the main partition
        if [ $(echo $mounted_at) == "/" ] || [ $(echo $mounted_at) == *"/mnt"* ];
        then
            echo -e "\nMain partition detected! \nMounting /dev/$partition to /mnt/$partition ..."
            #   Creating the mount point directory
            mkdir -p /mnt/$partition
            #   Mounting the main partition to the mount point directory
            mount /dev/$partition /mnt/$partition
            
            echo -e "\nMain partition /dev/$partition has been mounted successfully !!!"
            echo "Analyzing file system and determining root directory ..." 
            sleep 2
            break
        
        #   If the currently selected partition could not be identified as the main partition
        #   the loop will continue with the next iteration
        else
            continue

        fi
    done

#   Code block will be executed if the server type could not have been determined
#   The program will have to prompt a message to the user to manually identify the main partition
else

        #Main partition detection failure message
        echo -e "\n[ ERROR ]"
        echo "Unfortunately, we could not detect the main partition."
        echo "[ Please have a look at the partition list down below and determine which one it is ]"
        echo -e "\nOnce you have located the main partition, enter it in the prompt down below.\n"

        #   Printing the block devices detected by the kernel
        lsblk
        
        sleep 2
        echo "Please type in the partition name ( sdXx or nvmeXnXpX ):"
        read $partition
        echo -e "\n[ SUCCESS ]"
        echo -e "\nMain partition detected! \nMounting /dev/$partition to /mnt/$partition ..."
        #   Creating the mount point directory
        mkdir -p /mnt/$partition
        #   Mounting the main partition to the mount point directory
        mount /dev/$partition /mnt/$partition
    
        echo -e "\nMain partition /dev/$partition has been mounted successfully !!!"
        echo "Analyzing file system and determining root directory ..." 
        sleep 2
fi

#   Username validation
#
#   The customer is asked to type in their username in order to change the
#   correct user accounts password
echo -e "\n\n[ Please type in the username for which you want to change the password ]\n"
echo "It is NOT 'root' it is the username you have received after your last installation via email."
echo "Type in username: "
read username


#   This for loop gives the customer a total of three attempts
for attempt in `seq 1 3`;
do

#   Checks whether the typed in username is in the /etc/passwd file
        passwd_file_dir="$(find /mnt/$partition/ -type f -name 'passwd' | grep -E 'etc/passwd$')"
        username_found="$(cat $passwd_file_dir | grep $username | cut -d ':' -f 1)"
        
        if [ "$username" == "$username_found" ];
        then

                echo -e "\n[ SUCCESS ]"
                echo -e "Found user: \"$username\" in $passwd_file_dir"
                break 2

        elif [ "$attempt" == "3" ];
        then

                echo -e "\n[ FATAL ERROR ]"
                echo "We could not identify an user account with for: $username "
                echo "Please make sure to find the username in your records or in the"
                echo "your last VPS installation email."
                echo "For further assistance please contact the OVHcloud technical support team."

                #    Unmounting the main partition from the mount point
                echo -e "\nUnmounting /mnt/"$partition" ..."
                sleep 1
                umount /mnt/$partition

                #    Stopping the script
                echo -e "\n[ EXITING PROGRAM ... ]\n"
                exit 1

        else
                echo -e "\n[ ERROR ]"
                echo "The username "$username" could not be found!"

                #    Outputs the amount of attempts that are left
                echo $(( 3 - $attempt ))" attempt(s) left"
                echo "Please type in your username: "
                read username
        fi
done

#   Password change message
echo ""
echo "[ You will now be asked to enter a new password and to re-enter it ]"
echo -e "Please make sure to remember your password !\n"
sleep 3

#   Changing root directory to the main partition
#
#   This pattern template will filter out the root directory in the main partition
chroot_dir="$(find /mnt/$partition/ -type f -name 'passwd' | grep -E 'etc/passwd$' | sed 's/etc\/passwd//')"
#   Changing the root directory
echo "Changing the root directory to $chroot_dir"
#   Evoking the passwd binary with the username variable as argument in the new root directory
chroot $chroot_dir passwd $username
echo ""
sleep 1

#   Unmounting the main partition from the mount point
echo "Unmounting /mnt/"$partition" ..."
sleep 1
umount /mnt/$partition
echo -e "\n[ TERMINATING PROGRAM ... ]\n"
