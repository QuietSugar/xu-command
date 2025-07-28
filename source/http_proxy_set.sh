#!/bin/bash


function set_proxy() {
  # 获取配置,若未配置,则不可使用
  if [ -n "$PROXY_ADDR" ]; then
    local proxy_addr="$PROXY_ADDR"
    export http_proxy="http://${proxy_addr}" https_proxy="http://${proxy_addr}" all_proxy="socks5://${proxy_addr}"
    echo "Set proxy to ${proxy_addr}"
  else
    echo '[ xu -> ] 未配置地址,退出'
  fi
}

function unset_proxy() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
  echo "Unset proxy"
}
                                                                                                                                                            # Shadowsocks proxy
alias proxy="set_proxy"
alias unproxy="unset_proxy"
