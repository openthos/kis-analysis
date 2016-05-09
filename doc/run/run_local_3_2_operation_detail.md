## 操作细节

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


在打包（pack）中完成下载的

wakeup，用于暂停、唤醒进程，使监视器记录状态。

postrun，用于发起运行，并负责将临时结果文件保存到result目录。

output文件是在lkp-init文件中用tail命令记录的，临时存于/tmp/lkp-${LKP_USER}

以上就是整个本地运行过程的细节描述。
