## 相关文件

本地运行：
```bash
bin/lkp
├── bin/run-local
│ ├── lib/yaml.rb
│ │ ├── lib/common.rb
│ │ ├── lib/error
│ ├── lib/stats.rb
│ ├── lib/matrix.rb
│ ├── lib/job2sh.rb
│ ├── lib/job.rb
│ │ ├── lib/common.rb
│ │ ├── lib/result.rb
│ ├── /$result_root/job.sh
│ │ ├── lib/job.sh
│ │ ├── lib/env.sh
│ │ ├── monitors/event/wait
│ │ ├── monitors/event/wakeup
│ │ ├── monitors/wrapper
│ │ ├── tests/wrapper
│ │ ├── stats/wrapper
│ ├── bin/postrun
│ ├── sbin/unite-params
```

虚拟机运行：
```bash
bin/lkp
├── bin/run-qemu
│ ├── lib/yaml.rb
│ │ ├── lib/common.rb
│ │ ├── lib/error
│ ├── lib/stats.rb
│ ├── lib/matrix.rb
│ ├── lib/job2sh.rb
│ ├── lib/job.rb
│ │ ├── lib/common.rb
│ │ ├── lib/result.rb
│ ├── /$result_root/job.sh
│ │ ├── lib/job.sh
│ │ ├── lib/env.sh
│ │ ├── monitors/event/wait
│ │ ├── monitors/event/wakeup
│ │ ├── monitors/wrapper
│ │ ├── tests/wrapper
│ │ ├── stats/wrapper
│ ├── lkp-exec/qemu
│ │ ├── lib/kexec.sh
│ │ ├── lib/qemu.sh
│ │ ├── lib/unit.sh
│ │ ├── lib/job-init.sh
│ ├── sbin/unite-params
```
