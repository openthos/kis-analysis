## 01-20 ##

**周度工作总结：**

整套流程主要分三部分：Build（xll），Test（czh），Data Process（mjj）。

我这几天的工作，是在学长的带领下，对于LKP测试这一块有了更加宏观的理解。

运行`lkp qemu`需要输入：module.cgz/vmlinuz.cgz/linux-headers.cgz(from linux kernel)，benchmark.cgz(need to write script program)，monitors.cgz(lkp automatically)。所以我之前的主要工作就是弄清楚如何写benchmark的几个关键脚本。

而输出的格式为一系列键值对，这是运行过程中记录所有信息的方式，最后会用于`lkp compare`等工具将结果进行汇总比较，得到一个report，这部分是由学长负责。

kernel-ci只需要能监测内核的commit，并针对几个Config(all-yes, all-no, default)编译出内核，包括module镜像。之后便可以用于lkp-test进行测试。

---

**之后的工作**

kernel page，kernel config，除了生成内核的镜像，还会有各个模块，要知道如何将模块安装到指定目录下，看看如何装module，如何编译内核。之后自然会知道vmlinuz是什么，linux-headers暂时不用管，没有这个也可以跑。

run-qemu中需要的镜像里，在`/lkp`下和`/osimage`下（缓存在`/tmp/lkp-qemu-downloads/osimage`）的lkp.cgz和turbostat.cgz有什么区别？为什么需要两个？分别是如何来的？

- 学习编译Linux内核
- cgz的理解
- 加一个benchmark(nbench)
- 之前的Bug

## 01-19 ##

对于那个难调的BUG，尝试无果之后决定先尝试熟悉改写四个关键脚本。

找到NBenchMark的一个SVN[地址](https://svn.code.sf.net/p/nbenchmark/code/trunk/NBenchmark/)。介绍似乎表明这个是针对Windows的...

    .NET framework to create benchmarks to measure HW and SW performance, identify system bottlenecks, optimize code, automate performance testing. Designed for .NET Full and Compact Frameworks. Supports Windows 2003, 2008, XP, Vista, Mobile 5.0+, CE 5.0+.

1. jobs/*.yaml

split之后的结果，通过对比，发现会添加共同的`default_monitors`、`memory`等，另外原始yaml中的所有键值对会复制到结果中，另如果包含列表，则split会分出多个，每个里面的键值对只含一项。

初步判断在测试同名键值对下的子键值对是test本身需要的参数，其他根级键值对应该是lkp的运行参数。

2. stats/*

考虑到这里的文件本身是ruby脚本，不太好入手，先分析看看如何生成的这些脚本。用grep看了下，在`lib/job2sh.rb`里看到`create_programs_hash "stats/**/*"`，进一步查看这个函数。

在`lib/job.rb`里找到定义。似乎是**枚举**参数中路径的文件判断是否可执行，并将不冲突的程序加入一个全局变量`program`的`[cache_key]`中。所以应该对stats文件的生成没多大关系。

再返回对比一下`stats/ebizzy`和`stats/hackbench`发现共同之处是对line这个变量的信息进行枚举，然后`puts`输出一些东西。联系其目的是正则化测试的初始输出，猜测是对raw data进行一定程度过滤后形成每个测试独有的关键输出结果。所以还需要先对benchmark本身进行较深入的了解。

另外在看代码的过程中，发现对于ruby的语法有点生疏了，需要抽空复习一下。

3. pack/*

关键变量：`BM_ROOT=/lkp/benchmarks/$BM_NAME`，指代benchmark存储的位置。

发现主要打包步骤是在`pack/default`里，我们需要写的只是下载地址和`install`函数。

`install`函数实际上也不是真的安装，主要是将一些必须文件拷贝到`$BM_ROOT`下，以便之后运行。

4. tests/*

直接负责对benchmark程序的运行，针对不同程序撰写不同参数，并且按照iteration设置好迭代次数。

相对来说比较闭环，与`.yaml`文件中的一些参数名有关，会在这涉及，核心就是：

    cmd /usr/bin/$BM_NAME -args

## 01-15 ##

与学长的`lkp-test`项目Merge了一下，学到了一些小技巧（git/shell/terminal)。

接下来几天的工作：

- 调现有的BUG，处理`no KERNEL found`，需要能得到`/results/.../ebizzy.json`以及`/results/.../stats.json`。
- 将已有的流程应用到一个全新的benchmark上：nbench。需要自己写：
    + `jobs/nbench.yaml`，用于split成对应yaml脚本。
    + `stats/nbench`，正则化初始输出，变成key:value对的形式，能用于其他脚本将结果进一步转换为`.json`格式。
    + `pack/nbench`，用于打包成`.cgz`。
    + `tests/nbench`，指示怎么跑这个benchmark。

直接`run-qemu run-img/ebizzy-test.yaml`会出现`no KERNEL found`，间隔时间很长，可以认为与`lib/bootstrap.sh`中`next_job()`暂停300秒有关，但是直接在此脚本中加入echo没有用。

接下来的调试方法首先得找到能写入有效echo的地方，不然难以弄清其中的流程。

## 01-14 ##

在尝试不同的运行方式的过程中，逐渐熟悉了整个项目的框架，对于`exec/qemu`、`.sh`文件中的配置有所了解。

使用茅学长给的`ebizzy-test.yaml`，利用`lkp job2sh ebizzy-test.yaml`生成`.sh`文件，再`lkp qemu ebizzy-test.sh`。

- 阅读`sbin/pack`，了解如何生成`.cgz`文件。
- 跑通ebizzy这个benchmark后，尝试换一个跑通相同的流程：生成sh、运行`lkp qemu`

在初步阅读`.yaml`文件后，对比正确版本多的东西，可以看到至少在initrd里是需要有测试对应的`.cgz`镜像的，所以需要先从`sbin/pack`下手，生成hackbench的镜像。

阅读了`sbin/pack`的大致内容后，发现它是针对`pack/*`目录下的脚本，下载脚本中url对应的benchmark，而hackbench没有这个脚本（以后有需要也得自己仿照着写），另外考虑到国内能否连上的问题，暂且选取使用`sourceforge.net`的几个benchmark：

    reaim
    thrulay
    ebizzy
    fsmark
    aim9
    aim7

fsmark是测文件系统读写速度的，reaim\aim9\aim7都是一整套测各个方面的，thrulay是测网络的，选thrulay进行下一步。

    The program thrulay is used to measure the capacity, delay, and other performance metrics of a network by sending a bulk TCP or UDP stream over it.


## 01-13 ##

到达上海Intel，跟随学长开始接下来的工作。

对于`lkp compare`，需要基于两个`lkp run/qemu`的结果，给出两个任务的编号。

利用肖络元学长新提交的版本中附带的一些镜像`run_img/lkp-qemu-downloads/*`，将其复制到根目录下，并在`lkp-exec/qemu`中调整（/tmp目录位于内存，也可换另外的目录）：

    LKP_SERVER=localhost
    CACHE_DIR=/tmp/lkp-qemu-downloads

并在两个`wget`处加上`-nc`删去`-N`。

尝试运行，能成功运行`lkp qemu`。

- 我目前的两个主要的任务是弄清楚如何生成.sh文件和如何生成.cgz&.module镜像，而不是必须从公司内部拿现成的。

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

之后询问xll学长结果的含义，发现问题没我想的那么简单。

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

