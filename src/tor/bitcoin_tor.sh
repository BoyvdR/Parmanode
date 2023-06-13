function bitcoin_tor {

if [[ $OS == "Mac" ]] ; then no_mac ; return 1 ; fi

if ! which tor >/dev/null 2>&1 ; then install_tor ; fi

if [[ ! -f /etc/tor/torrc ]] ; then
set_terminal ; echo "
########################################################################################
    /etc/tor/torrc file does not exist. You may have a non-standard Tor installation.
    Parmanode won't be able to automate this process for you. Aborting.
########################################################################################
"
enter_continue ; return 1 ;
fi

usermod -a -G tor $USER 

if sudo grep -q "ControlPort 9051" /etc/tor/torrc | grep -v '^#' ; then true ; else
    echo "ControlPort 9051" | sudo tee -a /etc/tor/torrc >/dev/null 2>&1
    fi

if sudo grep -q "CookieAuthentication 1" /etc/tor/torrc | grep -v '^#' ; then true ; else
    echo "CookieAuthentication 1" | sudo tee -a /etc/tor/torrc >/dev/null 2>&1
    fi

if sudo grep -q "CookieAuthFileGroupReadable 1" /etc/tor/torrc | grep -v '^#' ; then true ; else
    echo "CookieAuthFileGroupReadable 1" | sudo tee -a /etc/tor/torrc >/dev/null 2>&1
    fi

if sudo grep -q "DataDirectoryGroupReadable 1" /etc/tor/torrc | grep -v '^#' ; then true ; else
    echo "DataDirectoryGroupReadable 1" | sudo tee -a /etc/tor/torrc >/dev/null 2>&1
    fi
if ! grep -q "listen=1" /$HOME/.bitcoin/bitcoin.conf ; then
    echo "listen=1" | tee -a $HOME/.bitcoin/bitcoin.conf
    fi

if sudo grep -q "HiddenServiceDir /var/lib/tor/bitcoin-service/" \
    /etc/tor/torrc | grep -v "^#" ; then true ; else
    echo "HiddenServiceDir /var/lib/tor/bitcoin-service/" | sudo tee -a /etc/tor/torrc >/dev/null 2>&1
    fi

if sudo grep -q "HiddenServicePort 8333 127.0.0.1:8333" \
    /etc/tor/torrc | grep -v "^#" ; then true ; else
    echo "HiddenServicePort 8333 127.0.0.1:8333" | sudo tee -a /etc/tor/torrc >/dev/null 2>&1
    fi

#Bitcoind stopping - remember to start it up inside this function later

    sudo systemctl restart tor
    sudo systemctl stop bitcoind.service

get_onion_address_variable

if [[ $1 == "torandclearnet" ]] ; then
    delete_line "$HOME/.bitcoin/bitcoin.conf" "onion="
    echo "onion=127.0.0.1:9050" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    delete_line "$HOME/.bitcoin/bitcoin.conf" "externalip="
    echo "externalip=$ONION_ADDR" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    delete_line "$HOME/.bitcoin/bitcoin.conf" "discover="
    echo "discover=1" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    fi

if [[ $1 == "toronly" ]] ; then
    delete_line "$HOME/.bitcoin/bitcoin.conf" "onion="
    echo "onion=127.0.0.1:9050" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    delete_line "$HOME/.bitcoin/bitcoin.conf" "externalip="
    echo "externalip=$ONION_ADDR" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    delete_line "$HOME/.bitcoin/bitcoin.conf" "bind="
    echo "bind=127.0.0.1" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    fi

if [[ $2 == "onlyout" ]] ; then
    delete_line "$HOME/.bitcoin/bitcoin.conf" "onlynet"
    echo "onlynet=onion" | tee -a $HOME/.bitcoin/bitcoin.conf >/dev/null 2>&1
    fi


    sudo systemctl start bitcoind.service

}