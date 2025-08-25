#!/bin/bash

# ============================================
# 用户配置区
# ============================================

# 你的 GitHub 仓库中存放脚本的原始 URL
# 格式为：https://raw.githubusercontent.com/用户名/仓库名/分支/
GITHUB_RAW_URL="https://raw.githubusercontent.com/guangwit9/ArgoSB_merge/main/"

# 脚本将被下载到 VPS 上的哪个目录
INSTALL_DIR="/root/scripts"

# ============================================
# 脚本自动化区 - 以下代码无需修改
# ============================================

# 检查脚本是否以 root 权限运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以 root 用户身份运行。"
   exit 1
fi

echo "开始 VPS 配置和文件同步..."

# 检查并安装 git 和 python3
echo "检查依赖项：git 和 python3..."
apt-get update -y
if ! command -v git &> /dev/null; then
    echo "git 未找到，正在安装..."
    apt-get install -y git
fi
if ! command -v python3 &> /dev/null; then
    echo "python3 未找到，正在安装..."
    apt-get install -y python3
fi

# 确保 python3-pip 已经安装
if ! dpkg -l | grep -q python3-pip; then
    echo "python3-pip 软件包未找到，正在安装..."
    apt-get install -y python3-pip
fi

echo "安装 Python 依赖项..."
# 使用更可靠的方式运行 pip3，避免 PATH 问题
if command -v pip3 &> /dev/null; then
    pip3 install PyYAML
elif command -v python3 &> /dev/null; then
    python3 -m pip install PyYAML
else
    echo "错误：无法找到 pip 或 python3，无法安装 PyYAML。退出。"
    exit 1
fi

# 创建安装目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || { echo "错误：无法切换到目录，退出。"; exit 1; }

# 下载脚本文件
echo "从 GitHub 下载脚本..."
curl -sL "${GITHUB_RAW_URL}upload_and_merge.py" -o "upload_and_merge.py"
curl -sL "${GITHUB_RAW_URL}gitlab_uploader.sh" -o "gitlab_uploader.sh"

# 检查文件是否成功下载
if [ $? -ne 0 ] || [ ! -s "upload_and_merge.py" ] || [ ! -s "gitlab_uploader.sh" ]; then
    echo "错误：一个或多个脚本下载失败。请检查你的 GitHub URL。"
    exit 1
fi

# 赋予脚本执行权限
chmod +x gitlab_uploader.sh
chmod +x upload_and_merge.py

# 运行主脚本
echo "运行主上传脚本..."
/bin/bash gitlab_uploader.sh

echo "配置和同步完成。"
