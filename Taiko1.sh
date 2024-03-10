#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Taiko.sh"
# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="taiko"
    local shell_rc="$HOME/.bashrc"

    # 对于Zsh用户，使用.zshrc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$shell_rc"; then
        echo "设置快捷键 '$alias_name' 到 $shell_rc"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$shell_rc"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $shell_rc' 来激活快捷键，或重新打开终端。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $shell_rc。"
        echo "如果快捷键不起作用，请尝试运行 'source $shell_rc' 或重新打开终端。"
    fi
}

# 节点安装功能
function install_node() {

# 进入 Taiko 目录
cd $HOME/simple-taiko-node

# 如果不存在.env文件，则从示例创建一个
if [ ! -f .env ]; then
  cp .env.sample .env
fi

# 提示用户输入环境变量的值
l1_endpoint_http=https://ethereum-holesky.blockpi.network/v1/rpc/95900baa68b1912c8e645c02548d0d318db68b42
l1_endpoint_ws=wss://ethereum-holesky.blockpi.network/v1/ws/95900baa68b1912c8e645c02548d0d318db68b42
#read -p "请输入BlockPI holesky HTTP链接: " l1_endpoint_http
#read -p "请输入BlockPI holesky WS链接: " l1_endpoint_ws
# 提示用户输入环境变量的值
read -p "请输入EVM钱包私钥: " l1_proposer_private_key
enable_proposer=true

# 检测并罗列未被占用的端口
#function list_recommended_ports {
#    local start_port=8000 # 可以根据需要调整起始搜索端口
#    local needed_ports=7
#    local count=0
#    local ports=()
#
#    while [ "$count" -lt "$needed_ports" ]; do
#        if ! ss -tuln | grep -q ":$start_port " ; then
#            ports+=($start_port)
#            ((count++))
#        fi
#        ((start_port++))
#    done
#
#    echo "推荐的端口如下："
#    for port in "${ports[@]}"; do
#        echo -e "\033[0;32m$port\033[0m"
#    done
#}

# 使用推荐端口函数为端口配置
#list_recommended_ports

# 提示用户输入端口配置，允许使用默认值
#read -p "请输入L2执行引擎HTTP端口 [默认: 8547]: " port_l2_execution_engine_http
#port_l2_execution_engine_http=${port_l2_execution_engine_http:-8547}
#
#read -p "请输入L2执行引擎WS端口 [默认: 8548]: " port_l2_execution_engine_ws
#port_l2_execution_engine_ws=${port_l2_execution_engine_ws:-8548}
#
#read -p "请输入L2执行引擎Metrics端口 [默认: 6060]: " port_l2_execution_engine_metrics
#port_l2_execution_engine_metrics=${port_l2_execution_engine_metrics:-6060}
#
#read -p "请输入L2执行引擎P2P端口 [默认: 30306]: " port_l2_execution_engine_p2p
#port_l2_execution_engine_p2p=${port_l2_execution_engine_p2p:-30306}
#
#read -p "请输入证明者服务器端口 [默认: 9876]: " port_prover_server
#port_prover_server=${port_prover_server:-9876}
#
#read -p "请输入Prometheus端口 [默认: 9091]: " port_prometheus
#port_prometheus=${port_prometheus:-9091}
#
#read -p "请输入Grafana端口 [默认: 3001]: " port_grafana
#port_grafana=${port_grafana:-3001}

# 将用户输入的值写入.env文件
sed -i "s|L1_ENDPOINT_HTTP=.*|L1_ENDPOINT_HTTP=${l1_endpoint_http}|" .env
sed -i "s|L1_ENDPOINT_WS=.*|L1_ENDPOINT_WS=${l1_endpoint_ws}|" .env
sed -i "s|ENABLE_PROPOSER=.*|ENABLE_PROPOSER=${enable_proposer}|" .env
sed -i "s|L1_PROPOSER_PRIVATE_KEY=.*|L1_PROPOSER_PRIVATE_KEY=${l1_proposer_private_key}|" .env

# 更新.env文件中的端口配置 已经在.env文件中配置好了
#sed -i "s|PORT_L2_EXECUTION_ENGINE_HTTP=.*|PORT_L2_EXECUTION_ENGINE_HTTP=${port_l2_execution_engine_http}|" .env
#sed -i "s|PORT_L2_EXECUTION_ENGINE_WS=.*|PORT_L2_EXECUTION_ENGINE_WS=${port_l2_execution_engine_ws}|" .env
#sed -i "s|PORT_L2_EXECUTION_ENGINE_METRICS=.*|PORT_L2_EXECUTION_ENGINE_METRICS=${port_l2_execution_engine_metrics}|" .env
#sed -i "s|PORT_L2_EXECUTION_ENGINE_P2P=.*|PORT_L2_EXECUTION_ENGINE_P2P=${port_l2_execution_engine_p2p}|" .env
#sed -i "s|PORT_PROVER_SERVER=.*|PORT_PROVER_SERVER=${port_prover_server}|" .env
#sed -i "s|PORT_PROMETHEUS=.*|PORT_PROMETHEUS=${port_prometheus}|" .env
#sed -i "s|PORT_GRAFANA=.*|PORT_GRAFANA=${port_grafana}|" .env
sed -i "s|PROVER_ENDPOINTS=.*|PROVER_ENDPOINTS=http://taiko-a6-prover.zkpool.io|" .env

# 用户信息已配置完毕
echo "用户信息已配置完毕。"


# 运行 Taiko 节点
docker-compose -f docker-compose-1.yaml up

# 获取公网 IP 地址
public_ip=$(curl -s ifconfig.me)

# 准备原始链接
original_url1="LocalHost:11116/d/L2ExecutionEngine/l2-execution-engine-overview?orgId=1&refresh=10s"

# 替换 LocalHost 为公网 IP 地址
updated_url1=$(echo original_url1 | sed "s/LocalHost/$public_ip/")

# 显示更新后的链接
echo "请通过以下链接查询设备运行情况，如果无法访问，请等待2-3分钟后重试：$updated_url1"

}

# 查看节点日志
function check_service_status() {
    docker-compose -f docker-compose-1.yml logs -f
}

# 重启
function restart() {
    docker-compose -f docker-compose-1.yml restart
}



# 主菜单
function main_menu() {
    clear
    echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
    echo "================================================================"
    echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
    echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
    echo "请选择要执行的操作:"
    echo "1. 安装节点"
    echo "2. 查看节点日志"
    echo "3. 设置快捷键的功能"
    echo "4. 重启"
    read -p "请输入选项（1-4）: " OPTION

    case $OPTION in
    1) install_node ;;
    2) check_service_status ;;
    3) check_and_set_alias ;;
    4) restart ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu