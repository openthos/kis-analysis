## How to Run

1. Install necessary packages according to [depend1](https://github.com/dc3671/lkp-tests/blob/master/distro/depends/lkp-dev_bak) and [depend2](https://github.com/dc3671/lkp-tests/blob/master/distro/depends/lkp_bak)

    ```
    make
    automake
    gcc
    libtool
    libtool-bin
    patch
    git
    cpio
    wget
    ```
    
    and

    ```
    bc
    gawk
    linux-tools
    ruby
    ruby-gnuplot
    sysstat
    time
    kmod
    gzip
    xz-utils
    ```

2. Add environment variable, using `envsetup.sh`

3. Set correct server address in `bin/run-qemu` - `LKP_SERVER`

4. Run `bin/run-qemu <job-file:*.yaml> <kernel_path:kconfig/compile/commit> <vmlinuz-**-**>`

5. See results at `/result`

## A Important Control Flow

`run-qemu` change `.yaml` to `.sh` and add many important key-value pairs.
|
v
`lkp-exec/qemu` run `.sh` file.
|
v
`lib/kexec.sh`, `lib/qemu.sh`, `lib/unit.sh, `lib/job-init.sh`

## Directory Illustration

**1. jobs/.yaml**

contains job files used when `lkp run <job file>`. the key-value pairs under the *same name* of job-file set the different args to run the benchmark/test-job. other root-level key-value pairs set `lkp`'s args.

在测试同名键值对下的子键值对是test本身需要的参数，其他根级键值对应该是lkp的运行参数。

**2. stats/**

handle the raw output of benchmark from the `line` variable using regularization method.

主要是ruby脚本，对line这个变量的信息处理，目的是正则化测试的初始输出，形成每个测试独有的关键输出结果。

**3. pack/**

download and pack/move benchmark files. set download source and how to pack the files.

global:

- benchmark location:

`BM_ROOT=/lkp/benchmarks/$BM_NAME`

- default pack operation:

in `pack/default` file

need to set:

- install function:

```
install() {
    # what to do with the downloaded file / copy necessary file to $BM_ROOT
}
```

**4. tests/**

how to execute the benchmark. set the args, eg: iteration times, and args set in `.yaml` file. 

    cmd /usr/bin/$BM_NAME -args


**Permission：** files under `pack`, `stats` and `tests` need to be **executable**.

*\*more details see `nbench` files under each directory*

## Some Internal Environment Variable:

    $PATH=$BENCHMARK_ROOT/netperf/bin:$PATH
    $BENCHMARK_ROOT=/lkp/benchmarks
    $LKP_SRC=<project location>
    $BM_ROOT=/lkp/benchmarks/$BM_NAME`

see `lib/constant-shared.rb`.

## Compare(FIX ME):

```
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
    
    lkp compare **-a** commit1 commit2
    lkp compare **-a** -d fs ubuntu fedora
    ...

