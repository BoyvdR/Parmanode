function ParmanodL_docker_run {
if [[ $(uname) == Linux ]] ; then return 0 ; fi
# Remove old ParmanodL containers in case of repeated installation

    if docker ps -a | grep -q ParmanodL ; then docker stop ParmanodL >/dev/null 2>&1 ; docker rm ParmanodL >/dev/null 2>&1 ; fi

# Start a Linux docker container as a daemon process

if [[ $1 == umbrelmac ]] ; then
    docker run --privileged -d --device $disk:$disk -v $HOME/parman_programs:/volume --name umbrel arm64v8/debian tail -f /dev/null >/dev/null 2>&1 || \
        { announce "Couldn't start Docker container. Aborting." ; return 1 ; }
else
    docker run  --privileged -d -v $HOME/ParmanodL:/mnt/ParmanodL --name ParmanodL arm64v8/debian tail -f /dev/null >/dev/null 2>&1 || \
        { announce "Couldn't start Docker container. Aborting." ; return 1 ; }
fi

}

function ParmanodL_docker_get_binaries {
if [[ $uname == Linux ]] ; then return 0 ; fi

# Get necessary binaries inside the container

    docker exec ParmanodL /bin/bash -c 'apt-get update -y && apt-get install fdisk -y' || \
        { announce "Couldn't execute updates in Docker container. Aborting." ; return 1 ; }

}
