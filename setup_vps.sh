#!/bin/bash

# ============================================
# 用户配置区
# 脚本将从命令行参数或环境变量中获取信息
# ============================================

# 你的 GitHub 仓库中存放脚本的原始 URL
# 格式为：https://raw.githubusercontent.com/用户名/仓库名/分支/
GITHUB_RAW_URL="https://raw.githubusercontent.com/your-username/your-repo/main/"

# 脚本将被下载到 VPS 上的哪个目录
INSTALL_DIR="/root/scripts"

# ============================================
# 脚本自动化区 - 以下代码无需修改
# ============================================

# 检查环境变量是否已设置
if [ -z "$GITLAB_TOKEN" ] || [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ] || [ -z "$GITLAB_REPO_URL" ]; then
    echo "Error: Please set required environment variables before running this script."
    echo "Example: GITLAB_TOKEN='...' GIT_USER_NAME='...' GIT_USER_EMAIL='...' GITLAB_REPO_URL='...' bash -c \"\$(curl -fsSL ...)\""
    exit 1
fi

echo "Starting VPS setup and file synchronization..."

# 检查并安装 git 和 python3
echo "Checking dependencies: git and python3..."
if ! command -v git &> /dev/null; then
    echo "git not found, installing..."
    apt-get update && apt-get install -y git
fi
if ! command -v python3 &> /dev/null; then
    echo "python3 not found, installing..."
    apt-get update && apt-get install -y python3 python3-pip
fi

echo "Installing python dependencies..."
pip3 install PyYAML

# 创建安装目录
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 下载脚本文件
echo "Downloading scripts from GitHub..."
curl -sL "${GITHUB_RAW_URL}upload_and_merge.py" -o "upload_and_merge.py"
curl -sL "${GITHUB_RAW_URL}gitlab_uploader.sh" -o "gitlab_uploader.sh"

if [ $? -ne 0 ]; then
    echo "Error: Failed to download scripts. Check your GitHub URL."
    exit 1
fi

# 赋予执行权限
chmod +x gitlab_uploader.sh
chmod +x upload_and_merge.py

# 运行主脚本，并传入环境变量
echo "Running the main uploader script..."

/bin/bash gitlab_uploader.sh

echo "Setup and synchronization complete."
