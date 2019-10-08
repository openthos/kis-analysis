## 操作细节

与之前本地运行不同，为了让测试程序及一系列监视器程序能够在虚拟机（kvm）中自动运行，我们首先需要配置虚拟机启动的参数。

项目原本对于虚拟机运行的支持并不友好，本地运行过程中生成的shell脚本文件并不能用于虚拟机的直接运行，更别提直接用YAML格式的工作文件直接运行了，原因就是虚拟机运行所必须的内核镜像、文件系统镜像等#FIX#没有被指定，而这些是qemu运行的基础。

所以我们对照Intel公司提供的一个能用于虚拟机运行的Shell工作脚本，将其与普通`bin/run-local`生成的本地运行脚本进行对比，从而能修改`bin/run-local`，得到`bin/run-qemu`文件，从而能根据YAML文件生成可用于虚拟机运行的工作脚本。接下来分析具体添加了哪些部分。

在`bin/run-qemu`中，与`bin/run-local`类似，首先需要进行参数有效性检验，然后用Job类导入作为参数的YAML文件，并且设置结果存放目录及其他一些环境配置，而`bin/run-qemu`添加的主要就是环境配置部分。

1. 机器参数信息。这部分属于记录性质，用于区分不同机器的运行结果，体现在结果保存目录的不同上，并不影响实际的运行。在本地运行中也包括这一部分，然而不像本地运行时机器的参数可以直接从系统获取，在虚拟机中运行我们需要记录实际上虚拟机运行的环境参数，包括实际使用的内核的commit号、分支、系统架构（是不是64位）等。

1. 用户名称。在虚拟机中运行时，系统需要创建用户，这里指定了其名称，默认为lkp。

1. 镜像信息。这部分是最重要的一部分，虚拟机运行所需的镜像文件的路径信息全部在这部分指定。主要包括内核镜像、内核附加模块镜像、文件系统镜像、监视器程序、测试用例程序。

1. bootloader信息。在运行qemu时，使用`-kernel`、`-initrd`、`-append`三个参数来形成bootloader的功能，三者会直接被加载进虚拟机内存的相对位置，并且会从kernel的第一条语句开始执行，这里设置的`-append`参数则是传递给kernel的参数，引导kernel、挂载rootfs后，就会参照`-append`的内容进行相应的操作，比如运行指定的脚本等。

以上配置信息的具体使用之处会在后面启动qemu时具体分析。#FIX#

接下来就是将之前配置的所有信息通过Job类保存到文件中，通过`save()`会直接保存成YAML文件，即在原来作为参数的文件的基础上增加了一些新的键值对，通过`job2sh()`将YAML文件转换成对应的Shell工作脚本，接下来便可以使用`lkp-exec/qemu`运行这个脚本了，最后的收尾工作和本地运行时是一样的。

## qemu运行过程

在`lkp-exec/qemu`脚本中，还是先会对参数进行检验，然后会source工作脚本将其中函数导入当前Shell环境，接下来调用工作脚本中的`export_top_env()`方法将之前写入的环境配置加载到当前Shell，接着对一系列需要使用的镜像进行打包。

1. lkp-tests项目打包。采用上一章介绍的`pack`命令，将执行`pack/lkp-src`中的一系列方法，#FIX#具体来说，是在`/tmp`目录下创建一个`lkp_initrd-$USER`文件夹，将项目目录链接到此，然后用`find | cpio | gzip`的形式进行打包，最终生成`/tmp/lkp_initrd-$USER/lkp/$LKP_USER/lkp-${ARCH}.cgz`。

1. 测试程序打包。调用`create_job_initrd()`，将工作脚本打包，同样采用`cpio | gzip`的形式，最终生成`/tmp/lkp/scheduled/${testcase}.cgz`

1. 内核镜像打包。调用`get_qemu_kernel_initrd()`，进而调用`lib/kexec.sh`的`download_kernel_initrd()`下载所有内核镜像，再加上传入的两个参数（即项目镜像和测试程序镜像）合并成一个cgz文件，但是似乎下载的与本地的有重复#FIX#。最终生成`/tmp/initrd-$$`，以进程号命名的文件。

之后，进行四项配置，`setup_qemu_console`、`setup_qemu_netdev`、`setup_vdisk_root`、`setup_qemu_drives`，#FIX#

最后便可以调用`run_kvm()`启动qemu了，之前的准备都通过qemu的参数进行体现，比如`-kernel $kernel_file`设定了虚拟机的内核；`-initrd $concatenate_initrd`，是第三步打包的镜像，所有镜像的文件全部解压在根目录下便成了虚拟机的文件系统。#FIX#

由于启动参数有`-device virtio-9p-pci,fsdev=test_dev,mount_tag=$mount_tag`，使得最终结果能同步在物理机的相同位置#FIX#，这样便得到了虚拟机中运行测试用例的结果。

以上便是虚拟机运行的整个流程。
