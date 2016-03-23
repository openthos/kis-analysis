# Linux Kernel Performance tests

## Basic Introduction

see intel original repo [README](https://github.com/fengguang/lkp-tests/)

## How to Run with QEMU

1. Install necessary packages: try to run `lkp install <any job file in ./jobs`, or mannually install according to [depend1](https://github.com/dc3671/lkp-tests/blob/master/distro/depends/lkp-dev_bak) and [depend2](https://github.com/dc3671/lkp-tests/blob/master/distro/depends/lkp_bak) 

    Note: these package names may differ slightly in different OS, default in Ubuntu 14.0

        ```
        make        automake    gcc         libtool     patch 
        git         cpio        wget        bc          linux-tools  
        gawk        ruby        sysstat     time        ruby-gnuplot
        kmod        gzip        xz-utils
        ```

2. Add environment variable, using `envsetup.sh` or adding it to related config file.

3. Set correct server address in `bin/run-qemu` -> `LKP_SERVER`. Put file-system image, kernel image and benchmark archive in correct path: root path in web server, or local cache path default in /lkp-cache/lkp-qemu-downloads like the folder in `./run_img`)

4. Run 

    ```
    bin/run-qemu  <job-file:*.yaml>  <kernel_path:kconfig/compile/commit>  <vmlinuz-**-**>
    eg: run-qemu ./jobs/ebizzy.yaml x86_64-test/gcc-test/test-commit vmlinuz-4.2.0-rc8
    ```

    Note: modules.cgz file's name is temporarily hardcoded.

5. See results default at `/result` (in root path)

## A Important Control Flow

`run-qemu` change `.yaml` to `.sh` and add many important key-value pairs.
|
v
`lkp-exec/qemu` run `.sh` file.
|
v
`lib/kexec.sh`, `lib/qemu.sh`, `lib/unit.sh, `lib/job-init.sh`

## How to Run Locally

Make sure the first two steps in `How to Run in QEMU` are done.

3. Put correct benchmark archive file (like `ebizzy-x86_64.cgz`) in `/lkp/benchmark` folder.

4. Run 

    ```
    lkp run <job-file:*.yaml>
    eg: lkp run ./jobs/ebizzy.yaml
    ```

5. See results default at `/result` (in root path)

## How to add a new benchmark

Mainly four script files need to be written.

Note: *more details see `nbench` files under each directory*

**1. jobs/.yaml**

contains job files used when `lkp run <job file>`. the key-value pairs under the *same name* of job-file set the different args to run the benchmark/test-job. other root-level key-value pairs set `lkp`'s args.

*basic tempalte:*

```yaml
testcase: <benchmark name>
category: benchmark

iterations: <times to run, eg: 10x>

<benchmark name>:       # some args needed to run the benchmark
    <key-value pairs>   # differ in benchmarks
    ...
```

More format related info see in [YAML Introduction](http://www.ibm.com/developerworks/cn/xml/x-cn-yamlintro/) or other references.

**2. stats/**

mainly a ruby script file. handle the raw output of benchmark from the `line` variable using regularization method.

*basic tempalte:*

```ruby
#!/usr/bin/env ruby

<some variables needed below>

while line = STDIN.gets
    case line.chomp!    # handle the stdout in line
    when <Regular Expression to match the line>
        
        <code block, what to do>

        #what to write in final result file `stats.json`
        puts <key-value pairs> 

    ...

# example:
    when /^=+LINUX DATA BELOW=+$/
        flag = true
    when /^MEMORY INDEX        : ([0-9\.]+).*$/
        if flag == true
            memindex = $1
            puts 'memindex: ' + memindex
        end
    when /^INTEGER INDEX       : ([0-9\.]+).*$/
        if flag == true
            intindex = $1
            puts 'intindex: ' + intindex
        end
    when /^FLOATING-POINT INDEX: ([0-9\.]+).*$/
        if flag == true
            fltindex = $1
            puts 'fltindex: ' + fltindex
            flag = false
        end
    end
# end of example. finally get three key-value pairs: memindex, intindex and fltindex

end

```

**3. pack/<benchmark name>**

download and pack/move benchmark files. set download source and how to pack the files.

*basic tempalte:*

```shell
#!/bin/bash

# two basic VARIABLEs
VERSION="2.2.3"
WEB_URL="http://www.tux.org/~mayer/linux/nbench-byte-${VERSION}.tar.gz"

# install() function, used when download benchmark
install()
{
    <what to do after compile>
    // like: copy runable files and dependency files to $BM_ROOT
    // no need to `make`
    // eg:
    cp -af $BM_NAME $BM_ROOT
    cp -af *.DAT $BM_ROOT
}
```

**4. tests/**

how to execute the benchmark. set the args, eg: iteration times, and args set in `.yaml` file. 


*basic tempalte:*

```shell
#!/bin/sh
# - test

cd $BENCHMARK_ROOT/<benhmark name> || exit

start_time=$(date +%s)

for i in $(seq 1 $iterations)
do
    echo Iteration: $i
    <cmd /usr/bin/$BM_NAME -args>
done

```

**Permission：** files under `pack`, `stats` and `tests` need to be **executable**.

## Some Internal Environment Variable:

```shell
$PATH=$BENCHMARK_ROOT/netperf/bin:$PATH
$BENCHMARK_ROOT=/lkp/benchmarks
$LKP_SRC=<project location>
$BM_ROOT=/lkp/benchmarks/$BM_NAME
```

see `lib/constant-shared.rb`.

## Compare(FIX ME):

```shell
options:
-c, --color WHEN                 WHEN coloful: never, always, auto.
-d, --dimension DIMENSION        **DIMENSION to compare**: commit, kconfig, fs, etc.
-f, --field FIELD                **FIELD to evaluate**: vmstat.cpu.sy, iostat.sda.util, etc.
-g, **--grep PATTERN**               only compare result roots that match PATTERN
-G, **--invert-grep PATTERN**        dont compare result roots that match PATTERN
-p, --plot                       plot bar graph
-a, --all                        **compare all**
-s, --save-changes               save all performance and bisectable changes to a file
-t, --group-by-test              test-grouped output format
-i, --index                      performance/power index
    --ignore-incomplete-run      ignore incomplete runs
-D, --distance N                 threshold of changes
-P, --perf                       show performance changes only
-r, --resize N                   resize first matrix
-v, --variance N                 show variance changes larger than N times
    --no-hide-noises             do not hide noisy results
-h, --help                       Show this message
```

default is comparing `commit`, and `benchmark`(hackbench's category) has its own default FIELDs to test&compare showed in `DEFAULTS-benchmark`.

**1. For one only test result:**

command:

    lkp compare abs_path1 abs_path2


path is like:

    /result/hackbench/50%-threads-socket/Lab_Arch/arch/defconfig/gcc/4.2.5-1-ARCH/1`

as:

    /result/*benchmark_kind/*test_config/*Hostname/*file_system&release_version/*kconfig/*compiler/*commit/*test_number

**2. For all test comparison between two DIMENSION:**

command:

```shell    
lkp compare **-a** commit1 commit2
lkp compare **-a** -d fs ubuntu fedora
...
```
