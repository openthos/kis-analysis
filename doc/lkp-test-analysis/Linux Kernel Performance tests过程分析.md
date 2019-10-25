### Linux Kernel Performance tests

LKP的执行的命令路径在：`bin,sbin,tools,lkp-exec`
<br>
* 安装通用的以及指定JOB所需的包
```
  lkp-exec/install
  lkp-exec/install JOB  #为分割后的JOB安装依赖包
```
<br>
  检测Linux发行版类型，根据distro/installer/$distro，安装该操作系统通用的依赖包和ruby的相关bundle包；<br>
  然后创建好相关的LKP目录和testbox configuration文件，包括识别计算出的CPU、内存、硬盘分区等配置信息，这些信息在接下来的JOB处理时会用到。<br>
  还有一步重要的是makepkg，创建JOB运行包，包括下载，编译，打包：
  ```
  install_packages "$pkg" "$distro"
  makepkg_install_packages "$pkg" "$distro"
  build_install_benchmarks "$script" $distro $install_opt
  ```

* 分割JOB
  `sbin/split-job JOB`
  <br>
  这部分代码使用ruby语言编写，主要是解析yaml格式的文件；<br>
  根据yaml文件中的性能测试指标，分别对各项进行组合后分割；<br>
  如果在hosts/hostname-xxx文件中定义了磁盘分区信息，在分割JOB时也将自动识别并添加该host的磁盘分区信息；

* 编译JOB成shell脚本
  `sbin/job2sh(compile)  JOB`
  <br>
  导入ruby库lib/job2sh.rb，把分割好的JOB文件，解析后生成对于内容的shell脚本；<br>
  .sh脚本内容包括：export_top_env()环境变量定义，run_job()运行命令，extract_stats()解析系统状态数据。<br>
  生成的.sh脚本会在模拟器QEMU运行时使用到，这些变量信息有很多在使用开源部分LKP无法自动生成的，需要我们后续的代码完善。<br>
  以下为WFG提供的一个生成的完整的可运行可shell文件：
```
export_top_env()
{
	export LKP_SERVER='inn'
	export LKP_CGI_PORT=80
	export testcase='ebizzy'
...
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/scheduled/lkp-nex04/unit_ebizzy-performance-200%-100x-10s-x86_64-rhel-BASE-c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b-20150830-10493-9a909m-0.yaml
...
commit=c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b
BOOT_IMAGE=/pkg/linux/x86_64-rhel/gcc-4.9/c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b/vmlinuz-4.2.0-rc8
max_uptime=3319
RESULT_ROOT=/result/ebizzy/performance-200%-100x-10s/lkp-nex04/debian-x86_64-2015-02-07.cgz/x86_64-rhel/gcc-4.9/c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b/0
...
rw'
	export modules_initrd='/pkg/linux/x86_64-rhel/gcc-4.9/c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b/modules.cgz'
	export bm_initrd='/osimage/deps/debian-x86_64-2015-02-07.cgz/lkp.cgz,/osimage/deps/debian-x86_64-2015-02-07.cgz/run-ipconfig.cgz,/osimage/deps/debian-x86_64-2015-02-07.cgz/turbostat.cgz,/lkp/benchmarks/turbostat.cgz,/lkp/benchmarks/ebizzy-x86_64.cgz'
	
	[ -n "$LKP_SRC" ] ||
	export LKP_SRC=/lkp/${user:-lkp}/src
}

run_job()
{
	echo $$ > $TMP/run-job.pid

	. $LKP_SRC/lib/job.sh
	. $LKP_SRC/lib/env.sh
	
	export_top_env
	
	default_monitors()
	{
		run_monitor $LKP_SRC/monitors/event/wait 'activate-monitor'
		run_monitor $LKP_SRC/monitors/wrapper kmsg
		run_monitor $LKP_SRC/monitors/wrapper uptime
	...
	}
}
extract_stats()
{
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper uptime
	$LKP_SRC/stats/wrapper iostat
...
}
"$@"
```

* 本机运行JOB
```
  bin/run-local.sh JOB
  bin/run-local JOB
```
<br>
调用bin/post-run，包括处理进程运行状态、pipe处理、timeout处理等功能，还有标准输出和标准错误的采集，运行结果的采集；<br>
最后运行完成后，会调用lib/upload.sh，通过copy、rsync、lftp、curl等方式upload到$LKP_SERVER服务器的$JOB_RESULT_ROOT。<br>

* 模拟器QEMU上运行JOB
  `lkp-exec/qemu JOB`
  <br>
调用shell脚本，创建job_initrd.cgz包，是把JOB解析下载编译后的所有需要文件通过cpio和gzip打包；然后创建虚拟机的结果搜集目录；<br>
定义好LKP_SERVER和HTTP_PREFIX，将用于QEMU运行kernel和rootfs的下载；<br>
定义好kernel启动参数，调用qemu-system-x86_64启动虚拟机。<br>
以下为运行案例：
```
qemu-system-x86_64 -enable-kvm -fsdev local,id=test_dev,path=/result/ebizzy/200%-4x-10s/chy-KVM/debian-x86_64.cgz/x86_64-rhel/gcc-4.9/c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b/5,security_model=none -device virtio-9p-pci,fsdev=test_dev,mount_tag=9p/virtfs_mount -kernel ./kernel-android -initrd ./initrd-android.img -append "initrd=/initrd.img root=/dev/ram0 androidboot.hardware=android_x86_64 text SRC= DATA= BOOT_IMAGE=/kernel user=lkp job=/lkp/scheduled/kvm/ebizzy.yaml ARCH=x86_64 kconfig=x86_64-rhel branch=master commit=c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b max_uptime=3300 RESULT_ROOT=/result/ebizzy/200%-4x-10s/chy-KVM/debian-x86_64.cgz/x86_64-rhel/gcc-4.9/c13dcf9f2d6f5f06ef1bf79ec456df614c5e058b/5 LKP_SERVER=192.168.0.119 earlyprintk=ttyS0,115200 systemd.log_level=err debug apic=debug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=100 panic=-1 softlockup_panic=1 nmi_watchdog=panic oops=panic load_ramdisk=2 prompt_ramdisk=0 console=ttyS0,115200 vga=normal rw ip=dhcp result_service=9p/virtfs_mount" -smp 2 -m 2048M -no-reboot -watchdog i6300esb -rtc base=localtime -device e1000,netdev=net0 -netdev user,id=net0 -serial stdio -drive file=/tmp/vdisk-root/disk0-chy-KVM,media=disk,if=virtio -drive file=/tmp/vdisk-root/disk1-chy-KVM,media=disk,if=virtio -drive file=/tmp/vdisk-root/disk2-chy-KVM,media=disk,if=virtio -drive file=/tmp/vdisk-root/disk3-chy-KVM,media=disk,if=virtio -drive file=/tmp/vdisk-root/disk4-chy-KVM,media=disk,if=virtio -drive file=/tmp/vdisk-root/disk5-chy-KVM,media=disk,if=virtio ...
```

* 显示测试结果数据
  `lkp-exec/result PATTERNs`
<br>
