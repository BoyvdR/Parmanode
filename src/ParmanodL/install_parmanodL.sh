function ParmanodL_build {

if [[ $1 == d ]] ; then export debug=true ; else export debug=false ; fi

if [ ! -e $HOME/parman_programs/parmanode/do_not_delete_move_rename.txt ] ; then
clear ; echo "
########################################################################################

    The Parmanode software is required to run this script. It will be downloaded now.

	Hit n and <enter> to abort.

########################################################################################
" ; read choice ; case $choice in n) return 1 ;; esac
curl https://parmanode.com/install.sh | sh
counter=$((counter + 1))
fi

clear ; echo "
########################################################################################

    Parmanode will now update itself (Your installed programs won't be affected)

	<enter> to continue

########################################################################################
"
read && clear
cd $HOME/parman_programs/parmanode && git pull && clear

if [ ! -e $HOME/parman_programs/parmanode/do_not_delete_move_rename.txt ] ; then
clear ; echo "failed to get Parmanode, aborting." ; sleep 2 ; exit ; fi


source $HOME/parman_programs/parmanode/src/ParmanodL/detect_microSD.sh2

for file in ~/parman_programs/parmanode/src/**/*.sh ; do 

		if [[ $file != *"/postgres_script.sh" ]]; then
	    source $file 
		fi 

	done

################################################################################################################################

#remember to set terminal wider for ssh into parmanodL
# HOW TO BUILD
# Need a Raspi 64 bit, with 32GB microSD capacity


# Prepare working directoris

	mkdir -p $HOME/parman_programs/ParmanodL 
	mkdir -p $HOME/.parmanode

	#Rasbperry Pi OS, 64 bit, with Desktop.
	cd $HOME/parman_programs/ParmanodL
	if [ ! -e 2023-05-03-raspios-bullseye-arm64.img.xz ] ; then
	curl -LO https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64.img.xz

	# Check integrity.

		if ! shasum -a 256 *.img.xz | grep e7c0c89db32d457298fbe93195e9d11e3e6b4eb9e0683a7beb1598ea39a0a7aa ; then
			echo "sha256 failed. Aborting"
			enter_continue
			return 1
		fi
	fi

	if [ ! -e 2023-05-03-raspios-bullseye-arm64.img ] ; then
	# Unzip the image:
	xz -vkd 2023-05-03-raspios-bullseye-arm64.img.xz
	fi

ParmanodL_mount
ParmanodL_chroot
read -p "pause here and check stuff"
unmount_image

#Write image
if [[ $debug == true ]] ; then
	read -p "about to write. y or n" choice
	case $choice in y) write_image ;;
	esac
else
    write_image 
fi
clear_known_hosts

}

function ParmanodL_mount {
# Caculate offset for image, needed for mount command later.
start=$(sudo fdisk -l $HOME/parman_programs/ParmanodL/2023-05-03-raspios-bullseye-arm64.img | grep img2 | awk '{print $2'}) >/dev/null
start2=$(($start*512)) >/dev/null

# Make mountpoint
if [[ ! -e /mnt/raspi ]] ; then sudo mkdir -p /mnt/raspi ; fi

# Mount
sudo mount -v -o offset=$start2 -t ext4 2*.img /mnt/raspi >/dev/null || { echo "failed mount" ; return 1 ; }

# Bind file systems needed, just in case.
sudo mount --bind /dev /mnt/raspi/dev >/dev/null 2>&1 
sudo mount --bind /sys /mnt/raspi/sys >/dev/null 2>&1
sudo mount --bind /proc /mnt/raspi/proc >/dev/null 2>&1
}

