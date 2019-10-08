## 操作细节

### 测试前准备

首先执行`lkp run <benchmark name>`命令，按照在[打包过程](../pack/pack_4_operation_detail.md)中所述，针对run参数调用`run-local`Ruby脚本进行接下来的操作。

由于传入的参数是一个指示Benchmark运行配置的yaml文件，所以首先需要对这个文件进行解析。这里引入了几个重要的全局变量：

```
LKP_USER = ENV["USER"] || `whoami`.chomp
ENV['TMP'] = "/tmp/lkp-#{LKP_USER}"
ENV['BENCHMARK_ROOT'] = '/lkp/benchmarks'
```

第一个是存储当前用户名，第二个是之后运行结果的临时储存目录，第三个就是之前打包（pack）操作下载的Benchmark所在目录。

之后进行一系列参数有效性的检测，进而声明了一个新的`Job`类的实例，这个类是在`lib/job.rb`里定义的，主要负责存储Benchmark运行的所有配置以及环境的配置信息，最终利用`to_hash()`方法和`lib/job2sh.rb`脚本完成生成job script文件的步骤。

这中间有一个过程值得一提，关于结果目录的创建，使用的如下函数：

```ruby
#bin/run_local
def create_result_root(_result_root)
	0.upto(99) do |i|
		result_root = "#{_result_root}/#{i}"
		next if Dir.exist? result_root
		FileUtils.mkdir_p result_root, :mode => 02775
		return result_root
	end
	$stderr.puts "cannot create more result_roots under #{_result_root}"
	return nil
end
```

会依次判断结果目录中0~99是否已经存在，创建一个最小的未存在的数字作为本次运行结果的存储目录。而这个传入的参数，即结果的根目录默认状态下又是来自于`lib/result.rb`中的`ResultPath`类，由`Job`类初始化时进行获取并存储为成员变量`_result_root`。

于是便得到另一个重要的环境变量：

```
ENV['RESULT_ROOT'] = result_root
```

###　监视器及测试程序的运行

工作脚本生成完成之后，通过系统shell运行，语句如下：

```ruby
#bin/run_local
system job_script, 'run_job'
system LKP_SRC + '/bin/post-run'
system LKP_SRC + '/monitors/event/wakeup', 'job-finished'
system job_script, 'extract_stats'
```

首先调用工作脚本（以`run_img/ebizzy-test.sh`为例进行说明）中的`run_job`函数，启动测试，这里会导入两个脚本文件，后面会用到里面的函数。

```bash
#/$result_root/job.sh
. $LKP_SRC/lib/job.sh
. $LKP_SRC/lib/env.sh
```

接着调用自身`export_top_env`函数，会把之前在`run-local`中设定的配置变量export导入到当前的环境变量中。然后会异步执行`default_monitors`函数（`&`符号），准备启动监视器：

```bash
#/$result_root/job.sh
default_monitors()
{
	run_monitor $LKP_SRC/monitors/event/wait 'activate-monitor'
	run_monitor $LKP_SRC/monitors/wrapper kmsg
	...
}
```

这里通过异步创立新进程的方式启动监视器，就是为了能在运行测试的同时运行监视器记录系统状态。这里的`wait`程序起的是类似互斥锁的作用，会一直等到`wakeup`执行才会接着运行。`wait`是一个符号链接，指向`monitors/event/wakeup`，是一个用C写的程序。通过调用时使用的名称（`argv[0]`），可以达到休眠和唤醒的两种功能。

程序中使用了`命名管道`以达到使进程休眠等待的目的。首先使用`getopt_long`获取参数，如果有`-t`或者`-timeout`参数，则会设置超时限定。核心的参数，比如上面的`activate-monitor`则是通过`mkfifo()`创建`命名管道`，其类似一个互斥锁文件，当一个进程对其进行`read`操作时，会被锁死，直到另一个进程对这一个命名管道进行`write`操作。

在这里，新进程运行到`wait`处会进行等待，从而使监视器的启动过程被挂起直到测试程序运行前一刻才继续进行：

```bash
#/$result_root/job.sh
run_test $LKP_SRC/tests/wrapper ebizzy
```

```bash
#lib/job.sh
wakeup_pre_test()
{
	...
	$LKP_SRC/monitors/event/wakeup activate-monitor
	...
}
...
run_test()
{
	wait_other_nodes 'test' $program
	wakeup_pre_test
	"$@" # 运行测试程序
	check_exit_code $?
	sync_cluster_state 'finished'
}
```

原进程创建新进程运行`default_monitors`后，接着执行，在`run_test()`里会调用`wakeup`唤醒之前在`wait`挂起的新进程。然后用`tests/wrapper`执行测试程序（以`ebizzy`为例）。

需要注意的是，执行监视器脚本用的是`monitors/wrapper`，而执行测试程序用的是`tests/wrapper`，这两个脚本功能类似，但是应用的对象并不同。之后`extract_stats()`中还涉及到了`stats/wrapper`，这个之后再说。

`monitors/wrapper`负责执行监视器脚本程序，记录监视器进程pid，并将监视器的标准输出写在一个命名管道`fifo=$TMP/fifo-$monitor`中（异步调用），并最后将其`cat`到结果目录中的`monitor`文件中（视情况还可能用gzip对其进行压缩）（也是异步调用），两部分的语句通过命名管道连接了起来，最终实现的就是监视器的标准输出被存储到`$RESULT_ROOT`中（`$RESULT_ROOT`和`$TMP_RESULT_ROOT`的值是相等的）。

```bash
# monitors/wrapper
stdbuf -o0 -e0 $monitor_dir/$monitor "$@" > $fifo &
...
$gzip -c < $fifo		> $TMP_RESULT_ROOT/$monitor.gz &
cat-$monitor	   $fifo		> $RESULT_ROOT/$monitor &
```

`tests/wrapper`负责执行测试程序，记录wrapper进程pid和测试程序pid，更重要的是通过命名管道将测试程序运行中的标准输出用`tee`重定向到了`$TMP_RESULT_ROOT/$program`文件中，原理与上面类似。

```bash
# tests/wrapper
tee-$program -a $TMP_RESULT_ROOT/$program < $fifo &
...
exec $time_prefix $exec_prefix $program_dir/$program "$@" > $fifo
```

在创建新进程执行测试程序后，会再开启一个监视器`watchdog`，用于管理程序的终止，之后在`bin/run-local`中执行`wakeup 'job-finished'`会让`watchdog`调用`kill_tests()`终止进程。

### 结果文件处理

回到`bin/run-local`中，接着会调用`postrun`，此脚本主要负责将运行时临时存储在`$TMP`目录的结果文件拷贝到result目录。然后`wakeup job-finished`唤醒`watchdog`进程进行相关进程的收尾工作，并调用工作脚本的`extract_stats`进行结果的收集，具体来说会使用`stats/wrapper`调用`stats`文件夹中对应的脚本对上文提到的结果文件进行进一步处理。

然后使用`lib/stats.rb`中的方法对所有的结果处理之后生成最终的结果文件`stats.json`，并用`unite_to()`方法生成平均值`average.json`和整合值`matrix.json`两个文件，到此整个运行过程就算完成了。

以上就是整个本地运行过程的细节描述。
