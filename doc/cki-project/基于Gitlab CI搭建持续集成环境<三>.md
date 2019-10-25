# 创建.gitlab-ci.yml
##  .gitlab-ci.yml 文件是什么
  .gitlab-ci.yml 用来配置 CI 用你的项目中做哪些操作，这个文件位于仓库的根目录。

  配置好 Runner 之后，我们要做的事情就是在项目根目录中添加 .gitlab-ci.yml 文件了。 当我们添加了 .gitlab-ci.yml 文件后，每次提交代码或者合并 MR 都会自动运行构建任务了。

  还记得 Pipeline 是怎么触发的吗？Pipeline 也是通过提交代码或者合并 MR 来触发的！ 那么 Pipeline 和 .gitlab-ci.yml 有什么关系呢？ 其实 .gitlab-ci.yml 就是在定义 Pipeline 而已！

  当有新内容push到仓库后，GitLab会查找是否有.gitlab-ci.yml文件，如果文件存在， Runners 将会根据该文件的内容开始build 本次commit。

## 基本语法
```
# 定义 stages
stages:
  - build
  - test

# 定义 job
job1:
  stage: test
  script:
    - echo "I am job1"
    - echo "I am in test stage"

# 定义 job
job2:
  stage: build
  script:
    - echo "I am job2"
    - echo "I am in build stage"
```
用 stages 关键字来定义 Pipeline 中的各个构建阶段，然后用一些非关键字来定义 jobs。 每个 job 中可以可以再用 stage 关键字来指定该 job 对应哪个 stage。 job 里面的 script 关键字是最关键的地方了，也是每个 job 中必须要包含的，它表示每个 job 要执行的命令。
根据我们在 stages 中的定义，build 阶段要在 test 阶段之前运行，所以 stage:build 的 jobs 会先运行，之后才会运行 stage:test 的 jobs。

详尽的内容请前往 [官方文档](http://docs.gitlab.com/ce/ci/yaml/README.html)
