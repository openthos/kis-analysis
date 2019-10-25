# 基于Gitlab CI搭建持续集成环境
本文简单介绍了持续集成的概念并着重介绍了如何基于 Gitlab CI 快速构建持续集成环境，主要介绍了 Gitlab CI 的基本功能和入门操作流程。

本文提到的 Gitlab 版本为 8.x ，新版的 Gitlab 界面可能会有所不同

##  什么是持续集成？
持续集成（Continuous Integration，简称CI）指的是，频繁地（一天多次）将代码集成到主干。
![Image text](https://upload-images.jianshu.io/upload_images/64173-0f610cc3507dc987.png?imageMogr2/auto-orient/strip|imageView2/2/w/1168/format/webp)
##  持续集成的好处主要有两个:
- 快速发现错误
每完成一点更新，就集成到主干，可以快速发现错误，定位错误也比较容易
-  防止分支大幅偏离主干
如果不是经常集成，主干又在不断更新，会导致以后集成的难度变大，甚至难以集成。持续集成的目的，就是让产品可以快速迭代，同时还能保持高质量。它的核心措施是，代码集成到主干之前，必须通过自动化测试。只要有一个测试用例失败，就不能集成。

## 持续交付、持续部署的概念
持续交付（Continuous delivery）指的是，频繁地将软件的新版本，交付给质量团队或者用户，以供评审。如果评审通过，代码就进入生产阶段。

持续部署（continuous deployment）是持续交付的下一步，指的是代码通过评审以后，自动部署到生产环境。
![Image text](https://upload-images.jianshu.io/upload_images/64173-b5921de034a8db7e.png?imageMogr2/auto-orient/strip|imageView2/2/w/600/format/webp)
## 持续集成的原则
业界普遍认同的持续集成的原则包括：

- 需要版本控制软件保障团队成员提交的代码不会导致集成失败。常用的版本控制软件有 git、svn 等；
- 开发人员必须及时向版本控制库中提交代码，也必须经常性地从版本控制库中更新代码到本地；
- 需要有专门的集成服务器来执行集成构建。根据项目的具体实际，集成构建可以被软件的修改来直接触发，也可以定时启动，如每半个小时构建一次；
- 必须保证构建的成功。如果构建失败，修复构建过程中的错误是优先级最高的工作。一旦修复，需要手动启动一次构建。

## 持续集成系统的组成
由此可见，一个完整的构建系统必须包括：

- 一个自动构建过程，包括自动编译、分发、部署和测试等。
- 一个代码存储库，即需要版本控制软件来保障代码的可维护性，同时作为构建过程的素材库。
- 一个持续集成服务器。

##  GitLab CI介绍
![Image text](https://upload-images.jianshu.io/upload_images/64173-444f3b7a2f88eba4.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

GitLab CI是 GitLab 提供的持续集成服务，只要在你的仓库根目录 创建一个.gitlab-ci.yml 文件， 并为该项目指派一个Runner，当有合并请求或者 push的时候就会触发build。

这个.gitlab-ci.yml 文件定义GitLab runner要做哪些操作。 默认有3个[stages(阶段)]: build、test、deploy。

当build完成后(返回非零值)，你会看到push的 commit或者合并请求前面出现一个绿色的对号。 这个功能很方便的让你检查出来合并请求是否会导致build失败， 免的你去检查代码。

大部分项目用GitLab's CI服务跑build测试， 开发者会很快得到反馈，知道自己是否写出了BUG。

所以简单的说，要让CI工作可总结为以下几点:

- 在仓库根目录创建一个名为.gitlab-ci.yml 的文件
- 为该项目配置一个Runner
完成上面的步骤后，每次push代码到Git仓库， Runner就会自动开始pipeline。

## 一些概念
### Pipeline
一次 Pipeline 其实相当于一次构建任务，里面可以包含多个流程，如安装依赖、运行测试、编译、部署测试服务器、部署生产服务器等流程。 任何提交或者 Merge Request 的合并都可以触发 Pipeline，如下图所示：
```
+------------------+           +----------------+
|                  |  trigger  |                |
|   Commit / MR    +---------->+    Pipeline    |
|                  |           |                |
+------------------+           +----------------+
```

### Stages
Stages 表示构建阶段，说白了就是上面提到的流程。 我们可以在一次 Pipeline 中定义多个 Stages，这些 Stages 会有以下特点：

- 所有 Stages 会按照顺序运行，即当一个 Stage 完成后，下一个 Stage 才会开始
- 只有当所有 Stages 完成后，该构建任务 (Pipeline) 才会成功
- 如果任何一个 Stage 失败，那么后面的 Stages 不会执行，该构建任务 (Pipeline) 失败
因此，Stages 和 Pipeline 的关系就是：
```
+--------------------------------------------------------+
|                                                        |
|  Pipeline                                              |
|                                                        |
|  +-----------+     +------------+      +------------+  |
|  |  Stage 1  |---->|   Stage 2  |----->|   Stage 3  |  |
|  +-----------+     +------------+      +------------+  |
|                                                        |
+--------------------------------------------------------+
```

### Jobs
Jobs 表示构建工作，表示某个 Stage 里面执行的工作。 我们可以在 Stages 里面定义多个 Jobs，这些 Jobs 会有以下特点：

- 相同 Stage 中的 Jobs 会并行执行
- 相同 Stage 中的 Jobs 都执行成功时，该 Stage 才会成功
- 如果任何一个 Job 失败，那么该 Stage 失败，即该构建任务 (Pipeline) 失败
所以，Jobs 和 Stage 的关系图就是：
```
+------------------------------------------+
|                                          |
|  Stage 1                                 |
|                                          |
|  +---------+  +---------+  +---------+   |
|  |  Job 1  |  |  Job 2  |  |  Job 3  |   |
|  +---------+  +---------+  +---------+   |
|                                          |
+------------------------------------------+
```
### GitLab Runner
理解了上面的基本概念之后，有没有觉得少了些什么东西 —— 由谁来执行这些构建任务呢？ 答案就是 GitLab Runner 了！

想问为什么不是 GitLab CI 来运行那些构建任务？ 一般来说，构建任务都会占用很多的系统资源 (譬如编译代码)，而 GitLab CI 又是 GitLab 的一部分，如果由 GitLab CI 来运行构建任务的话，在执行构建任务的时候，GitLab 的性能会大幅下降。

GitLab CI 最大的作用是管理各个项目的构建状态，因此，运行构建任务这种浪费资源的事情就交给 GitLab Runner 来完成！ 因为 GitLab Runner 可以安装到不同的机器上，所以在构建任务运行期间并不会影响到 GitLab 的性能！

GitLab-CI与GitLab-Runner的关系，请参照[基于Gitlab CI搭建持续集成环境<二>](https://github.com/openthos/kis-analysis/blob/master/doc/cki-project/%E5%9F%BA%E4%BA%8EGitlab%20CI%E6%90%AD%E5%BB%BA%E6%8C%81%E7%BB%AD%E9%9B%86%E6%88%90%E7%8E%AF%E5%A2%83%3C%E4%BA%8C%3E.md)
