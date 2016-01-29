# Collecting Data from Result Roots

'lkp collect' is used to collect certain fields from result roots and save the
data in common data format for further use.

## Usage

```
    Usage: collect [options]

    options:
        -c, --condition AXIS=VALUE       only collect fields from result roots with AXIS being VALUE
        -f, --format FORMAT              FORMAT to use for the output file
        -g, --grep PATTERN               only collect fields matching PATTERN
        -G, --invert-grep PATTERN        only collect fields not matching PATTERN
        -o, --output FILE                save collected data to FILE
            --no-na                      Try hard to exclude all stats w/ N/A.
        -h, --help                       Show this message
```

## Where to collect from

'lkp collect' collects data from result roots satisfying the conditions which
are given with the -c options. When multiple -c options are given, 'lkp collect'
will search for result roots that satisfy *ALL* the conditions.

For example, in the following result roots,

```
/result/hackbench/50%-threads-socket/localhost/ubuntu/defconfig/gcc-4.9/3.19.0-43-generic
/result/hackbench/50%-threads-socket/localhost/ubuntu/defconfig/gcc-4.8/3.19.0-43-generic
/result/hackbench/50%-threads-socket/localhost/ubuntu/defconfig/gcc-4.9/3.13.0-24-generic
/result/hackbench/50%-threads-socket/localhost/ubuntu/defconfig/gcc-4.8/3.13.0-24-generic
```

all result roots satisfy '-c testcase=hackbench', while the first two satisfy
'-c commit=3.19.0-43-generic'. As for '-c commit=3.19.0-43-generic -c
compiler=gcc-4.9', only the first result root satisfies all the conditions.

## What to collect

'lkp collect' collects axes or stats that

1. are common in all result roots satisfying the given condition,
2. have the same type in all result roots (e.g. all are vectors of numerals or a
   string scalar),
3. match all patterns given with -g options, and
4. match no pattern given with -G options.

For each axis or stat, one scalar value is collected from a single result
root. If the value of an axis or stat is a vector in the matrix in a result
root, the vector is summarized as follows.

* If the value is a vector of numbers, 'lkp collect' will collect, instead of
  one stat '[stat]', two stats namely '[stat].avg' and '[stat].stddev',
  representing the average and standard deviation, respectively.
* If the value is a vector of strings, only the first value in the vector is
  collected.

## Output

The collected data will be stored in the file given by the -o option. Users can
explicitly state in what format should be data be stored by a -f option. When
the output format is not explicitly given, 'lkp collect' will try to guess from
the extension of the file name.

For now, only CSV format (with header) is supported.

## Example

```
    # Run a few tests to get some data
    lkp split-job $LKP_SRC/jobs/hackbench.yaml
    for i in $(seq 1 3); do lkp run hackbench-50%-threads-socket.yaml; done
    for i in $(seq 1 3); do lkp run hackbench-50%-threads-pipe.yaml; done

    # Collect time.*, excluding *.max, from all hackbench results, and save the data to time.csv
    lkp collect -c testcase=hackbench -g '^time\.' -G '\.max$' -o time.csv
    # time.csv:
    # time.user_time,time.system_time,time.percent_of_cpu_this_job_got,...
    # 1009.43,12704.23,2257.0,...
    # 1000.78,13039.4,2277.0,...
    # ...
```

## Known Issues

* String data are collected as is. This may not work for analysis algorithms
  requiring all data being numeral.
* There is no explicit order among lines in the collected data.
