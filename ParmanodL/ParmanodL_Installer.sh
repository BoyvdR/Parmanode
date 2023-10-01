#!/bin/bash

# Debug toggle

    if [[ $1 == d ]] ; then export debug=1 ; else export debug=0; fi

# Version specific info
    
    export zip="2023-05-03-raspios-bullseye-arm64.img.xz"
    export image_file="2023-05-03-raspios-bullseye-arm64.img"
        export image_path="$HOME/ParmanodL/$image_file" 
        export image=$image_path
    export hash="e7c0c89db32d457298fbe93195e9d11e3e6b4eb9e0683a7beb1598ea39a0a7aa"

# size 88 wide, and orange colour scheme

    printf '\033[8;38;88t' && echo -e "\033[38;2;255;145;0m" 
    clear ; echo "
########################################################################################

                       P  A  R  M  A  N  O  D  L     O  S 

    You are installing ParmanodL OS onto a microSD card, for use in a Raspberry Pi 4.

    The target microSD can be as small as 16GB.

    The entire process may take about 30 minutes. 

    For best probability of success, do not do too many other things with the computer
    as you build this.

    Hit <enter> to continue

########################################################################################
    " ; read

# Detect the OS

    if [[ $(uname) == Linux ]] ; then export OS=Linux ; fi
    if [[ $(uname) == Darwin ]] ; then export OS=Mac ; fi

# Detect the Machine

    if [[ $OS == Mac ]] ; then export machine=Mac ; fi
    if sudo cat /proc/cpuinfo | grep "Raspberry Pi" ; then export machine=Pi ; fi
    if [[ $machine != Mac && $machine != Pi ]] ; then export macine=other ; fi

# Detect the chip

    export chip=$(uname -m)

#need to get part 1 dependencies

    if [[ $OS = Mac ]] ; then 

        if ! which brew ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
        if ! which brew ; then export warning=1 ; fi
        fi

        if ! greadlink ; then
            if [[ $warning == 1 ]] ; then echo "problem with homebrew, needed to install coreutils/greadlink. Aborting." ; sleep 4 ; exit ; fi
            brew install coreutils
        fi

        if ! which git ; then
            if [[ $warning == 1 ]] ; then echo "problem with homebrew, needed to install git. Aborting." ; sleep 4 ; exit ; fi
            brew install git
        fi

        if ! which ssh ; then 
            if [[ $warning == 1 ]] ; then echo "problem with homebrew, needed to install git. Aborting." ; sleep 4 ; exit ; fi
            brew instal ssh ; fi
        fi
    
    fi

    if [[ $OS == Linux ]] ; then
        
        sudo apt-get update -y
        if ! which vim ; sudo apt-get install vim -y ; fi
        if ! which git ; sudo apt-get install git -y ; fi
        if ! which ssh ; sudo apt-get install ssh -y ; fi

    fi


# Get Parmanode or update

   if [ ! -e ~/parman_programs/parmanode/src ] ; then
        mkdir -p ~/parman_programs
        cd ~/parman_programs
        git clone --depth 1 https://github.com/armantheparman/parmanode.git || \
          { announce "Unable to get parmanode scripts with git. Aborting." ; exit 1 ; }
    else
        cd $HOME/parman_programs/parmanode/
        git pull
    fi

# Source Parmanode & ParmanodL scripts to get needed functions

    for file in ~/parman_programs/parmanode/src/**/*.sh ; do 
		if [[ $file != *"/postgres_script.sh" ]]; then
	    source $file 
        fi 
	done

    for file in ~/parman_programs/parmanode/ParmanodL/src/*.sh ; do source $file ; done

# Now that parmanode scripts have been sources, the code from here on can be tidier, 
# as parmanode functions are available.

# Part 2 dependencies - Macs need Docker

    Macs_need_docker || exit

# Make necessary directories

    ParmanodL_directories 

# Get PiOS, verify, and extract

    get_PiOS || exit

# Macs need docker functionality here

    ParmanodL_docker_run || exit
    ParmanodL_docker_get_binaries || exit

# Mount the image and dependent directories

    ParmanodL_mount || exit

# Setup system locale

    set_locale

# Modify the image with chroot

    ParmanodL_chroot 

# Debug - opportunity to pause and check

    debug "Chroot finished. Pause to check."

# Unmount the image and system directories

    ParmanodL_unmount

# Get microSD device name into disk variable - user input here

    detect_microSD || exit

# Write the image to microSD

    ParmanodL_write || exit

# Clean known hosts of parmanodl
 
    clean_known_hosts

# make run_parmanodl for desktop execution

    make_run_parmanodl

# Success output

    ParmanodL_success

# The End
