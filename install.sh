#!/bin/bash


XU_COMMAND_RELEASE_URL="${XU_COMMAND_URL:-https://github.com/QuietSugar/xu-command/releases/download/v1.0.0/xu-command-v1.0.0.tar.gz}"
XU_COMMAND_INSTALL_ROOT_PATH=${HOME}"/.xu-command/"
XU_COMMAND_NAME="xu-command"
mkdir -p ${XU_COMMAND_INSTALL_ROOT_PATH}


# 直接使用当前的源码安装
function install_local() {
  check
  cd ..
  install_from_dir
}

# 下载安装包然后执行安装
function install() {
  set -e
  check
  TMP_ROOT=/tmp/xu-command-installer
  rm -rf ${TMP_ROOT}
  mkdir -p ${TMP_ROOT}
  TMP_DIR=$(mktemp -d -p ${TMP_ROOT})

  cd "${TMP_DIR}"
  # wget -t 3 -q --show-progress -c  "${XU_COMMAND_RELEASE_URL}"
  curl -L -C - -# -o "$(basename "${XU_COMMAND_RELEASE_URL}")" --connect-timeout 3 --retry 3 --retry-delay 1 --retry-max-time 30 "${XU_COMMAND_RELEASE_URL}"
  release_tar_file=$(ls xu-command*.tar.gz 2>/dev/null | head -n 1)
  if [ -z "$release_tar_file" ]; then
    echo "错误：未找到-*.tar.gz文件" >&2
    exit 1
  fi
  tar zxf "${release_tar_file}"
  if [ -z "$XU_COMMAND_NAME" ]; then
    echo "错误：未找到解压的目录" >&2
    exit 1
  fi
  install_from_dir
}

function install_from_dir() {
  cp -r ${XU_COMMAND_NAME}/command ${XU_COMMAND_INSTALL_ROOT_PATH}
  cp ${XU_COMMAND_NAME}/example.env ${XU_COMMAND_INSTALL_ROOT_PATH}
  cp -r ${XU_COMMAND_NAME}/source ${XU_COMMAND_INSTALL_ROOT_PATH}
  chmod -R +x ${XU_COMMAND_INSTALL_ROOT_PATH}
  copy_sh_file
  install_done
}

# ====================================================
#   复制一份不带后缀的文件
#	  foo.sh ->  foo
# ====================================================
function copy_sh_file() {
  local command_path=${XU_COMMAND_INSTALL_ROOT_PATH}command
  pushd "${command_path}"
  for file in "${command_path}"/*.sh; do
    if [[ -f "$file" ]]; then
      cp -f $file $(basename $file .sh)
    fi
  done
  popd
}

function check() {
  # 检查目录是否存在
  if [ -d "${XU_COMMAND_INSTALL_ROOT_PATH}/command" ]; then
    echo "已安装,退出"
    exit 0
  fi
}

function install_done() {
  if [ "Windows_NT" = "$OS" ]; then
    bin_ath=$(cygpath -w ${XU_COMMAND_INSTALL_ROOT_PATH}/command)
  else
    bin_ath=$script_path
  fi
  cat <<'EOF'

将以下脚本内容加入你的配置文件中
1. .profile
2. .bashrc 适用于linux和安装了git-bash的windows
3. .bash_profile  专门针对git-bash 位于git安装目录中
以下是具体内容

# set user's private env if it exists
if [ -d "$HOME/.xu-command/source" ]; then
  while IFS= read -r -d '' FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.xu-command/source" -name '*.sh' -print0 | sort -z)
fi

EOF

echo 'install done'
}
function uninstall() {
  echo "uninstall" ${XU_COMMAND_NAME}
  rm -rf ${XU_COMMAND_INSTALL_ROOT_PATH}command
}

if [ "$1" = "uninstall" ]; then
  uninstall
elif [ "$1" = "me" ]; then
  install_local
else
  install
fi
