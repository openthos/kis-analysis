#!/bin/bash

dirname_path=$(cd `dirname $0`; pwd)

#build_sh="$dirname_path/build.sh"
test_sh="$dirname_path/test.sh"
tmp_branch="$dirname_path/tmp_branch"

# for linux_repo NEED TO SET #linux_repo="/home/oto/thecode/cki/linux/"
source $tmp_branch/envar

cd $linux_repo
# TBD: need get origin and master  from git remote -v
git fetch origin master

if [ $? -ne 0 ]; then
   echo -e "git fetch ERROR!"
   exit
fi  

#remote_branches=$(git branch -r | sed -e  "s/origin\///")

echo "All branches: ($remote_branches)"

remote_branches="origin/master" #remote_branches="origin/master origin/HEAD"
echo $remote_branches

for br_ in $remote_branches
do 

echo $br_
nbr_=${br_/\//##}
echo $nbr_

#old_br_com : old_branch_commit id
old_br_com=(`cat $tmp_branch/$nbr_`)
echo $old_br_com

git checkout $br_

#new_br_com : new_branch_commit id
new_br_com=(`git log -1 --pretty=format:"%H %cd" --date=raw`)
echo $new_br_com
if [ "${old_br_com[0]}"x = "${new_br_com[0]}"x ]
then
  echo No changes in $br_
  continue
else
  echo New changes, need testing in $br_
  #update newest old_branch_commit id
  echo ${new_br_com[@]} > $tmp_branch/$nbr_
fi

branch_log=$(git log --pretty=format:"%H" --since=${old_br_com[1]} )

echo -e "NEW info:: Branch $br_: ($branch_log)"

for log_ in $branch_log
do 
	echo '#!/bin/bash' > $tmp_branch/$log_
	#echo -e "/bin/bash $build_sh $br_ $log_" >> $tmp_branch/$log_
        echo -e "/bin/bash $test_sh $br_ $log_" >> $tmp_branch/$log_
	chmod 755 $tmp_branch/$log_
	echo -e "\033[32m Running $br_ $tmp_branch/$log_ \033[0m"
	/bin/bash $tmp_branch/$log_

	sleep 2
done

#for loop
done

