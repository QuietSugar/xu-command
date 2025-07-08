# shell-command

# 安装
```shell
chmod +x install_sh.sh
./install_sh.sh
```

将以下脚本内容加入你的配置文件中
`.profile`
`.bashrc` 适用于linux和安装了git-bash的windows
`.bash_profile` 专门针对git-bash 位于git安装目录中

```shell
# set user's private env if it exists
if [ -d "$HOME/.xu/env" ] ; then
  FILES=$(find "${HOME}/.xu/env" -name '*.sh' | sort)
  for FILE in $FILES; do
    source $FILE
  done
fi
```


# 原理说明

- 将脚本安装成命令

将一个脚本放进操作系统的环境变量中,那么就可以将脚本当做命令执行
> 事先将一个目录设置进PATH

- 将脚本安装成别名
> 需要手动加载,或者在系统启动时放进profile中

> 在 Windows 下面执行的时候需要使用`git-bash`执行

# 关于`.bat`脚本

> 如果 `.bat`脚本中包含中文(包含注释),那么文件的编码方式必须设置为`ANSI`,否则会有乱码,并且可能无法执行,或者可以改变默认字符集 `chcp 65001`

如果`.gitattribute`对于换行的配置没有生效,那么手动设置
git config --local core.autocrlf false



```
# macos 下使用COPYFILE_DISABLE去除._文件
COPYFILE_DISABLE=1 tar -czvf xu-command.tar.gz --exclude='.git' --exclude='.idea'  ./xu-command


```
