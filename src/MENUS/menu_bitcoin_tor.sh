function menu_bitcoin_tor {

if ! which tor >/dev/null 2>&1 ; then set_terminal
echo "
    You need to install Tor first. Aborting.
    "
enter_continue
fi

while true ; do

source $dp/parmanode.conf >/dev/null 2>&1 
if [[ $bitcoin_tor_status == t ]] ; then
local status_print="Tor enabled (option 2)"
elif [[ $bitcoin_tor_status == c ]] ; then
local status_print="Clearnet (option 4)"
elif [[ $bitcoin_tor_status == tc ]] ; then
local status_print="Clearnet & Tor (option 1)"
elif [[ $bitcoin_tor_status == tonlyout ]] ; then
local status_print="Strict Tor, only out (option 3)"
fi

set_terminal ; echo -e "
########################################################################################

$cyan                        Tor options for Bitcoin (Linux only)   $orange


    Option to change Bitcoin Tor Settings. LND may stop running and require some
    thinking time (minutes) before you can succesfully manually restart it.


    1)    Allow Tor connections AND clearnet connections
                 - Helps you and the network overall

    2)    Force Tor only connections
                 - Extra private but only helps the Tor network of nodes
    
    3)    Force Tor only OUTWARD connections
                 - Only helps yourself but most private of all options
                 - You can connect to tor nodes, they can't connect to you

    4)    Make Bitcoin public (Remove Tor usage and stick to clearnet)
                 - Generally faster and more reliable


$bright_magenta    Current Status: $status_print$orange"

if sudo [ -f /var/lib/tor/bitcoin-service/hostname ] ; then 
get_onion_address_variable bitcoin >/dev/null ; echo -e "
$bright_blue    Onion adress: $ONION_ADDR
$orange
########################################################################################
"
else echo "########################################################################################
"
fi

choose "xpmq" ; read choice
case $choice in 
m|M) back2main ;;
Q|q|quit|QUIT|Quit) exit 0 ;;
p|P) return 1 ;;
"1")
    bitcoin_tor "torandclearnet" 
    check_bitcoin_tor_status #sets status in parmanode.conf
    break ;; 
"2")
    bitcoin_tor "toronly" 
    check_bitcoin_tor_status
    break ;;
"3")
    bitcoin_tor "toronly" "onlyout" 
    check_bitcoin_tor_status
    break ;;
"4")
    bitcoin_tor_remove 
    check_bitcoin_tor_status
    break ;;
*)
    invalid ;;
esac

done
}

