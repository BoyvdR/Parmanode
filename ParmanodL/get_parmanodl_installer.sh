# This file is to be kept at parmanode.com
# User to type: 
#        /bin/bash -c "$(curl -fsSL https://parmanode.com/get_parmanodl_installer)" 


########################################################################################
#!/bin/bash
printf '\033[8;38;88t' && echo -e "\033[38;2;255;145;0m" 

cd $HOME/Desktop
curl -LO https://parmanode.com/ParmanodL_Installer.sh
sudo chmod +x install_ParmanodL.sh

clear ; echo "

    There should be a file on your desktop now called ParmanodL_Installer.sh.

    Double click it to run.

    "
sleep 3.5 
########################################################################################