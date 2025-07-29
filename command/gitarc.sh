#!/bin/bash
# ====================================================
#   @version:		1.0.0
#   遍历寻找目录下所有带 .git的目录,
#	将它归档到 固定目录中
#
# ====================================================

. $(dirname "$0")/lib/init.sh

LOG_LEVEL_STDOUT="INFO"

set -e
# 基准目录(也就是扫描的根目录)
if [ $# -eq 0 ]; then
    SOURCE_BASE_ABS_PATH=$(realpath .)
    log_success "此次操作当前目录: "$SOURCE_BASE_ABS_PATH
else
    SOURCE_BASE_ABS_PATH=$(realpath $1)
    log_success "此次操作指定目录: "$SOURCE_BASE_ABS_PATH
fi

# 检查目录是否存在
if [ ! -d "$SOURCE_BASE_ABS_PATH" ]; then
    log_error "Error: 目录 $SOURCE_BASE_ABS_PATH 不存在"
    exit 1
fi
# 目标基础目录
TARGET_BASE_ABS_PATH="$HOME/git-repo"
if [ ! -d "$TARGET_BASE_ABS_PATH" ]; then
    mkdir -p "$TARGET_BASE_ABS_PATH"
fi

# 查找所有.git目录的函数
find_git_dirs() {
    if [ $# -eq 0 ]; then
        log_error "请传入参数!"
        exit 1
    fi
    local this_dir="$1"
    # 检查当前目录是否有.git子目录
    if [ -d "$this_dir/.git" ]; then
        log_debug "【原始】绝对路径: "$this_dir
        move_git_dir "$this_dir"
        log_success ""
        return
    fi

    # 遍历当前目录的所有子目录
    for subdir in "$this_dir"/*; do
        # 如果是目录且不是符号链接（避免循环）
        if [ -d "$subdir" ] && [ ! -L "$subdir" ]; then
            find_git_dirs "$subdir"
        fi
    done
}
move_git_dir() {
    # eg /base/a/b/c
    local source_abs_dir=$1
    # eg /base/a/b/c/.git
    local source_dot_git_abs_dir="$source_abs_dir/.git"
    # eg /a/b/c
    local git_relative_dir=$(echo "${source_abs_dir}" | sed "s#$SOURCE_BASE_ABS_PATH##")
    # eg http://1.2.3.4/a/b/c.git
    local cloneUrl=$(git --git-dir=${source_dot_git_abs_dir} config --get remote.origin.url)
    is_git_url_https_ssh $cloneUrl
    #替换
    project_dir=$(make_filename_safe $cloneUrl)
    log_debug "【目标】项目相对路径:  $project_dir"
    # eg c
    project_name=$(echo ${project_dir##*/})
    log_debug "【目标】项目名称:  $project_name"
    # 不带前缀和后缀的 git url eg 1.2.3.4/a/b/c
    git_clone_to_dir=${project_dir%/*}
    # 替换路径中的冒号(windows不支持该字符)
    git_clone_to_dir=$(echo "$git_clone_to_dir" | sed 's#:#_#')
    log_debug "【目标】所在目录相对路径:  $git_clone_to_dir"
    absolute_project_dir="$TARGET_BASE_ABS_PATH/$git_clone_to_dir"
    log_debug "【目标】所在目录绝对路径:  $absolute_project_dir"

    if [ ! -d "$absolute_project_dir" ]; then
        mkdir -p "$absolute_project_dir"
    fi
    local new_path=$absolute_project_dir/$project_name
    log_debug "【new_pathnew_pathnew_pathnew_path:  $new_path"
    if [ ! -d "$new_path" ]; then
        # 使用mv实现移动和重命名
        log_debug "从:              $source_abs_dir"
        log_debug "移动并重命名为   $new_path"
        mv -v "$source_abs_dir" "$new_path"
    else
        log_warning "目录已存在已存在,无法移动"$new_path
    fi
}

# 规范化文件名 尽量使得三端都支持
function make_filename_safe() {
    local dirPath="$1"
    # 去除前后空白（-e 执行多个编辑命令）
    local dirPath=$(echo "$dirPath" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    # 去除特定前缀
    dirPath="${dirPath#https://gh-proxy.com/}"
    dirPath="${dirPath#https://}"
    dirPath="${dirPath#http://}"
    dirPath="${dirPath#git@}"

    # 将所有冒号替换为斜杠
    dirPath="${dirPath//:/\/}"

    # 去除末尾的.git
    dirPath="${dirPath%.git}"

    echo "$dirPath"
}

# 判断字符串是否为 HTTPS/HTTP 或 SSH 协议的有效 Git 地址（支持端口和 IP）
is_git_url_https_ssh() {
    local url="$1"
    # 正则表达式：
    # 1. HTTPS/HTTP：支持域名/IP + 可选端口 + 路径 + 可选.git后缀
    # 2. SSH：支持用户名@域名/IP + 可选端口 + 路径 + 可选.git后缀
    local git_regex='^(https?)://([a-zA-Z0-9.-]+|([0-9]{1,3}\.){3}[0-9]{1,3})(:[0-9]{1,5})?(/[a-zA-Z0-9._/-]+)*(\.git)?$|^[a-zA-Z0-9._-]+@([a-zA-Z0-9.-]+|([0-9]{1,3}\.){3}[0-9]{1,3})(:[0-9]{1,5})?:[a-zA-Z0-9._/-]+(\.git)?$'

    if [[ "$url" =~ $git_regex ]]; then
        return 0 # 有效
    else
        log_error "无效的 Git 地址: $url"
        exit 1
    fi
}

# 调用函数开始查找
find_git_dirs $SOURCE_BASE_ABS_PATH
