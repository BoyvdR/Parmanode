# searches for a string, then delete that line for all occurrances of the string.
# arguments should use full paths to file.

function delete_line {

if ! cat $HOME/.parmanode/parmanode.conf | grep -q parmanode-end ; then 

	search_string="$2"

		if [[ $OS == "Linux" ]] 
		then
                input_file="$(readlink -f "$1")"
		sudo sed -i "/${search_string}/d" "$input_file" 
		fi


		if [[ $OS == "Mac" ]]
		then
                input_file="$(greadlink -f "$1")"
		sudo sed -i "" "/${search_string}/d" "$input_file" 
		fi		
fi

}

