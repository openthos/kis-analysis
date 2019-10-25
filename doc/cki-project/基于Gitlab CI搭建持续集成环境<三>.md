# 创建.gitlab-ci.yml
##  .gitlab-ci.yml 文件是什么
.gitlab-ci.yml 用来配置 CI 用你的项目中做哪些操作，这个文件位于仓库的根目录。

当有新内容push到仓库后，GitLab会查找是否有.gitlab-ci.yml文件，如果文件存在， Runners 将会根据该文件的内容开始build 本次commit。
