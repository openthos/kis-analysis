## 操作细节

打包（pack）操作的目的是为了让打包的文件能在运行（run）操作时方便地使用。

首先执行`lkp pack <benchmark name>`命令，`$LKP_SRC/bin/lkp`是原项目中所有操作的汇总脚本，其后的第一个参数决定之后将执行具体哪一个脚本，并接受之后传递的其他所有参数。

```bash
#./bin/lkp
try_run()
{
	local subdir="$1"
  local path="$LKP_SRC/$subdir/$lkp_command"
	shift
  [ -x "$path" ] && exec "$path" $lkp_args "$@"
}
try_run 'bin'		"$@"
try_run 'sbin'		"$@"
try_run 'tools'		"$@"
try_run 'lkp-exec'	"$@"
```

以上语句会遍历四个分类存放不同可执行脚本的目录，试图在其中寻找执行命令中第一个参数对应的脚本，接着调用它并把其余的参数传递给它，这也是`shift`和`"$@"`的作用。

这里我们讨论打包（pack）操作，所以接下来将执行`$LKP_SRC/sbin/pack`脚本，并安排具体的操作。

这里脚本接受四个可选参数和一个必选参数，我们主要关注必选参数`<benchmark name>`。顾名思义，就是我们所需要打包的程序的名称，在项目内用变量`$BM_NAME`表示，同时用`$BM_ROOT`表示存放该Benchmark打包前的文件的目录。

```bash
#./sbin/pack
shift $(($OPTIND-1))
BM_NAME=$1;

[[ $BM_NAME ]] || usage
BM_ROOT=/lkp/benchmarks/$BM_NAME
```

接着进入打包的主要步骤，通过`source`两个文件，引入默认的步骤函数和自定义的步骤函数，并立即执行他们。由于前后顺序的不同，自定义的步骤函数会覆盖默认的步骤函数。

```bash
source $LKP_SRC/pack/default
source $LKP_SRC/pack/$BM_NAME

cd /tmp
download
build
install
pack_pkg $distro
```

所以步骤包括下载、编译、安装、打包四项，对应的也是四个函数，在default中包括了比较通用的方法，尤其是编译和打包由于差异比较小，一般都是使用默认的即可，而安装，需要指定哪些文件是运行必须的，所以一般来说需要各个Benchmark分别重写，而且下载步骤中的下载地址也需要给变量`$WEB_URL`赋值，两者合一也就形成了正常情况下的`$LKP_SRC/pack/`目录下对应不同测试用例名字的脚本文件。

值得一提的是打包步骤，如果没有指定`$distro`参数，那么按照一般的打包方式，会形成`.cgz`文件，使用的是`cpio <args> | gzip *.cgz`的命令形式，所以如果想要解压查看压缩包里的内容，使用反向的`gzip *.cgz | cpio <args>`类似的命令即可。

以上就是整个打包过程的细节描述。
