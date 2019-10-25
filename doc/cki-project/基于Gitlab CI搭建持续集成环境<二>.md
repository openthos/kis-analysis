#  GitLab-CI与GitLab-Runner

## GitLab-CI
GitLab-CI就是一套配合GitLab使用的持续集成系统（当然，还有其它的持续集成系统，同样可以配合GitLab使用，比如Jenkins）。而且GitLab8.0以后的版本是默认集成了GitLab-CI并且默认启用的。

## GitLab-Runner
GitLab-Runner是配合GitLab-CI进行使用的。一般地，GitLab里面的每一个工程都会定义一个属于这个工程的软件集成脚本，用来自动化地完成一些软件集成工作。当这个工程的仓库代码发生变动时，比如有人push了代码，GitLab就会将这个变动通知GitLab-CI。这时GitLab-CI会找出与这个工程相关联的Runner，并通知这些Runner把代码更新到本地并执行预定义好的执行脚本。

所以，GitLab-Runner就是一个用来执行软件集成脚本的东西。你可以想象一下：Runner就像一个个的工人，而GitLab-CI就是这些工人的一个管理中心，所有工人都要在GitLab-CI里面登记注册，并且表明自己是为哪个工程服务的。当相应的工程发生变化时，GitLab-CI就会通知相应的工人执行软件集成脚本。如下图所示：
![Image text](https://upload-images.jianshu.io/upload_images/525728-4339103186d2b1c9.png?imageMogr2/auto-orient/strip|imageView2/2/w/550/format/webp)
Runner可以分布在不同的主机上，同一个主机上也可以有多个Runner。

## Runner类型
GitLab-Runner可以分类两种类型：Shared Runner（共享型）和Specific Runner（指定型）。

- Shared Runner：这种Runner（工人）是所有工程都能够用的。只有系统管理员能够创建Shared Runner。

- Specific Runner：这种Runner（工人）只能为指定的工程服务。拥有该工程访问权限的人都能够为该工程创建Shared Runner。

## GitLab-Runner的安装与使用
参照官网的安装步骤即可：
https://gitlab.com/gitlab-org/gitlab-ci-multi-runner

## 使用gitlab-ci-multi-runner注册Runner
安装好gitlab-ci-multi-runner这个软件之后，我们就可以用它向GitLab-CI注册Runner了。

向GitLab-CI注册一个Runner需要两样东西：GitLab-CI的url和注册token。
其中，token是为了确定你这个Runner是所有工程都能够使用的Shared Runner还是具体某一个工程才能使用的Specific Runner。

如果要注册Shared Runner，你需要到管理界面的Runners页面里面去找注册token。如下图所示：

![Image text](https://upload-images.jianshu.io/upload_images/525728-e4141cc2a2d4f986.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

如果要注册Specific Runner，你需要到项目的设置的Runner页面里面去找注册token。如下图所示：

![Image text](https://upload-images.jianshu.io/upload_images/525728-bc5f1e385c2beb45.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

找到token之后，运行下面这条命令注册Runner（当然，除了url和token之外，还需要其他的信息，比如执行器executor、构建目录builds_dir等）。
```
sudo  gitlab-ci-multi-runner register
```
- 输入Gitlab CI地址, (e.g. https://gitlab.com/)
- 输入项目CI token
- 输入 Runner 描述（e.g. Test for CI  测试runner）
- 输入 Runner 标签，可以多个，用逗号隔开（e.g. mdx,tinghua）
- 输入 Runner 执行的语言 (e.g. shell)
如下图：
![Image text](https://github.com/openthos/community-analysis/blob/master/Daily%20Report/cki-runner-register.png)

注册完成之后，GitLab-CI就会多出一条Runner记录，如下图所示：
![Image text](https://github.com/openthos/community-analysis/blob/master/Daily%20Report/test.png)

## 让注册好的Runner运行起来
Runner注册完成之后还不行，还必须让它运行起来，否则它无法接收到GitLab-CI的通知并且执行软件集成脚本。怎么让Runner运行起来呢？gitlab-ci-multi-runner提供了这样一条命令:
```
sudo gitlab-ci-multi-runner  start
```
