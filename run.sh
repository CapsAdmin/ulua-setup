#!/bin/bash

ROOT_DIR=${BASH_SOURCE[0]}

remove() {
	path=$1

	if [ -d "$path" ]; then
		printf "removing directory: '$ROOT_DIR\$path' ... "
		rm -rf "$path"
		echo "OK"
	elif [ -f "$path" ]; then
		printf "removing file: '$ROOT_DIR\$path' ... "
		rm -rf "$path"
		echo "OK"
	else
		echo "could not find: $path"
	fi
}

download() {
	url=$1
	location=$2

	if ! [ -d "$location" ]; then
		printf "'$url' >> '$ROOT_DIR\$location' ... "
		wget "$url" -O "$location"
		echo "OK"
	else
		echo "'$ROOT_DIR\$location' already exists"
	fi
}

extract() {
	file=$1
	location=$2

	printf "$file >> '$location' ... "
	unzip "$file" -d "$location"
	mv -f $location/*/* "$location/" #hmmm
	echo "OK"
}

setup()
{
	url=$1
	dir=$2

	download $url temp.zip
	eemove $dir
	extract temp.zip $dir
	remove temp.zip
}
if ! [ -f "ulua/lua" ]; then
	setup http://ulua.io/download/ulua~latest.zip ulua
fi

./ulua/lua main.lua