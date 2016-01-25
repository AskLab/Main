#!/bin/bash
mac=$(cat /sys/class/net/eth0/address)
var=${mac//:}
repo=/home/root/usr/AskRepo
defaultRepo=/home/root/usr/DefaultRepo
addressDatabase=ipDatabase.txt
currentTime=$(date +"%m-%d-%y_%H%M")

#Checking for git on machine
version=$(git --version)
if [[ $version == *"command not found"* ]]
then
	echo "GIT not found getting it"
	apt-get install git-all
else
	echo "Found GIT"
fi

#Setting git repositories
cd
rm -rf $repo
rm -rf $defaultRepo

cd
git clone https://AskLab:student123@github.com/AskLab/Default.git $defaultRepo

#Choosing what group we want to expand
echo "Enter what kind of PC is this, admin/user/highClient"
read pctype
echo "What interface you want to set?"
read interface

#Configuring interface
declare file="/run/network/ifstate"
declare file_content=$( cat "${file}" )

if [[ " $file_content " == *"$interface"* ]]
then
	echo "doing sed"
	sed -i '/'$interface'/c'$interface'='$interface'' /run/network/ifstate
else
	echo "$interface=$interface" >> /run/network/ifstate
fi
if [ $pctype = "admin" ]
	#Downloading main group options
	then echo "Setting up options for admin"
	cd
	git clone https://AskLab:student123@github.com/AskLab/AdminOptions.git $repo

	#Saving updated ipDatabase on git
	echo "Saving updated ipDatabase on git"	
	bash $repo/setIpScript.sh $interface
	git init $defaultRepo
	cd $defaultRepo
	git add $addressDatabase
	git commit -m "$var"
	git push -u origin master
	
	#Saving current options on branch for this machine
	cp -f /etc/network/interfaces $repo
	cd $repo
	git checkout -b $var
	git add interfaces
	git commit -m "$currentTime"
	git push -u origin $var
	echo "Committed current options on $var branch with $currentTime commit message"
	
elif [ $pctype = "user" ]
	#Downloading main group options
	then echo "Setting up options for user"
	cd
	git clone https://AskLab:student123@github.com/AskLab/UserOptions.git $repo
	
	#Saving updated ipDatabase on git
	bash $repo/setIpScript.sh $interface
	git init $defaultRepo
	cd $defaultRepo
	git add $addressDatabase
	git commit -m "$var"
	git push -u origin master
	
	#Saving current options on branch for this machine
	cp -f /etc/network/interfaces $repo
	cd $repo
	git checkout -b $var
	git add interfaces
	git commit -m "$currentTime"
	git push -u origin $var
	echo "Committed current options on $var branch with $currentTime commit message"

elif [ $pctype = "highClient" ]
	#Downloading main group options
	then echo "Setting up options for high IP user"
	cd
	git clone https://AskLab:student123@github.com/AskLab/LaterUser.git $repo
	
	#Saving updated ipDatabase on git
	bash $repo/setIpScript.sh $interface
	git init $defaultRepo
	cd $defaultRepo
	git add $addressDatabase
	git commit -m "$var"
	git push -u origin master
	
	#Saving current options on branch for this machine
	cp -f /etc/network/interfaces $repo
	cd $repo
	git checkout -b $var
	git add interfaces
	git commit -m "$currentTime"
	git push -u origin $var
	echo "Committed current options on $var branch with $currentTime commit message"
else
	echo "Not recognized command"
fi
