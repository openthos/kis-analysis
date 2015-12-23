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

安装collectd-turbostat。

在找资料过程中，发现github上有几个lkp-tests的repo，考虑到官网的repo很久没更新的样子，我重新下了一个三天前更新过的[repo](https://github.com/fengguang/lkp-tests)
不知为何这样就不提示`wait`的问题了，尽管目录下依然没有`wait`。

## 12-21 ##

首先`lkp install jobs/hackbench.yaml`会需要安装一系列依赖。

其中ruby-git没法装，`gem install git`
注意换[淘宝源](https://ruby.taobao.org/)，不然没法下载。
同时安装以下依赖，不然gem没法运行似乎。
ruby-devel
libsqlite3x-devel
rpm-build
zlib-devel

