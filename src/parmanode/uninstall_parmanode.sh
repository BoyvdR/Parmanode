function uninstall_parmanode {
local file="$dp/installed.conf"
set_terminal
echo "
########################################################################################

                                Uninstall Parmanode

    This will first give you the option to remove programs installed with Parmanode 
    before removing the Parmanode installation files and configuration files. Finally,
    you'll have the option to delete the Parmanode script directory that was 
    downloaded form GitHub.

########################################################################################
"
choose "epq"
read choice
case $choice in

    q|QUIT|Q|quit)
    exit 0 ;;

    p|P)
    return 1 ;;

    esac

if grep -q "bitcoin" < $file #checks if bitcoin is installed in install config file.
then uninstall_bitcoin #confirmation inside function 
set_terminal
else 
set_terminal
fi #ends if bitcoin installed/unsinstalled

if grep -q "fulcrum" < $file 
then uninstall_fulcrum #both linux & mac, confirmations inside functions
set_terminal
fi

if grep -q "btcpTOR" < $file
then 
        #linux condition not required becuase btcpTOR for mac non-existent.
        uninstall_btcpay_tor
        set_terminal
fi

if grep -q "btcpay" < $file 
then uninstall_btcpay # confirmation inside function, linux and mac.
set_terminal
fi

if grep -q "electrum" < $file 
then
uninstall_electrum
set_terminal
fi

if grep -q "lnd" $file 
then
uninstall_lnd
set_terminal
fi


if grep -q "rtl" < $file 
then
uninstall_rtl #Confirmation inside function
set_terminal
fi

if grep -q "sparrow" < $file 
then
uninstall_sparrow
set_terminal
fi

if grep -q "tor-server" <$file 
then
uninstall_tor_server
set_terminal
fi

if grep -q "specter" <$file 
then
uninstall_specter
set_terminal
fi

if grep -q "electrs" <$file 
then
uninstall_elctrs
set_terminal
fi

if grep -q "btcrpcexplorer" < $file
then
uninstall_btcrpcexplorer
set_terminal
fi

if grep -q "parmanshell" < $file 
then
uninstall_parmanshell
set_terminal
fi

set_terminal
if [[ $debug == 0 ]] ; then 
echo "
########################################################################################

                            Parmanode will be uninstalled

########################################################################################
"
choose "epq"
exit_choice ; if [[ $? == 1 ]] ; then return 1 ; fi
unset choice
fi

#check other programs are installed in later versions.

if [[ $OS == "Linux" ]] ; then

        if [[ $EUID -eq 0 ]] ; then  #if user running as root, sudo causes command to fail.
                umount /media/$HOME/parmanode* > /dev/null 2>&1
            else
                sudo umount /media/$HOME/parmanode* > /dev/null 2>&1
            fi
    fi

    if [[ $OS == "Mac" ]] ; then

        disktultil unmount "parmanode"

        fi
#uninstall parmanode directories and config files contained within.
rm -rf $HOME/.parmanode >/dev/null 2>&1

#remove crontab entries
crontab -l | sed '/parmanode/d' | crontab - >/dev/null ; clear

#remove bashrc/zshrc additions
delete_line "$HOME/.bashrc" "Parmanode..." >/dev/null 2>&1
delete_line "$HOME/.bashrc" "function rp {" >/dev/null 2>&1
delete_line "$HOME/.zshrc" "Parmanode..." >/dev/null 2>&1
delete_line "$HOME/.zshrc" "function rp {" >/dev/null 2>&1



set_terminal ; echo "
########################################################################################

    Do you also wish to delete the Parmanode script directory, the one you downloaded
    from GitHub?

                                   y)    Yes

                                   n)    No

    If you choose yes, then this program will continue to run from computer memory, 
    but you won't be able to start it up again unless you download it again.

######################################################################################## 
"
read choice
case $choice in y|Y) 
#remove desktop icon file
rm $HOME/Desktop/run_parmanode*
rm $HOME/Desktop/parmanode.desktop
rm $HOME/.icons/PNicon*
rm -rf $original_dir ;; 
esac

set_terminal
echo "
########################################################################################

                        Parmanode has been uninstalled

########################################################################################
"
exit
}
