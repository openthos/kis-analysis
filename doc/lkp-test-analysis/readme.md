# lkp-test运行步骤
- 下载应用于本地环境的lkp-test的
[patch](https://github.com/openthos/kis-analysis/blob/master/doc/lkp-test-analysis/0001-Fix-the-bugs-of-lkp-test.patch)，并apply
  -  注意：HTTP_PREFIX=http://192.168.0.77/lkp-qemu 对应的是自身搭建的http服务器，用于运行过程中下载对应文件，所以请保证连接到实验室内部网络

- Getting started
```
cd lkp-tests
make install
lkp help
```
- Install packages for a job
```
# browse and select a job you want to run, for example, jobs/hackbench.yaml
ls lkp-tests/jobs
	
# install the common dependencies for lkp
lkp install
```
- Run one atomic job
```
lkp split-job ./jobs/ebizzy.yaml
# output is:
# ./jobs/ebizzy.yaml => ./ebizzy-10s-100x-200%.yaml
```
- 在上述命令生成的yaml末尾添加如下内容：
```
kernel: "/fbc/5b51ae969e3d8ab0134ee3c98a769ad6d2cc2e24/vmlinuz-5.2.0-rc3-00004-g5b51ae969e3d8a"
initrd: "/osimage/debian/debian-x86_64-2018-04-03.cgz"
bm_initrd: "/lkp/benchmarks/ebizzy-x86_64.cgz"
user: "lkp"
job_file: "/lkp/jobs/ebizzy-10s-100x-200%.yaml"
```
- compile 
```
lkp compile ./ebizzy-10s-100x-200%.yaml  -o ebizzy.sh
```
- 上述步骤会在lkp-test目录下生成ebizzy.sh，将之前生成的yaml文件一同拷贝到/lkp/jobs（若目录不存在创建之）
- 最后执行qemu
```
lkp qemu  /lkp/jobs/ebizzy.sh
```
- 正常现象终端会有输出信息，并且输出信息保存在~/.lkp 下
