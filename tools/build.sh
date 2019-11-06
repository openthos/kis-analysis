#!/bin/bash

branch_name="$1"
commit_id="$2"

function init_env() {
	dirname_path=$(cd `dirname $0`; pwd)
	tmp_branch="$dirname_path/tmp_branch"

	source $tmp_branch/envar
	buildroot_linux=$linux_repo
}

function init_git(){
	cd $buildroot_linux

	git checkout $branch_name
	git checkout $commit_id

	if [ $? -ne 0 ]; then
		echo -e "git checkout $commit_id ERROR!"
		exit
	fi

}

function init_kernel_config(){
	cp $buildroot_linux/arch/x86/configs/x86_64_defconfig  $buildroot_linux/.config
}

function build_kernel(){
	make x86_64_defconfig
	make

	if [ $? -ne 0 ]; then
		echo -e "make ERROR!"
		exit
	fi
}

function output_log(){
	echo -e "$sec $branch_name $commit_id --> (${!file_time[@]})" >> $tmp_branch/build.log
	echo -e "$branch_name \033[32m$commit_id\033[0m output files: (\033[32m${!file_time[@]} \033[0m) in $image_path"
}

function images_commit(){
	cd $buildroot_linux/arch/x86_64/boot/
	declare -A file_time
	sec=$(date +%s)
	for file_ in $(ls)
	do
		time_=$(stat -c %Y $file_)
		if [ $time_ -gt $sec ]; then
			file_time[$file_]=$time_

			if [ "$file_"x == "bzImage"x ]; then
				rm  $tmp_branch/$commit_id
			fi
		fi
	done
	image_path=$dirname_path/buildroot/output/images
	if [ ! -d $image_path ]
	then
		mkdir -p $image_path
	fi
	cp bzImage $image_path
	output_log
}


function test_image() {
	echo $dirname_path
	cd $dirname_path
	./test.sh   $image_path/bzImage   rootfs.ext2
}

init_env
init_git
init_kernel_config
build_kernel
images_commit
test_image
