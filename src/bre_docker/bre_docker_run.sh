function bre_docker_run {

if [[ $OS == Linux ]] ; then
docker run -d --name bre \
     -v $HOME/parmanode/bre:/home/parman/parmanode/bre \
     --network="host" \
     bre
fi

if [[ $OS == Mac ]] ; then
docker run -d --name bre \
     -v $HOME/parmanode/bre:/home/parman/parmanode/bre \
     -p 8332:8332 \
     -p 50001:50001 \
     bre
fi

}