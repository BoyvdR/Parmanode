function menu_mempool {
while true ; do 
if docker ps 2>/dev/null | grep -q mempool_web ; then
running="                           MEMPOOL IS$green    Running$orange"
else
running="                           MEMPOOL IS$red    Not Running$orange"
fi
unset ONION_ADDR_MEM tor_mempool tor_mempool_status
if [[ -e /var/lib/tor/mempool-service ]] ; then
get_onion_address_variable mempool
tor_mempool_status="${green}enabled$orange"
tor_mempool=true
get_onion_address_variable "fulcrum" >/dev/null
else
tor_mempool=false
tor_mempool_status="${red}disabled$orange"
fi
#get backend variable
if grep "MEMPOOL_BACKEND" < $hp/mempool/docker/docker-compose.yml | grep -q "none" ; then
backend="${yellow}Bitcoin Core$orange"
elif grep "MEMPOOL_BACKEND" < $hp/mempool/docker/docker-compose.yml | grep -q "electrum" ; then
backend="${bright_blue}An Electrum or Fulcrum Server$orange"
fi
debug "after if backend"

set_terminal_custom 45 ; echo -e "
########################################################################################$cyan
                                    Mempool Menu            $orange                   
########################################################################################


                        MEMPOOL BACKEND: $backend

$running


                  s)             Start

                  stop)          Stop

                  r)             Restart

                  tor)           Enable/Disable Tor.                      $tor_mempool_status

                  bk)            Change Bitcoin Backend     

                  conf)          View/Edit config (restart if changing)


    Access Mempool:
$cyan
    http://127.0.0.1:8120
    http://$IP:8120
$orange
    Tor Access: $bright_blue    

    Onion adress: $ONION_ADDR_FULCRUM:8280 $orange           

########################################################################################
"
choose "xpmq" ; read choice ; set_terminal
case $choice in 

m|M) back2main ;;
q|Q|QUIT|Quit) exit 0 ;;
p|P) menu_use ;; 

start|S|s|Start|START)
start_mempool
;;
stop|STOP|Stop)
stop_mempool
;;

r|RESTART|restart|R)
restart_mempool
debug "restart done"
;;

tor)
if [[ $mempool_tor == false ]] ; then
swap_string "$file" "SOCKS5PROXY_ENABLED:" "SOCKS5PROXY_ENABLED: \"true\""
enable_mempool_tor
else
swap_string "$file" "SOCKS5PROXY_ENABLED:" "SOCKS5PROXY_ENABLED: \"false\""
disable_mempool_tor
fi
;;

bk)
mempool_backend
;;

conf)
nano $hp/mempool/docker/docker-compose.yml
;;

*)
invalid
;;

esac
done
}
