function make_electrum_config {

if [[ $OS == "Linux" ]] ; then
echo "{
    \"auto_connect\": false,
    \"check_updates\": false,
    \"config_version\": 3,
    \"decimal_point\": 8,
    \"is_maximized\": false,
    \"oneserver\": true,
    \"server\": \"127.0.0.1:50002:s\",
    \"show_addresses_tab\": true,
    \"show_utxo_tab\": true
}" | tee $HOME/.electrum/config >/dev/null 2>&1
    
echo "connection=\"FulcrumSSL\"" > $HOME/.parmanode/electrum.connection

fi


if [[ $OS == "Mac" ]] ; then 

    echo "connection=\"Docker_FulcrumSSL\"" > $HOME/.parmanode/electrum.connection

    if docker inspect fulcrum | grep '"IPAddress"' | grep '172.17.0.2' >/dev/null ; then
        F_IP="172.17.0.2"
        
    elif docker inspect fulcrum | grep '"IPAddress"' | grep '172.17.0.3' >/dev/null ; then
        F_IP="172.17.0.3"

    elif docker inspect fulcrum | grep '"IPAddress"' | grep '172.17.0.4' >/dev/null ; then
        F_IP="172.17.0.4"

    elif docker inspect fulcrum | grep '"IPAddress"' | grep '172.17.0.5' >/dev/null ; then
        F_IP="172.17.0.5"
    else
    F_IP="172.17.0.2"
    fi


    echo "{
        \"auto_connect\": false,
        \"check_updates\": false,
        \"config_version\": 3,
        \"decimal_point\": 8,
        \"is_maximized\": false,
        \"oneserver\": true,
        \"server\": \"${F_IP}:50002:s\",
        \"show_addresses_tab\": true,
        \"show_utxo_tab\": true
    }" | tee $HOME/.electrum/config >/dev/null 2>&1
fi

}
