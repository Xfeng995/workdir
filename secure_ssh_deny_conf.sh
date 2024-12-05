#!/bin/bash

# SSH配置文件和备份文件的路径
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_CONFIG_DEFAULT="/etc/ssh/sshd_config_default"
# hosts.deny文件和备份文件的路径
HOSTS_DENY="/etc/hosts.deny"
HOSTS_DENY_DEFAULT="/etc/hosts.deny_default"

# 函数：备份SSH配置文件
backup_ssh_config() {
    if [ ! -f "$SSH_CONFIG_DEFAULT" ]; then
        cp "$SSH_CONFIG" "$SSH_CONFIG_DEFAULT"
        echo "已创建SSH配置文件备份：$SSH_CONFIG_DEFAULT"
    else
        echo "SSH配置文件备份已存在：$SSH_CONFIG_DEFAULT"
    fi
}

# 函数：还原SSH配置文件
restore_ssh_config() {
    if [ -f "$SSH_CONFIG_DEFAULT" ]; then
        cp "$SSH_CONFIG_DEFAULT" "$SSH_CONFIG"
        echo "已还原SSH配置文件。"
    else
        echo "没有找到SSH配置文件备份。"
        exit 1
    fi
}

# 函数：修改SSH配置文件，禁止root用户登录
modify_ssh_config() {
    sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" "$SSH_CONFIG"
    if [ $? -eq 0 ]; then
        echo "已修改SSH配置文件，禁止root用户登录。"
    else
        echo "修改SSH配置文件失败，请检查sed命令。"
        exit 1
    fi
}

# 函数：备份/etc/hosts.deny文件
backup_hosts_deny() {
    if [ ! -f "$HOSTS_DENY_DEFAULT" ]; then
        cp "$HOSTS_DENY" "$HOSTS_DENY_DEFAULT"
        echo "已创建/etc/hosts.deny文件备份：$HOSTS_DENY_DEFAULT"
    else
        echo "hosts.deny文件备份已存在：$HOSTS_DENY_DEFAULT"
    fi
}

# 函数：还原/etc/hosts.deny文件
restore_hosts_deny() {
    if [ -f "$HOSTS_DENY_DEFAULT" ]; then
        cp "$HOSTS_DENY_DEFAULT" "$HOSTS_DENY"
        echo "已还原/etc/hosts.deny文件。"
    else
        echo "没有找到/etc/hosts.deny文件备份。"
        exit 1
    fi
}

# 函数：修改/etc/hosts.deny文件
modify_hosts_deny() {
    echo "sshd: ALL" >> "$HOSTS_DENY"
    if [ $? -eq 0 ]; then
        echo "已修改/etc/hosts.deny文件，添加了'sshd: ALL'。"
    else
        echo "修改/etc/hosts.deny文件失败。"
        exit 1
    fi
}

# 函数：重启SSH服务
restart_ssh_service() {
    service sshd restart
    if [ $? -eq 0 ]; then
        echo "SSH服务已重启。"
    else
        echo "重启SSH服务失败，请检查服务状态。"
        exit 1
    fi
}

# 主逻辑
case "$1" in
    "backup")
        backup_ssh_config
        backup_hosts_deny
        ;;
    "restore")
        restore_ssh_config
        restore_hosts_deny
        restart_ssh_service
        ;;
    "modify")
        backup_ssh_config
        modify_ssh_config
        backup_hosts_deny
        modify_hosts_deny
        restart_ssh_service
        ;;
    *)
        echo "使用方法：$0 {backup|restore|modify}"
        exit 1
        ;;
esac
