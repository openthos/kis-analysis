# 暂存肖洛元学长对于项目源码的修改  
# https://Lyuann@bitbucket.org/Lyuann/lkp.git #

# diff --git a/jobs/kernel_selftests.yaml b/jobs/kernel_selftests.yaml #
index 1a3caad..9e329fc 100644
--- a/jobs/kernel_selftests.yaml
+++ b/jobs/kernel_selftests.yaml
@@ -2,3 +2,4 @@ testcase: kernel_selftests
 category: functional
 
 kernel_selftests:
+job_state=wget_kernel

# diff --git a/lib/kexec.sh b/lib/kexec.sh #
index 8017f33..1bf1701 100755
--- a/lib/kexec.sh
+++ b/lib/kexec.sh
@@ -21,10 +21,12 @@ download_kernel_initrd()
 
        kernel=$(echo $kernel | sed 's/^\///')
 
-       echo "downloading kernel image ..."
+       #echo "downloading kernel image ..."
+       echo "downloading kernel image: $kernel "
        set_job_state "wget_kernel"
        kernel_file=$CACHE_DIR/$kernel
-       wget "http://$LKP_SERVER:$LKP_CGI_PORT/~$LKP_USER/$kernel" -nv -N -P $(dirname $kernel_file) || {
+       #wget "http://$LKP_SERVER:$LKP_CGI_PORT/~$LKP_USER/$kernel" -nv -N -P $(dirname $kernel_file) || {
+       wget "$LKP_SERVER/linux/$kernel" -nv -N -P $(dirname $kernel_file) || {
                echo "failed to download kernel: $kernel" 1>&2
                exit 1
        }
@@ -42,15 +44,20 @@ download_kernel_initrd()
                initrds="${initrds}$file "
        done
 
-       [ -n "$initrds" ] && {
+#      [ -n "$initrds" ] && {
                concatenate_initrd="/tmp/initrd-$$"
                if [ $# = 0 ]; then
+               echo "Args == 0"
                        cat $initrds > $concatenate_initrd
                else
+               echo "Args != 0"
                        cat $initrds $* > $concatenate_initrd
                fi
                initrd_option="--initrd=$concatenate_initrd"
-       }
+#      }
+
+       echo "initrds option: $concatenate_initrd"
+
        return 0
 }
 
 
# diff --git a/lkp-exec/install b/lkp-exec/install #
index 8ebef83..7f883bd 100755
--- a/lkp-exec/install
+++ b/lkp-exec/install
@@ -170,6 +170,7 @@ do
                echo "$0: skip unknown parameter $filename" >&2
        fi
 
+       echo "##### $scripts #####";exit 1
        for script in $scripts
        do
                [ -z "$makepkg_once" ] && [ -d "$LKP_SRC/pkg/$script" ] && ! [ -x "$LKP_SRC/pack/$script" ] && {

# diff --git a/lkp-exec/qemu b/lkp-exec/qemu #
index 4a96f80..3d09d9d 100755
--- a/lkp-exec/qemu
+++ b/lkp-exec/qemu
@@ -129,6 +129,8 @@ job_script=$1
 export_top_env
 replace_script_partition_val $job_script
 
+#echo "##### user: $user #####";exit 1
+
 # create lkp-$arch.cgz
 export LKP_USER=$user
 if [[ "$kconfig" =~ ^(i386|x86_64)- ]]; then
@@ -162,7 +164,8 @@ fi
 mkdir -p $vm_result_path
 
 # download kernel and initrds, then cat them
-LKP_SERVER=bee.sh.intel.com
+#LKP_SERVER=bee.sh.intel.com
+LKP_SERVER=ftp://os:o@192.168.0.150
 CACHE_DIR=/tmp/lkp-qemu-downloads
 [ -d $CACHE_DIR ] || mkdir $CACHE_DIR
 LKP_USER="lkp"
@@ -171,9 +174,13 @@ run_kvm()
 {
        trap - EXIT
 
-       local mem_mb="$(max_sane_qemu_memory $memory)"
+       #local mem_mb="$(max_sane_qemu_memory $memory)"
+       local mem_mb="1024"
        local mount_tag=9p/virtfs_mount
-       model='qemu-system-x86_64 -enable-kvm'
+       #model='qemu-system-x86_64 -enable-kvm'
+       model='qemu-system-x86_64 -nographic '
+       nr_cpu=2
+
        netdev_option="-device e1000,netdev=net0 "
        netdev_option+="-netdev user,id=net0"
        KVM_COMMAND=(

# diff --git a/pack/lkp-src b/pack/lkp-src #
index 8830db6..7ff017b 100755
--- a/pack/lkp-src
+++ b/pack/lkp-src
@@ -38,6 +38,10 @@ pack()
                cd $tmp_dir                                     && find lkp/$LKP_USER/src/*     | $cpio_cmd --append
                {
                        cd $tmp_dir/lkp/$LKP_USER/src/rootfs/addon
+                       mkdir -p etc/ssh/
+                       touch etc/ssh/ssh_config
+                       mkdir -p root
+                       touch root/.ssh
                        chmod -R 600 etc/ssh/* # to avoid sshd Permissions too open error
                        chmod g-ws root
                        chmod -R go-rwxs root/.ssh
