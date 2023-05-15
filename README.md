<img src="https://github.com/bysecurety/passwdreset/blob/main/OVHcloudVPSpasswdreset.jpg">

# Changing your root password if you have lost it
</br>
</br>
It can always happen that you lose or forget your root password and now are not able to SSH into your VPS and neither use the KVM from the OVHcloud control panel.

OVHcloud provided it's customers with a guide on how to fix the issue but sometimes things just have to be done very quick 
and without too much typing. Or maybe you have lost it for multiple VPSs and need a quick and fast solution.

This is where the Bash script in this Git repo comes in handy. With just one command you can deploy the script to your VPS in rescue mode and 
the script will handle the main partition detection, mount point creation, mounting and the password change. 

The only thing you will have to do is to type in your rescue mode password twice, specify the username of your main OS (the account you lost the password for) and re-enter your password twice.

That's it!
</br>
</br>
</br>
<h2>Usage:</h2>

Before you can use the Bash script I would recommend to create a seperate folder and place the script in it.
The PingSweeper generates dated cache/result files for each sweep and saves them in the script's directory.
</br>
</br>
In order to execute the script you will have to make it executable with the following command:
</br>
</br>
`'sudo chmod 777 PATH_TO_BASHSCRIPT/pingsweep-v02-0422-debian.sh'`
</br>
</br>
To launch the script run:

`'source PATH_TO_BASHSCRIPT/pingsweep-v02-0422-debian.sh'`
</br>
</br>
Happy Sweeping!

And you will most definitely encounter bugs and errors. </br>
Please  report them here https://github.com/bysecurety/PingSweeper/issues </br>
or send me an email at cysecdevops@proton.me


