# KIS 设计架构

同 chyyuu 想法, KIS 包含一系列微服务.
微服务能被部署到不同的机器上.
下面叙述所有微服务及其关系.

## 获取:
* 输入: 无
* 触发: 周期性轮讯
* 参数: repo remote url, branch
* 输出: 一系列 patch (不一定要这个格式, 意思)

```
获取<repo, branch>: 微服务
    周期性地轮讯:
        repo 远端 head sha1 是否和本地一致?
        获取远端的更新
```

## 配置
* KIS 原来是一般随机配置, 一半手选配置
  - 可以 tuning?

## 静态分析

## 动态运行
包含多个阶段
* setup
* run

分为多种情况
* 虚拟化
* 真机: TODO PXE 等

## 信息分析
是我们的关键, 但是具体怎么做还不确定.

## 错误定位报告
可能利用数据挖掘等方法, 从 log / output 中抓取出错误信息.
并且完成 email author.

bisect 等工作也被这个完成.

## 调度器
scalability 的关键.



# 其他元信息
KIS 希望达到的五个指标是

* **[D]**iverse: 支持多样的 config
* **[I]**nstant: 即时测试 (hour level)
* bug **[R]**reporting: bug 定位和报告
* **[A]**anlysis: 对编译, 静态分析, 运行, 动态测试得到的信息做分析
* **[S]**calability 分布式多机可拓展性

除此之外还有

* 容易使用

那么就有如下表格

|          | D   | I   | R   | A   | S   |
| ---      | --- | --- | --- | --- | --- |
| KIS      | ✔️   | ✔️   | ✔️   | ✔️   | ✔️   |
| autotest | ✔️   | ❌  | ❌  | ❌  | ✔️   |
