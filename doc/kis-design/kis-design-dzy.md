# KIS 设计架构

同 chyyuu 想法, KIS 包含一系列微服务.
微服务能被部署到不同的机器上.
微服务应当运行在隔离的容器 (docker, chroot) 中.
下面叙述所有微服务及其关系.

用 job 表示一个正在运行的微服务.

*斜体* 表示一个微服务.

## 获取:
* 输入: 无
* 触发: 周期性轮讯
* 参数: tree (repo remote url), branch
* 输出: 一系列 patch (不一定要这个格式, 意思)

```
获取<tree, branch>: 微服务
    周期性地轮讯:
        repo 远端 head sha1 是否和本地一致?
        获取远端的更新
```

## 配置
* 输入: *获取* 微服务输出的 *一个* patch, 以及对应的 tree 和 branch
* 触发: 被 *获取* 触发. 一个 *获取* job 输出的每个 patch 都可以对应创建一个 *配置*.
* 参数: patch, tree, branch
* 输出: 一个配置好的内核

其他
* KIS 原来是一般随机配置, 一半手选配置
  - 想法: 可以 tuning? 以提高 coverage? (但是 coverage 真的是有效的指标吗)

疑问
* **什么叫配置**?
  - arch, device, dotconfig
  - 分析目标: 静态? 动态?

## 静态分析
静态分析不是一个微服务, 而是一个 '抽象微服务' 或者 '微服务模式'.

每种静态分析 (sparse, kint, dsac ...) 都是一个具体的微服务.

* 输入: 配置好的内核代码
* 触发: 被 *配置* 触发.
* 参数: tree branch.
* 输出: 分析结果 (是一个数据结构, 例如文本串)

## 编译
* 输入: 配置好的内核代码
* 触发: 被 *配置* 触发
* 参数: tree branch arch device
* 输出: 一个构建好的 kernel image, 或者编译错误信息

一个 kernel image 可能会被不同的动态运行使用 (perfbench, stress, fuzz ...)


## 动态运行
动态运行也是 '微服务模式'.

* 输入: 构建好的 kernel image
* 触发: 被 *编译* 触发
* 参数: tree branch arch device
* 输出: 运行结果 (类似 *静态分析* 的分析结果)

动态运行可能对机器有依赖: 机器的 arch 要和参数 arch 匹配.

动态运行可能其他依赖文件 i.e. kis-design 中的 '打包', 这些可以开一个单独的存储微服务, 每次从存储微服务请求里面. 也可以直接配置完打包.

如果动态运行严重出错, 破坏了 VM 或者 kernel panic, 需要 scheduler 恢复 (c.f. Autoconf).

包含多个阶段
* setup
* run

分为多种情况
* 虚拟化
* 真机: TODO PXE 等

job 的声明可以仿照 autotest, 用一个可执行文件 (python / bash) 来指定.

## 信息分析
是我们的关键, 但是具体怎么做还不确定.

理论上每种静态分析和动态运行都应当有它自己的信息分析模块.

本质上是将输入的分析结果进行变换, 去除 false positive 等无用信息.

可能还需要对比历史上的信息.

* 输出:
  - 错误
  - 正常
  - 效率下降

## 错误定位报告
可能利用数据挖掘等方法, 从 log / output 中抓取出错误信息.
并且完成 email author.

bisect 等工作也被这个完成.

## 调度器
scalability 的关键. 中心化的.

* 机器运行 job. 当 job 完成后, 有多种可能
  - 没有接下来的 job 了: 给 scheduler 发送信息: '此机器可用'
  - 接下来有 job 但是只用一台机器: 不妨直接在同一台机器上运行
  - 接下来需要多台机器: 向 scheduler 请求机器

* 另外, 发起 job 也是通过告知 scheduler 来完成的.

另外, scheduler 还应当处理微服务失败. 微服务失败则执行 repair 或者 restart.


------------------------------------------------------------------------------
# 其他元信息和想法
KIS 希望达到的五个指标是

* [D]iverse: 支持多样的 config
* [I]nstant: 即时测试 (hour level)
* bug [R]reporting: bug 定位和报告
* [A]anlysis: 对编译, 静态分析, 运行, 动态测试得到的信息做分析
* [S]calability 分布式多机可拓展性

除此之外还有

* 容易使用

那么就有如下表格

|          | D   | I   | R   | A   | S   |
| ---      | --- | --- | --- | --- | --- |
| KIS      | ✔️   | ✔️   | ✔️   | ✔️   | ✔️   |
| autotest | ✔️   | ❌  | ❌  | ❌  | ✔️   |


## 优化相关
* 编译可以用 distcc 和 ccache
* 各个阶段有很多共享的东西 eg 内核源代码
* 容器之间如何快速通信 e.g. 发送 kernel image
* 如果需要多机的测试 (存在吗?) 类似 autotest
