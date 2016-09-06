
conda 集成了包管理和虚拟环境为一体，十分好用。
以后逐渐开始用使用 conda 而非 pip。

| 任务 | 命令 |
|:----:|:----:|
| 安装包 | conda install $PACKAGE_NAME |
| 更新包 | conda update --name $ENVIRONMENT_NAME $PACKAGE_NAME |
| 更新包管理 | conda update conda |
| 删除包 | conda remove --name $ENVIRONMENT_NAME $PACKAGE_NAME |
| 创建环境 | conda create --name $ENVIRONMENT_NAME python |
| 激活环境 | source activate $ENVIRONMENT_NAME |
| 退出环境 | source deactivate |
| 搜索可用的包 | conda search $SEARCH_TERM |
| 从特殊的源安装包 | conda install --channel $URL $PACKAGE_NAME |
| 列出安装的包 | conda list --name $ENVIRONMENT_NAME |
| 创建需求文件 | conda list --export |
| 列出所有环境 | conda info --envs |
| 安装 python | conda install python=x.x |
| 更新 python | conda update python * |

