#!/bin/bash

## @version:		1.1.2

## @description:
# ====================================================
#   针对 git clone 的封装
#	  请事先做好账户认证,需要在执行git clone的情况下不需要输入用户名和密码
#   配置文件地址: $HOME/.xu/config/gitclone
#   GIT_CLONE_CALL_BIN:
#           表示下载完毕之后执行的命令,参数是项目的文件夹,
#           例如: GIT_CLONE_CALL_BIN=explorer 表示打开文件夹,这个在Windows下有效
# ====================================================

# set -e

cloneUrl=$1
callBin=$2

# check
# 设置基础目录
if [ ! -n "$cloneUrl" ]; then
  echo '参数错误,请输入git url'
  exit 0
fi
set -e
# 加载环境变量
source load_config git-plus


local_git_repo_path=$(get_git_repo_path)


# --------->>>>>>>>>>> 准备基础目录完毕

# 优先使用命令行后跟着的,如果命令行中未设置,尝试从配置文件中读取
if [ ! -n "$callBin" ]; then
  callBin="$GIT_CLONE_CALL_BIN"
fi

#cloneUrl=$(echo "$cloneUrl" | sed 's#https://ghproxy.com/##')
# 删除前缀和后缀
if [[ "$cloneUrl" =~ ^https://.* ]]; then
  #echo "[ xu -> ] https url"
  project_dir=$(echo "$cloneUrl" | sed 's#https://##' | sed 's/.git//g')
elif [[ "$cloneUrl" =~ ^http://.* ]]; then
  #echo "[ xu -> ] http url"
  project_dir=$(echo "$cloneUrl" | sed 's#http://##' | sed 's/.git//g')
elif [[ "$cloneUrl" =~ ^git@.* ]]; then
  #echo "[ xu -> ] git ssh url"
  project_dir=$(echo "$cloneUrl" | sed 's#git@##' | sed 's/.git//g' | sed 's#:#/#')
else
  echo "[ xu -> ] error url"
  exit 0
fi

project_name=$(echo ${project_dir##*/} )
git_clone_to_dir=${project_dir%/*}
# 替换路径中的冒号(windows不支持该字符)
git_clone_to_dir=$(echo "$git_clone_to_dir" | sed 's#:#_#')
absolute_project_dir="$local_git_repo_path/$git_clone_to_dir"

if [ ! -d "$absolute_project_dir" ]; then
  mkdir -p "$absolute_project_dir"
fi
if [ ! -d "$absolute_project_dir/$project_name" ]; then
  cd "$absolute_project_dir"
  git clone  $cloneUrl
else
  echo "[ xu -> ] 已存在,跳过clone"
fi

# 输出日志
echo "[ xu -> ] project_name         :$project_name"
echo "[ xu -> ] git_clone_to_dir     :$git_clone_to_dir"
echo "[ xu -> ] project_dir          :$project_dir"
echo "[ xu -> ] absolute_project_dir :$absolute_project_dir"

if [ ! -n "$callBin" ]; then
  exit 0
fi

cd "$absolute_project_dir/$project_name"
echo "[ xu -> ] run $callBin ."
$callBin "."



