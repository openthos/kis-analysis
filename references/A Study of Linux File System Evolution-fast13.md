## 总结：

主要就是针对几个主流的文件系统，量化了一些分类指标，再进行对比分析。主要可参考之处在其如何进行分类，即文中的几个classification table，对于之后进行性能指标的设定和分析会比较有参考价值。


##主要内容：

有很多FS，主要是开源部分一直在进步，急速发展，可以期待会有更多通量。
但是很少有定量的理解。这很重要，对于提升设计，改进查找漏洞的工具。
Linux作为开源的代表，其FS的变动由于开源能十分清楚地获得，本文选取若干代表性的，进行分析。
对版本更新的分析，近50%是维护补丁，还有不到40%是修复bugs，其中语义bug（需要对fs语义有了解的）超过50%，属于普通bug检测系统很难找到的。其次是并发相关的bug，剩下的还有内存bug、代码错误bug等。
通过一个数据库，分析出了不同fs之间深层次的共同点

方法论：
抽取主要的几个FS，从三类问题进行分析回答：总体（补丁本身的特点），Bugs（哪些组件更容易出Bug），性能和稳定性（使用了哪些方法来提高）

This patch is classified as a bug (type=bug). The size is
1 (size=1) as one line of code is added. From the related
source file (super.c), we infer the bug belongs to Ext3’s
superblock management (data-structure=super). A null-
pointer access is a memory bug (pattern=memory,nullptr)
and can lead to a crash (consequence=crash).

**Patch Type**
Summary: Nearly half of total patches are for code
maintenance and documentation; a significant number of
bugs exist in not only new file systems, but also stable file
systems; all file systems make special efforts to improve
their performance and reliability; feature patches account
for a relatively small percentage of total patches.

**Patch Trend**
Summary: The patch percentages are relatively stable
over time; newer file systems (e.g., Btrfs) deviate occa-
sionally; bug patches do not diminish despite stability.

**Patch Size**
Summary: Bug patches are generally small; compli-
cated file systems have larger bug patches; reliability and
performance patches are medium-sized; feature patches
are significantly larger than other patch types.

**Correlation Between Code and Bugs**
对比bug数量和code数量，可以分析出哪些组分更加复杂容易出错（bug>code占比），对比不同FS也可以分析出相似和不同之处。
 the file, inode, and super bug较多。对应的IO、fsync path更多bug，inode和superblock频繁使用和更新，所以也更容易出错。
transactional code（原子操作，维护一致性的代码）更复杂，更容易出错。

Summary: The file, inode, and superblock components contain a disproportionally large number of bugs; transactional code is large and has a proportionate number of bugs; tree structures are not particularly error-prone, and should be used when needed without much worry.

**Bug Pattern**
Summary: Beyond maintenance, bug fixes are the
 most common patch type; over half of file-system bugs
 are semantic bugs, likely requiring domain knowledge to
 find and fix; file systems have a higher percentage of con-
 currency bugs compared with user-level software; mem-
 ory and error code bugs arise but in smaller percentages.

**Bug Trends**
Summary: Bug patterns do not change significantly
 over
 time, increasing and decreasing cyclically; large de-
 viations
 arise due to major structural changes.

**Bug Consequences**
Summary: File system bugs cause severe conse-
quences; corruptions and crashes are most common;
wrong behavior is uncommon; semantic bugs can lead
to significant amounts of corruptions, crashes, errors, and
hangs; all bug types have severe consequences.

