<img src="https://github.com/bysecurety/passwdreset/blob/main/OVHcloudVPSpasswdreset.jpg">

# Changing your root password if you have lost it
</br>
</br>
It can always happen that you lose or forget your root password and now are not able to SSH into your VPS and neither use the KVM from the OVHcloud control panel.
</br></br>
Eventhough, OVHcloud provides it's customers with a guide on how to fix the issue, sometimes things just have to be done very quickly 
and without too much typing. Or maybe you have lost it for multiple VPSs and need a quick and fast solution.
</br></br>
This is where the Bash script in this Git repo comes in handy. With just one command you can deploy the script to your VPS in rescue mode and 
the script will handle the main partition detection, mount point creation, mounting and the password change. 
</br></br>
The only thing you will have to do is to type in your rescue mode password twice, specify the username of your main OS (the account you lost the password for) and re-enter your password twice.
</br></br>
That's it!
</br>
</br>
</br>
<h2>Usage:</h2>
Before you can use the Bash script you will have to boot your VPS in rescue mode first.
You can do that in the OVHcloud control panel on your VPS'dashboard.
</br></br>
After that you will receive temporary login credentials which you will need for the one line command that will deploy and launch the 
password change script.
</br>
</br>
Once you have received the credentials download this script and open a terminal / command line interface on your computer.
</br>
</br>
Paste the command down below to the terminal. 
</br></br>
Change "VPS_IP" to your VPS' IPv4 address and make sure that the path to the downloaded script file is correct and change the "PATH/" in "PATH/passwordreset.sh" if necessary.
</br></br>
Now hit enter and let your computer execute the command.
</br></br>
Command:
</br></br>
`scp PATH/passwordreset.sh root@VPS_IP:/root && ssh root@VPS_IP "chmod 777 passwordreset.sh; source passwordreset.sh"`
</br>
</br>
You will be asked to enter a password twice this will be the password for the rescue mode that you have previously received via email.
After that the script will be deployed and executed and you will simply have to follow the few instructions and complete the password changing process.
</br>
</br>
If you have any questions or trouble feel free to contact the OVHcloud technical support or refer to the guides down below:
</br>
Changing password if you have lost it:
https://help.ovhcloud.com/csm/en-ca-vps-root-password?id=kb_article_view&sysparm_article=KB0047679#changing-the-password-if-you-have-lost-it
</br>
How to boot into rescue mode:
https://help.ovhcloud.com/csm/en-ca-vps-rescue?id=kb_article_view&sysparm_article=KB0047655#:~:text=Rescue%20mode%20is%20a%20tool,Resetting%20your%20root%20password



