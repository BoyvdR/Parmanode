function detect_microSD {
preparation 

clear ; echo "
########################################################################################

    Please pay careful attention here, otherwise you could get errors.

########################################################################################
"
echo "Hit <enter> to continue" ; read ; clear

while true ; do
clear ; echo "
########################################################################################

    Please make sure the microSD card you wish to use is DISCONNECTED. 
    
    Hit <enter> only once this is done.

########################################################################################
"
read

if [[ $OS == "Linux" ]] ; then 
    sudo blkid -g >/dev/null
    sudo blkid > $HOME/.parmanode/before
    fi

if [[ $OS == "Mac" ]] ; then
    diskutil list > $HOME/.parmanode/before
    fi

set_terminal ; echo -e "
########################################################################################

    Now go ahead and connect the microSD card you wish to use. Do not connect any 
    other drive. If a window pops up, a file explorer, you can safely close that.

    Hit <enter> once this is done.

########################################################################################
"
read
clear
sleep 2.5

if [[ $OS == "Linux" ]] ; then
    sudo blkid -g >/dev/null
    sudo blkid > $HOME/.parmanode/after
    fi

if [[ $OS == "Mac" ]] ; then
    diskutil list > $HOME/.parmanode/after
    fi

disk_after=$(cat $HOME/.parmanode/after | grep . $HOME/.parmanode/after | tail -n1 ) 
# grep . filters out empty lines
disk_before=$(cat $HOME/.parmanode/before | grep . $HOME/.parmanode/before | tail -n1 )

   if [[ "$disk_after" == "$disk_before" ]] ; then 
        echo "No new drive detected. Try again. Hit <enter>."
            read ; continue 
        else
            if [[ $OS == "Linux" ]] ; then
                sed -i s/://g $HOME/.parmanode/after
                export disk=$(grep . $HOME/.parmanode/after | tail -n1 | awk '{print $1}')
                echo "disk=\"$disk\"" > $HOME/.parmanode/var
                debug "disk is $disk"
                return 0
                fi
            
            if [[ $OS == "Mac" ]] ; then
                Ddiff=$(($(cat $HOME/.parmanode/after | wc -l)-$(cat $HOME/.parmanode/before |wc -l))) #visualstudo code shows last ) as an error but it's not.
                export disk=$(grep . $HOME/.parmanode/after | tail -n $Ddiff | grep "dev" | awk '{print $1}')
                echo "$(cat $HOME/.parmanode/after | tail -n $Ddiff)" > $HOME/.parmanode/difference
                echo "disk=\"$disk\"" > $HOME/.parmanode/var
                debug "disk is $disk"
                return 0
                fi

            break
    fi
done
}
########################################################################################

function preperation {

if [[ ! -e $HOME/.parmanode ]] ; then mkdir $HOME/.parmanode ; fi >/dev/null 2>&1

}