## 自定义打包步骤函数

接上一节的内容，由于我们最关心的便是如何添加新的Benchmark，所以如何撰写新的步骤函数脚本，在这里详细说明。

一个简单的模板如下所示（`$LKP_SRC/pack/nbench`）：

```bash
#!/bin/bash

# two basic VARIABLEs
VERSION="2.2.3"
WEB_URL="http://www.tux.org/~mayer/linux/nbench-byte-${VERSION}.tar.gz"

# install() function, used when download benchmark
install()
{
    cp -af $BM_NAME $BM_ROOT
    cp -af *.DAT $BM_ROOT
}
```

可见正如上一节所说，分为两部分：一部分是下载所需的一个变量`$WEB_URL`，这里还多加了一个版本变量便于日后修改；另一部分是安装步骤函数，指定了两类文件，与Benchmark同名的可执行文件以及后缀名为`.DAT`的数据文件，这便是运行nbench这个Benchmark所需的文件。

总的来说想要撰写新的步骤函数脚本，首先需要了解如何直接运行这个Benchmark，了解如何编译它，了解哪些文件是必需的，所以说需要针对不同的Benchmark对症下药。
