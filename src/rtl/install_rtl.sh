function install_rtl {

install_check "rtl" 
        if [ $? == 1 ] ; then return 1 ; fi

#if working on installing on host...
#	install_nodejs 
#download_rtl
#	verify_rtl || return 1
#	extract_rtl
#install_rtl
#fi

mkdir $HOME/parmanode/rtl $HOME/parmanode/rtl_db
installed_config_add "rtl-start"
make_rtl_config

docker build -t rtl ./src/rtl || { debug1 "failed to build rtl image" && return 1 ; }
docker run -d --name rtl -p 3000:3000 \
                         -v $HOME/parmanode/rtl:/home/parman/RTL \
                         -v $HOME/parmanode/rtl_db:/home/parman/rtl_db \
			 -v $HOME/.lnd:/home/parman/.lnd \
                         -v $HOME/.parmanode/:/home/parman/.parmanode \
                         rtl \
        || { debug1 "failed to run rtl image" && return 1 ; }

mv $original_dir/src/rtl/RTL-Config.json $HOME/parmanode/rtl
rtl_password_changer

run_rtl

success "RTL" "being installed."
installed_config_add "rtl-end"

}
