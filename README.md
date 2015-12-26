# lkp-analysis #

## 毕设题目
Linux 内核自动测试与动态差异分析研究

## 概述
保存针对LKP源码、运行结果的分析，并记录整个过程中遇到的问题。

## 流程
整个项目的流程是：

检测kernel更新 - 分发编译kernel - 用LKP测试一系列benchmark - 将结果与之前的结果进行比对，形成报告

目标是学习整个流程的细节，基础是复现整个流程，进一步针对安卓ROM替换不同kernel或者ROM相同kernel替换不同上层镜像能得到前后对比的分析报告。

去公司之前的目标是尽可能将LKP的代码弄熟弄透，各种命令尽量跑通。去公司之后，主要针对流程的其他部分进行学习，并且加强对报告分析部分的理解。

## 毕设目标
### 开题前：
- 写出当前的lkp-test设计分析报告
- 跑通lkp-test的简单实例
- 理解并写出lkp-test采集的linux kernel运行时状态信息分析
- **进阶要求：** 把kernel-ci搭建并运行起来

### 中期检查前：
- 可跑通＂检测kernel更新 - 分发编译kernel - 用LKP测试一系列benchmark - 将结果与之前的结果进行比对＂的整个流程
- 可搭建测试android系统的自动测试分析流程
- 开始进行数据挖掘的准备

### 进阶目标：
- 可对linux kernel的git数据和运行状态进行数据挖掘...

## 相关参考
- [Upstream Kernel Testing.pdf](http://elinux.org/images/f/ff/Kernelci.pdf)
- [Continuous integration for the Linux Kernel - Built within Docker](https://github.com/sanglt/kernel-ci)
- [LKP--Linux Kernel Performance](https://01.org/zh/lkp)
- [Automated Linux Kernel Testing](http://kernelci.org/)
- [Automated Linux Kernel Testing in GitHub](https://github.com/kernelci/)
- git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
