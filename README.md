# lkp-analysis #

保存针对LKP源码、运行结果的分析，并记录整个过程中遇到的问题。

整个项目的流程是：

检测kernel更新 - 分发编译kernel - 用LKP测试一系列benchmark - 将结果与之前的结果进行比对，形成报告

目标是学习整个流程的细节，基础是复现整个流程，进一步针对安卓ROM替换不同kernel或者ROM相同kernel替换不同上层镜像能得到前后对比的分析报告。

去公司之前的目标是尽可能将LKP的代码弄熟弄透，各种命令尽量跑通。去公司之后，主要针对流程的其他部分进行学习，并且加强对报告分析部分的理解。