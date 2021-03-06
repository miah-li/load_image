uname=$1
token=$2
id=$3

function load_image_ubuntu() {      
	curl -L -v \
		-H "Accept: application/vnd.github.v3+json" \
		-u $uname:$token  \
		-o $name.zip \
 		https://api.github.com/repos/khadas/fenix/actions/artifacts/$id/zip
 }

function get_id(){
	artifacts=`curl \
		-H "Accept: application/vnd.github.v3+json" \
		-u $uname:$token  \
		https://api.github.com/repos/khadas/fenix/actions/artifacts `
	a=`echo $artifacts | jq '.artifacts'`
	echo $a | jq ' .[] | { id , name } ' > jason1.txt
	a_id=`cat jason1.txt | awk -F"," '{ print $1 }' | sed -n '2p' `			
	id=`echo $a_id | sed 's/ /\n/g' | sed -n '2p' `							
	echo $id
}

function get_name(){
	curl \
		-H "Accept: application/vnd.github.v3+json" \
		-u $uname:$token  \
		https://api.github.com/repos/khadas/fenix/actions/artifacts/$id > jason2.txt
	name=` cat jason2.txt | jq .name | sed 's/\"//g' `
	echo $name
}

if [ -n "$uname" ] && [ -n "$token" ]; then
	while [ -n "$id" ]
	do
		curl \
			-H "Accept: application/vnd.github.v3+json" \
			-u $uname:$token  \
			https://api.github.com/repos/khadas/fenix/actions/artifacts/$id > jason.txt
		id=` cat jason.txt | jq .id `
		name=` cat jason.txt | jq .name | sed 's/\"//g' `	 
		echo $id
		echo $name
		load_image_ubuntu
	done

	while [ ! -n "$id" ]
	do
		get_id
		for(( i=1; i<=50 ; i++ ))
		do
			get_name
			if [ "$name" != "null" ]; then
				load_image_ubuntu
				id=$((id-1))
				echo $id
			else
				break
			fi
		done
		break
	done
else
	echo "I don't understand!"
fi

