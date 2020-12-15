id=$1

function load_image_ubuntu() {      
	curl -L -v \
		-H "Accept: application/vnd.github.v3+json" \
		-u miah-li:cd36e32be5004cb216baa1c8b4accf890ce82a14 \
		-o $name.zip \
 		https://api.github.com/repos/khadas/fenix/actions/artifacts/$id/zip
 }

function get_id(){
artifacts=`curl \
			-H "Accept: application/vnd.github.v3+json" \
        	-u miah-li:cd36e32be5004cb216baa1c8b4accf890ce82a14 \
        	https://api.github.com/repos/khadas/fenix/actions/artifacts `
a=`echo $artifacts | jq '.artifacts'`
echo $a | jq ' .[] | { id , name } ' > jason1.txt
a_id=`cat jason1.txt | awk -F"," '{ print $1 }' | sed -n '2p' `			# "id": 30587001

id=`echo $a_id | sed 's/ /\n/g' | sed -n '2p' `							# 30587001
echo $id

}

function get_name(){
curl \
	 -H "Accept: application/vnd.github.v3+json" \
     -u miah-li:cd36e32be5004cb216baa1c8b4accf890ce82a14 \
     https://api.github.com/repos/khadas/fenix/actions/artifacts/$id > jason2.txt
name=` cat jason2.txt | jq .name | sed 's/\"//g' `
echo $name

}


while [ -n "$id" ]
do

curl \
	 -H "Accept: application/vnd.github.v3+json" \
     -u miah-li:cd36e32be5004cb216baa1c8b4accf890ce82a14 \
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
	for(( i=1; i<=5 ; i++ ))
	do

		get_name

		load_image_ubuntu
		id=$((id-1))
		echo $id
		if [ "$name" == "null" ]; then
			break
		fi
	done
	break
done
