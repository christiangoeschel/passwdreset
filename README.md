<img src="https://github.com/bysecurety/passwdreset/blob/main/passwdreset.png">

# Changing the user password of an OVHcloud server if you have lost it
</br>
</br>
It can sometimes happen that you lose or forget your user password and now are not able to SSH into your server and neither use the KVM from the OVHcloud control panel.
</br></br>
Eventhough, OVHcloud provides it's customers with a guide on how to fix the issue, sometimes things just have to be done very quickly 
and without too much typing. Or maybe you have lost it for multiple servers and need a quick and scalable solution.
</br></br>
This is where this Bash script comes in handy. With just one command you can deploy the script to your server in rescue mode and 
the script will handle the main partition detection, mount point creation, mounting and the password change. 
</br></br>
The only thing you will have to do is to specify the username of your main OS (the account you lost the password for) and re-enter your new password twice.
</br></br>
That's it!
</br>
</br>
<h2>Usage:</h2>
Before you can use the Bash script you will have to boot your server in rescue mode first.
You can do that in the OVHcloud control panel on your server's dashboard.
</br></br>
After that you will receive temporary login credentials which you will need for the one line command that will deploy and launch the 
password change script.
</br>
</br>
Once you have received the credentials, login to your server and enter this one line command in your terminal:
</br></br>
Command:
</br></br>

` wget https://raw.githubusercontent.com/bysecurety/passwdreset/main/passwordreset.sh && chmod +x passwordreset.sh && source passwordreset.sh `
</br>
</br>
Hit enter and let the script do the rest.
</br></br>
If you have any questions or trouble feel free to contact the OVHcloud technical support or refer to the guides down below:
</br></br>
</br>
<h2>VPS</h2>
</br>
<h4>Changing password if you have lost it:</h4>
https://help.ovhcloud.com/csm/en-ca-vps-root-password?id=kb_article_view&sysparm_article=KB0047679#changing-the-password-if-you-have-lost-it
</br>
<h4>How to boot into rescue mode:</h4>
https://help.ovhcloud.com/csm/en-ca-vps-rescue?id=kb_article_view&sysparm_article=KB0047655#:~:text=Rescue%20mode%20is%20a%20tool,Resetting%20your%20root%20password
</br></br>

<h2>Dedicated server</h2>
</br>
<h4>Changing password if you have lost it:</h4>
https://help.ovhcloud.com/csm/en-ca-dedicated-servers-root-password?id=kb_article_view&sysparm_article=KB0043305
</br>
<h4>How to boot into rescue mode:</h4>
https://help.ovhcloud.com/csm/en-ca-dedicated-servers-ovhcloud-rescue?id=kb_article_view&sysparm_article=KB0030995#:~:text=You%20can%20activate%20rescue%20mode,select%20Boot%20in%20rescue%20mode.