function ParmanodL_chroot {


set_keyboard ; set_wifi_country ; set_timezone ; set_locale

sudo chroot /mnt/raspi /bin/bash -c "apt update -y && apt upgrade -y ; exit "
sudo chroot /mnt/raspi /bin/bash -c "groupadd -r parman ; useradd -m -g parman parman ; usermod -aG sudo parman ; exit "
sudo chroot /mnt/raspi /bin/bash -c 'echo "parman:parmanodl" | chpasswd ; systemctl enable ssh ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'chage -d 0 parman ; exit' 
sudo chroot /mnt/raspi /bin/bash -c "apt purge piwiz -y ; exit" 
sudo chroot /mnt/raspi /bin/bash -c 'userdel rpi-first-boot-wizard pi ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'rm -rf /home/pi /home/rpi* ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "Defaults lecture=never" >> /etc/sudoers ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "" > /etc/motd ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'sed -i "/autologin-user=/d" /etc/lightdm/lightdm.conf ; exit' 
sudo chroot /mnt/raspi /bin/bash -c 'echo "PrintLastLog no" >> /etc/ssh/sshd_config ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'rfkill unblock wifi ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "" > /etc/ssh/sshd_config.d/rename_user.conf ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'mkdir -p /home/parman/parmanode /home/parman/.parmanode ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'mkdir -p /home/parman/parman_programs/parmanode ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "message_instructions=1" > /home/parman/.parmanode/hide_messages.conf ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "parmanode-start" > /home/parman/.parmanode/installed.conf ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "parmanode-end" > /home/parman/.parmanode/installed.conf ; exit'
sudo chroot /mnt/raspi /bin/bash -c 'echo "parmanodl" > /etc/hostname ; exit'

sudo cp -r $HOME/parman_programs/parmanode/* /mnt/raspi/home/parman/parman_programs/parmanode/
sudo chown -R parman:parman /mnt/raspi/home/parman


echo '

WELCOME TO...

.______      ___      .______    .___  ___.      ___      .__   __.   ______    _______   __      
|   _  \    /   \     |   _  \   |   \/   |     /   \     |  \ |  |  /  __  \  |   __  \ |  |     
|  |_)  |  /  ^  \    |  |_)  |  |  \  /  |    /  ^  \    |   \|  | |  |  |  | |  T  |  ||  |     
|   ___/  /  /_\  \   |      /   |  |\/|  |   /  /_\  \   |  `    | |  |  |  | |  |  |  ||  |     
|  |     /  _____  \  |  |\  \   |  |  |  |  /  /   \  \  |  | `  | |  |__|  | |  |__|  ||  |____
| _|    /__/     \__\ | _| `._\__|__|  |__| /__/     \__\ |__| \__|  \______/  |_______/ |_______|


' > $HOME/parman_programs/ParmanodL/banner.txt
sudo cp $HOME/parman_programs/ParmanodL/banner.txt /mnt/raspi/tmp/banner.txt
sudo chroot /mnt/raspi /bin/bash -c 'cat /tmp/banner.txt > /etc/motd ; exit'
rm $HOME/parman_programs/ParmanodL/banner.txt
}

function unmount_image {
# umount evertying
sudo umount /mnt/raspi/dev
sudo umount /mnt/raspi/sys
sudo umount /mnt/raspi/proc
sudo umount /mnt/raspi
}

function write_image {
#dd the drive
# umount first
detect_microSD #result will be in the form /dev/xxx with no number at the end and stored in disk variable
cd $HOME/parman_programs/ParmanodL
sudo umount ${disk}* >/dev/null 2>&1

# * doesn't work in dd command
file=$(ls *.img)
sudo dd if=$file of=/dev/sdb bs=4M status=progress 
sync
}


#Detect device connected
#may need to install arp-scan
#sudo arp-scan -l 


# % ssh parman@192.168.0.159
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
# Someone could be eavesdropping on you right now (man-in-the-middle attack)!
# It is also possible that a host key has just been changed.
# The fingerprint for the ECDSA key sent by the remote host is
# SHA256:x7waumHQska9XfttVKEfuDW9xgNObUWEcY2edlMEbSY.
# Please contact your system administrator.
# Add correct host key in /Users/ArmanK/.ssh/known_hosts to get rid of this message.
# Offending ECDSA key in /Users/ArmanK/.ssh/known_hosts:1
# ECDSA host key for 192.168.0.159 has changed and you have requested strict checking.
# Host key verification failed.

# can search $HOME/.ssh/known_hosts for IP address and delete that line

function set_keyboard {
sudo chroot /mnt/raspi /bin/bash -c 'raspi-config nonint do_configure_keyboard us'
}
function set_timezone {
sudo chroot /mnt/raspi /bin/bash -c 'raspi-config nonint do_change_timezone Etc/UTC'
}
function set_wifi_country {
sudo chroot /mnt/raspi /bin/bash -c 'raspi-config nonint do_wifi_country US'
}
function set_locale {
sudo chroot /mnt/raspi /bin/bash -c 'raspi-config nonint do_change_locale en_US.UTF-8'
}
function clear_known_hosts {
sed -i '/parmanodl/d' $HOME/.ssh/known_hosts
}

function part2 {

# put microSD in pi
# wait
# ssh parmanodl.local --> set locale#
# creat script on desktop
true

}