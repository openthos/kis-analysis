# Analyzing Data

'lkp analyze' is used to analyze data collected from result roots by 'lkp
collect'.

## Usage

```
    Usage: analyze [options] data_file [param=value]

    options:
        -a, --algorithm ALGORITHM        ALGORITHM to use
            --list                       list algorithms available
        -h, --help                       Show this message
```

## Find all algorithms available

To print a comprehensive list of algorithms available:

```
    lkp analyze -l
```

The command will print something like this:

```
Algorithms available:
    ...
       high.cor - Top pairs of fields with highest correlation
                  count: number of top field pairs to print
                         default = 10
    ...
```

where 'high.cor' is the algorithm name (can be given to the -a option), followed
by a short description of the algorithm. Below the algorithm description is a
list of parameters with a description and the default value.

## Example

```
    # Collect some data and save them to time.csv
    lkp collect -c testcase=hackbench -g '^time\.' -G '\.max$' -o time.csv

    # List all algorithms available
    lkp analyze -l
    # Output:
    # Algorithms available:
    #        dump - Dump lines as is
    #      dump.s - Dump streaming lines as is
    # rm.zero.var - Remove columns with 0 variance and save it to CSV
    #               output: CSV file to save
    #                       default = data.csv
    #    high.cor - List top pairs of fields with highest correlation
    #               count: number of top field pairs to print
    #                      default = 10
    # ...


    # List top 20 pairs of axes or stats that are most highly correlated
    lkp analyze -a high.cor time.csv count=20
    # Output:
    # First.Variable                   Second.Variable Correlation
    # 1                   time.system_time  time.percent_of_cpu_this_job_got   0.9980352
    # 2    time.voluntary_context_switches time.involuntary_context_switches   0.9890684
    # 3                  time.elapsed_time                    time.page_size   0.9591263
    # 4                     time.user_time  time.percent_of_cpu_this_job_got   0.8784949
    # 5                     time.user_time                  time.system_time   0.8573843
    # 6                   time.system_time   time.voluntary_context_switches   0.7040014
    # 7                   time.system_time time.involuntary_context_switches   0.6970048
    # 8   time.percent_of_cpu_this_job_got   time.voluntary_context_switches   0.6890780
    # 9   time.percent_of_cpu_this_job_got time.involuntary_context_switches   0.6843335
    # 10                    time.user_time time.involuntary_context_switches   0.5993613
    # 11                    time.user_time   time.voluntary_context_switches   0.5791311
    # 12                    time.user_time            time.minor_page_faults   0.5283160
    # 13  time.percent_of_cpu_this_job_got    time.maximum_resident_set_size   0.5096318
    # 14                  time.system_time    time.maximum_resident_set_size   0.4942061
    # 15                    time.user_time    time.maximum_resident_set_size   0.4923047
    # 16   time.voluntary_context_switches          time.file_system_outputs  -0.4051415
    # 17 time.involuntary_context_switches          time.file_system_outputs  -0.3917815
    # 18  time.percent_of_cpu_this_job_got            time.minor_page_faults   0.3617438
    # 19                  time.system_time            time.minor_page_faults   0.3383548
    # 20                  time.system_time          time.file_system_outputs  -0.3172372
```
