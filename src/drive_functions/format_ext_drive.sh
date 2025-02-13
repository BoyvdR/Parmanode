function format_ext_drive {
if [[ $skip_formatting == true ]] ; then 
log "importdrive" "skipped formatting" ; return 0 ; fi
#quit if internal drive chosen
if [[ $1 == "Bitcoin" && $drive == "internal" ]] ; then return 0 ; fi
if [[ $1 == "Fulcrum" && $drive_fulcrum == "internal" ]] ; then return 0 ; fi
if [[ $1 == "electrs" && $drive_electrs == "internal" ]] ; then return 0 ; fi


if [[ $1 != justFormat ]] ; then

#quit if external drive set for either of the other programs that use this function
#parenteses added once for readability, but not required as && takes precedence over || ,so logic doesn't change
if [[ ( $1 == "Bitcoin" && $drive == "external" ) && ( $drive_fulcrum == "external" || $drive_electrs == "external" ) ]] ; then 
skip_formatting=true
fi
if [[ ( $1 == "Fulcrum" && $drive_fulcrum == "external" ) && ( $drive == "external" || $drive_electrs == "external" ) ]] ; then 
skip_formatting=true
fi
if [[ ( $1 == "electrs" && $drive_electrs == "external" ) && ( $drive == "external" || $drive_fulcrum == "external" ) ]] ; then 
skip_formatting=true
fi

if [[ $skip_formatting == true || $bitcoin_drive_import == true ]] ; then 
    return 0 
    else
    format_warnings || return 0 
fi

fi

#select_drive_ID || return 1 #gets $disk variable (exported)
detect_drive || return 1 #alternative (better) way to get $disk variable, and exported.

unmount   #failure here exits program. Need drive not to be mounted in order to wipe and format.

if [[ $1 != Bitcoin ]] ; then #cancelling dd for bitcoin installation. To slow and not necessary.
if [[ $1 != justFormat ]] ; then
    dd_wipe_drive  
fi
fi

if [[ $OS == "Linux" ]] ; then partition_drive ; fi   # Partition step not required for Mac



#Format the drive
if [[ $OS == "Mac" ]] ; then
        export disk_no_s=$(echo $disk | grep -oE 'disk[0-9]+' | tr -d '[:space:]') 
        set_terminal

        log "bitcoin" "eraseDisk $disk ..."

        if [[ $MacOSVersion_major -gt 10 || ($MacOSVersion_major == 10 && $MacOSVersion_minor -gt 12 ) ]] ; then 
        diskutil eraseDisk APFS "parmanode" /dev/$disk_no_s || log "bitcoin" "failed to eraseDisk"
        else
        diskutil eraseDisk exFAT "parmanode" /dev/$disk_no_s || log "bitcoin" "failed to eraseDisk"   
        fi

        set_terminal ; echo "
#######################################################################################

    If you saw no errors, then the $disk drive has been wiped, formatted, mounted, 
    and labelled as \"parmanode\".

#######################################################################################
    "
    enter_continue
    return 0
fi

if [[ $OS == "Linux" ]] ; then
        # The following function is redundant, but added in case the dd function (which
        # calls this function earlier is discarded). 
        remove_parmanode_fstab
        
        # Formats the drive and labels it "parmanode" - uses standard linux type, ext4
        sudo mkfs.ext4 -F -L "parmanode" $disk 

        #Extract the *NEW* UUID of the disk and write to config file.
        get_UUID "$disk" || return 1
        parmanode_conf_add "UUID=$UUID"
        write_to_fstab "$UUID"

        # Mounting... Make the mount directory, mount the drive, set the permissions,
        # and label drive (Last bit is redundant)
        if [[ ! -e $parmanode_drive ]] ; then sudo mkdir -p $parmanode_drive ; fi
        sudo mount $disk $parmanode_drive 
        sudo chown -R $USER:$(id -gn) $parmanode_drive 
        sudo e2label $disk parmanode

        debug "label done"
        set_terminal
        echo "
#######################################################################################

    If you saw no errors, then the new $disk drive has been prepared and is 
    labelled as \"parmanode\".
    
    The drive's UUID, for reference only, is $UUID.

########################################################################################
        "
        enter_continue
fi
return 0
}
