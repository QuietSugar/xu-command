#!/bin/bash
# ====================================================
#   遍历寻找目录下所有带 .git的目录,
#	  将它归档到 固定目录中
#
# ====================================================

# set -x

base_path=$(pwd)

# 设置基础目录,一定要配置,无默认值
if [ -n "$GIT_CLONE_BASE_DIR" ]; then
  baseDir="$GIT_CLONE_BASE_DIR"
fi
if [ ! -d "$baseDir" ]; then
  echo '[ xu -> ] 目录不存在,退出'
  exit 0
fi

function lm_traverse_dir(){
	# echo '开始 处理文件夹: ---------------------------'$(pwd)
	 echo "当前处理的文件夹: "$1
	# 判断.git文件是否存在,如果存在,表示当前目录是一个git仓库
	if [ -d ".git" ];then
		this_repo=$(echo "$(pwd)" | sed "s#$base_path##" )
		cloneUrl=$(git config --get remote.origin.url)
		echo "[log:]  原始路径:     $cloneUrl"
		#替换
#		cloneUrl=$(echo "$cloneUrl" | sed 's#https://ghproxy.com/##')
		# 删除前缀和后缀
		if [[ "$cloneUrl" =~ ^https://.* ]]; then
		  project_dir=$(echo "$cloneUrl" | sed 's#https://##' | sed 's/.git//g')
		elif [[ "$cloneUrl" =~ ^http://.* ]]; then
		  project_dir=$(echo "$cloneUrl" | sed 's#http://##' | sed 's/.git//g')
		elif [[ "$cloneUrl" =~ ^git@.* ]]; then
		  project_dir=$(echo "$cloneUrl" | sed 's#git@##' | sed 's/.git//g' | sed 's#:#/#')
		else
		  echo "[log:]  error url"
		  exit 0
		fi

		project_name=$(echo ${project_dir##*/} )
		git_clone_to_dir=${project_dir%/*}
		# 替换路径中的冒号(windows不支持该字符)
		git_clone_to_dir=$(echo "$git_clone_to_dir" | sed 's#:#_#')
		absolute_project_dir="$baseDir/$git_clone_to_dir"

		echo "git_clone_to_dir  $git_clone_to_dir"

		if [ ! -d "$absolute_project_dir" ]; then
		  mkdir -p "$absolute_project_dir"
		fi
		if [ ! -d "$absolute_project_dir/$project_name" ]; then
		  #cd "$absolute_project_dir"
		  # 移动文件
      local p_dir_name=$(basename `pwd`)
		  mv $(pwd) $absolute_project_dir
      mv "$absolute_project_dir/$p_dir_name" "$absolute_project_dir/$project_name"
		  echo "[log:]  移动路径: $absolute_project_dir"
		  echo ""
		else
		  echo "[log:]  已存在,跳过clone"
		fi
	else
		# 当前目录不是一个git仓库文件夹,遍历进入处理
		for file in `ls -a`
		do
			# 判断是否是目录
			if [ -d $file ];then
				# 判断是不是 . 和 ..
				if [[ $file != '.' ]] && [[ $file != '..' ]];
				then
					# echo '准备进入文件夹'$file
					# 进入当前目录
					cd $file
					lm_traverse_dir $file	#遍历子目录
				fi
			fi
		done
	fi
	# echo '结束 文件夹: ---------------------------'$(pwd)
	cd ..
}

lm_traverse_dir .


