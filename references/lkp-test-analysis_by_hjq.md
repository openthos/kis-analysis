# LKP Tests Notes

30 Oct 2014

[← back](http://hejq.me/)

LKP-Tests is a linux kernel performance testing framework authored by Fengguang Wu @ Intel.

Codes gitted from

```
git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
```

## 1. setup-local

### make_wakeup

```
(1) make and enter dir /tmp/event_pipe
(2) make FIFO file argv[1]
(3) if run by ./wait then exit
(4) write 1024 chars out to the FIFO file
(5) fork
    parent: write the child pid out to /tmp/pid-wakeup, then exit
    child: close all the files inherited from parent
(6) child is raised to the process group leader of a new session
(7) ignore four sigals: SIGCHLD/SIGTSTP/SIGTTOU/SIGTTIN
(8) sleep 100 hours
```

### create_lkp_dirs

```
(1) create LKP_HOME/tmp
(2) create /lkp/paths
(3) create /lkp/benchmarks
```

### create_host_config

```
(1) guarantee file LKP_HOME/hosts/HOSTNAME exists
(2) write the memory size to it
(3) maybe some other arguments
```

### insall_packages

```
(1) call `install_debian_packages('lkp', 'debian')`
    install the packages listed in LKP_HOME/debian/lkp
(2) call `install_debian_packages('lkp-dev', 'debian')`
    install the packages listed in LKP_HOME/debian/lkp-dev
```

### Iterate over `scripts`

#### The framework

Also call `install_debian_packages(script)` or `install benchmark(script)`. But here the scripts mainly download and install the benchmarks. The details on this procedure need more survey.

#### The pack scripts

The scripts that download and install benchmarks are put in  LKP_HOME/pack. LKP_HOME/pack/default defines many shell script functions  in the default case. Other files in LKP_HOME/pack override the  functions in each case while downloading and installing one certain  benchmark.

With the scripts in LKP_HOME/pack, the LKP_HOME/sbin/pack works. It just call the `download`, `build` and `install`, and then `pack_deb`, `cleanup`.

**The default scripts**

```
git_clone_update $url $dir:
    Clone url into dir.
pre_download:
    Do nothing.
download:
    Run wget --no-clobber $WEB_URL, and extract it if it's a tar.
patch_source:
    If $LKP_HOME/pack/${BM_NAME}.patch exists, then apply it.
build:
    Enter $source_dir, patch_source. Run ./configure $CONFIGURE_FLAGS if configuration file is executable. Make if a makefile exists.
install:
    Run make install-exec if a makefile exists.
pack_deb: 
    Pack the benchmark into a deb package.
pack:
    Pack /lkp/benchmarks/$BM_NAME/* to /tmp/${BM_NAME}.cgz
post_cleanup:
    Do nothing.
cleanup:
    Run rm -f  "/tmp/${source_package}" && rm -fr "/tmp/${source_dir}".
```

## 2. run-local

When `run-local` is run, **2** major tasks are carried out: running the benchmark and starting the system monitors. The details are store in a class name `Job` in the file `lib/job.rb`.

> How to store a job? After started, the scipts receive a yaml file from the cmd argument. `Job.load(jobfile)` is called to read and load the job configuration and store the job profile in a member named @job.

In fact, in `run-local`, the scripts only create the  result directory with the job information and set the environment  information of the local machine. More scripts that matter are written  in `run-job`.

## 3. run-job

In `run-job`, the job yaml file is loaded into a hash variable named `testcase`.

And all files in `LKP_SRC/setup`, `LKP_SRC/monitors`, `LKP_SRC/tests` are read into a program cache `$programs`.

Then `testcase` is iterated. For each `<key, value>` in testcase

> - If the key is in the $programs cache, skip
> - If the value is not a Hash, skip
> - Otherwise, the value is a Hash, and the case can only be a Hash of all system monitors. Then take the Hash from `testcase`, and use it to run `run-job` again.

That means now there are two processes. One is running the monitors, and the other is preparing to run the benchmark.

Although the two processes are isolated, they both call `run_program(program, env)` (in `run-job`) to run each command.

After filtered by a function `for_each_program` defined in `job.rb`, `run_program` recceives only the commands in the `$programs` cache.

## 4. post-run

The scripts `post-run` is used to wait for the monitors and pipe to quit, and then copy the following from the $TMP directory to the result diretory:

> - The results of benchmarks and monitors
> - The generated files: time, boottime, env.yaml, stdout, stderr, output

## 5. extract-stats