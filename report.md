## 01-07 ##

可算忙完了开题和一系列期末大作业，可以继续之前的工作了（不过接下去要出去玩几天...）

开始尝试搭建kernelci。

## 12-26 ## 

昨天晚上把新分配的物理机装上了Archlinux，有某些程度上比Fedora好用，但是毕竟新玩意，搞起来还是出现了一些问题。

还是为了解决`lkp install`的依赖，提示需要一个`yaourt`的东西，我一搜，是一个对pacman做了包装的包管理器，能方便的下载AUR(ArchLinux User-community Repository)里的东西，而AUR如其名是受信任用户提供的软件仓库集合，所以不必像Fedora那样手动加很多repo地址了。

为了下这个，得装一个`package-query`的东西，如果按照[软件官网](https://archlinux.fr/yaourt-en)说明，下载AUR包，然后`makepkg -si`，的确会自动下载安装，但是前提是你能连上仓库的服务器。

喜闻乐见，我连不上，或者说实验室内网连不上（鬼知道.fr是哪的域名！），之后从archlinux的[中文wiki](https://wiki.archlinux.org/index.php/Yaourt_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)上找到了可行的方法，把archlinuxcn这个源加入pacman的设置里就好了！

```
#中科大源
[archlinuxcn]
#The Chinese Arch Linux communities packages.
SigLevel = Optional TrustAll
Server   = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
```

然后按照在之前Fedora上的步骤，把其他依赖也装上就行。

其中一个问题是，`libtool-bin`并不是一个软件的名称，但是直觉告诉我装了libtool就够了，所以我打算故技重施把它从依赖中删除，结果我发现`distro/depends/lkp`里没有它！

我用`grep 'libtool-bin' -rn *` 找了之后，发现在同一目录下的lkp-dev里！我也是醉了。

所以昨天晚上的工作就是这些了。


## 12-25 ##

在使用intel工程师提供的hackbench.c之后，已经可以本机跑出结果了。

之后询问肖洛元学长结果的含义，发现问题没我想的那么简单。

hackbench只是各种测试程序之一，而且有一些程序必须使用虚拟机qemu运行，无法本机跑通。

那些结果实际上是不可读的，最终的目的可能是为了生成一个[报告](https://lists.01.org/pipermail/lkp/2015-December/003278.html)

```
+--------------------------------------------------------------+------------+------------+------------+
|                                                              | 200757f5d7 | 3ea85149e8 | 8ae5d9cccf |
+--------------------------------------------------------------+------------+------------+------------+
| boot_successes                                               | 63         | 0          | 0          |
| boot_failures                                                | 0          | 22         | 19         |
| WARNING:at_drivers/gpu/drm/drm_crtc.c:#drm_property_create() | 0          | 22         | 19         |
| backtrace:drm_property_create                                | 0          | 22         | 19         |
| backtrace:drm_mode_config_init                               | 0          | 22         | 19         |
| backtrace:bochs_kms_init                                     | 0          | 22         | 19         |
| backtrace:__pci_register_driver                              | 0          | 22         | 19         |
| backtrace:drm_pci_init                                       | 0          | 22         | 19         |
| backtrace:bochs_init                                         | 0          | 22         | 19         |
| backtrace:kernel_init_freeable                               | 0          | 22         | 19         |
| IP-Config:Auto-configuration_of_network_failed               | 0          | 0          | 4          |
+--------------------------------------------------------------+------------+------------+------------+
```

对于使用qemu运行，虚拟机的镜像默认设置是从bee.sh.intel.com获取，而这是内部网站，所以学长之前的处理方式是架设ftp，修改源码($LKP_SRC/lkp_exec/qemu)中的网址，也可以考虑修改host定向到本机的ftp。

关于`lkp compile`学长还演示了一下作用，生成的源码可以导出成`.sh`文件，使用`lkp qemu`运行，实际上之前本机的运行结果文件夹中有0、1、2、...等文件夹，指代每一次运行测试的结果，其中也有job.sh，也是可以用lkp qemu运行的。

所以现在的任务是搭一个FTP，争取能跑通qemu模式。

A intersting name: 0 day kernel testing robot.

## 12-24 ##

对于/proc/sys下的文件

应该使用 echo 命令，然后从命令行将输出重定向至 /proc 下所选定的文件中。例如： 

    echo "Your-New-Kernel-Value" > /proc/your/file

类似的，如果希望查看 /proc 中的信息，应该使用专门用于此用途的命令，或者使用命令行下的 cat 命令。 

改了/proc/sys/kernel/perf_event_paranoid，改成0之后权限问题似乎没了。

依旧跑不通。偶然情况下，误输入如下命令：

    lkp install hackbench-50%-threads-socket.yaml

结果竟然编译安装了新东西，在根目录下出现了之前的一个报错缺失的内容：`/lkp/benchmark`

而且里面有turbostat！

而且`$LKP_SRC/monitors`里也有了turbostat

现在只剩下`/usr/bin/hackbench`的问题了


## 12-23 ##

`lkp install`仅是安装任务运行所需的依赖程序，不会具体做什么。

`lkp split/run`才是分解任务、运行任务，会有具体结果日志

`lkp install`似乎由于系统平台问题，ruby-git无法识别，只能去`./distro/depends/lkp`把依赖删了。

`lkp run`的过程中，以下三个找不到。

    lkp-tests/monitors/event/wait
    vmstat
    /usr/bin/hackbench


第二个安装procps-ng即可，第一、三个不知道怎么解决。

安装后，出现新的问题：

    /root/Project/lkp-tests/monitors/turbostat: line 10: cd: /lkp/benchmarks/turbostat

安装`collectd-turbostat`。

在找资料过程中，发现github上有几个lkp-tests的repo，考虑到官网的repo很久没更新的样子，我重新下了一个三天前更新过的[repo](https://github.com/fengguang/lkp-tests)

不知为何这样就不提示`wait`的问题了，尽管目录下依然没有`wait`。

!!!一直没注意jobs目录下有个readme!!!

## 12-21 ##

首先`lkp install jobs/hackbench.yaml`会需要安装一系列依赖。

其中ruby-git没法装，`gem install git`

注意换[淘宝源](https://ruby.taobao.org/)，不然没法下载。

同时安装以下依赖，不然gem没法运行似乎。

    ruby-devel
    libsqlite3x-devel
    rpm-build
    zlib-devel

