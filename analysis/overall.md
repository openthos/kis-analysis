Some Internal Environment Variable:

    $PATH=$BENCHMARK_ROOT/netperf/bin:$PATH
    $BENCHMARK_ROOT=/lkp/benchmarks

Analysis Methods:

    [Book]() Chapter Three

Permission：

files under `pack`, `stats` and `tests` need to be **executable**.

Compare:

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

1. For one only test result:

command:

    lkp compare abs_path1 abs_path2


path is like:

    /result/hackbench/50%-threads-socket/Lab_Arch/arch/defconfig/gcc/4.2.5-1-ARCH/1`

as:

    /result/*benchmark_kind/*test_config/*Hostname/*file_system&release_version/*kconfig/*compiler/*commit/*test_number

2. For all test comparison between two DIMENSION:

command:
    
    lkp compare **-a** commit1 commit2
    lkp compare **-a** -d fs ubuntu fedora
    ...

