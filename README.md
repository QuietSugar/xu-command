# xu-command

```bash
# 安装
curl -fsSL https://raw.githubusercontent.com/QuietSugar/xu-command/refs/heads/debug/install.sh | sudo bash

# 卸载
curl -fsSL https://raw.githubusercontent.com/QuietSugar/xu-command/refs/heads/debug/install.sh | sudo bash -s -- uninstall
```

将以下脚本内容加入你的配置文件中
- `.profile`
- `.bashrc` 适用于linux和安装了git-bash的windows
- `.bash_profile` 专门针对git-bash 位于git安装目录中

```shell
# set user's private env if it exists
if [ -d "$HOME/.xu-command/source" ]; then
  while IFS= read -r -d '' FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.xu-command/source" -name '*.sh' -print0 | sort -z)
fi
```


# 说明

- 将脚本安装成命令 command

将一个脚本放进操作系统的环境变量中,那么就可以将脚本当做命令执行
> 事先将一个目录设置进PATH

- 将脚本安装成别名 source
> 需要手动加载,或者在系统启动时放进profile中

# 注意

- 在 Windows 下面执行的时候需要使用`git-bash`执行

