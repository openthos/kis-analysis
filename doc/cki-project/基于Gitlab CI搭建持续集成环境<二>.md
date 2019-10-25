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
或者使用强大的命令gitlab-ci-multi-runner run-single，详情如下：
```
# gitlab-ci-multi-runner run-single --help
NAME:
   run-single - start single runner

USAGE:
   command run-single [command options] [arguments...]

OPTIONS:
   --name, --description   Runner name [$RUNNER_NAME]
   --limit     Maximum number of builds processed by this runner [$RUNNER_LIMIT]
   --ouput-limit    Maximum build trace size [$RUNNER_OUTPUT_LIMIT]
   -u, --url     Runner URL [$CI_SERVER_URL]
   -t, --token     Runner token [$CI_SERVER_TOKEN]
   --tls-ca-file    File containing the certificates to verify the peer when using HTTPS [$CI_SERVER_TLS_CA_FILE]
   --executor     Select executor, eg. shell, docker, etc. [$RUNNER_EXECUTOR]
   --builds-dir    Directory where builds are stored [$RUNNER_BUILDS_DIR]
   --cache-dir     Directory where build cache is stored [$RUNNER_CACHE_DIR]
   --env     Custom environment variables injected to build environment [$RUNNER_ENV]
   --shell     Select bash, cmd or powershell [$RUNNER_SHELL]
   --ssh-user     User name [$SSH_USER]
   --ssh-password    User password [$SSH_PASSWORD]
   --ssh-host     Remote host [$SSH_HOST]
   --ssh-port     Remote host port [$SSH_PORT]
   --ssh-identity-file    Identity file to be used [$SSH_IDENTITY_FILE]
   --docker-host    Docker daemon address [$DOCKER_HOST]
   --docker-cert-path    Certificate path [$DOCKER_CERT_PATH]
   --docker-tlsverify    Use TLS and verify the remote [$DOCKER_TLS_VERIFY]
   --docker-hostname    Custom container hostname [$DOCKER_HOSTNAME]
   --docker-image    Docker image to be used [$DOCKER_IMAGE]
   --docker-privileged   Give extended privileges to container [$DOCKER_PRIVILEGED]
   --docker-disable-cache   Disable all container caching [$DOCKER_DISABLE_CACHE]
   --docker-volumes    Bind mount a volumes [$DOCKER_VOLUMES]
   --docker-cache-dir    Directory where to store caches [$DOCKER_CACHE_DIR]
   --docker-extra-hosts   Add a custom host-to-IP mapping [$DOCKER_EXTRA_HOSTS]
   --docker-links    Add link to another container [$DOCKER_LINKS]
   --docker-services    Add service that is started with container [$DOCKER_SERVICES]
   --docker-wait-for-services-timeout  How long to wait for service startup [$DOCKER_WAIT_FOR_SERVICES_TIMEOUT]
   --docker-allowed-images   Whitelist allowed images [$DOCKER_ALLOWED_IMAGES]
   --docker-allowed-services   Whitelist allowed services [$DOCKER_ALLOWED_SERVICES]
   --docker-image-ttl     [$DOCKER_IMAGE_TTL]
   --parallels-base-name   VM name to be used [$PARALLELS_BASE_NAME]
   --parallels-template-name   VM template to be created [$PARALLELS_TEMPLATE_NAME]
   --parallels-disable-snapshots  Disable snapshoting to speedup VM creation [$PARALLELS_DISABLE_SNAPSHOTS]
   --virtualbox-base-name   VM name to be used [$VIRTUALBOX_BASE_NAME]
   --virtualbox-disable-snapshots  Disable snapshoting to speedup VM creation [$VIRTUALBOX_DISABLE_SNAPSHOTS]

```
要让一个Runner运行起来，--url、--token和--executor选项是必要的。其他选项可根据具体情况和需求进行设置。这个命令运行起来的前提是，GitLab-CI中必须事先注册有这个Runner。
