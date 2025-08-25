#!/bin/bash

# ============================================
# 脚本自动化区
# ============================================

# 仓库克隆的本地目录
REPO_DIR="temp_repo"

# 检查环境变量是否已设置
if [ -z "$GITLAB_TOKEN" ] || [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ] || [ -z "$GITLAB_REPO_URL" ]; then
    echo "Error: Required environment variables (GITLAB_TOKEN, GIT_USER_NAME, GIT_USER_EMAIL, GITLAB_REPO_URL) are not set."
    exit 1
fi

# 获取脚本所在的目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# 检查依赖文件
if [ ! -f "$SCRIPT_DIR/upload_and_merge.py" ]; then
    echo "Error: upload_and_merge.py script not found at $SCRIPT_DIR"
    exit 1
fi

echo "Configuring Git..."
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# 清理旧的临时仓库
rm -rf "$REPO_DIR"

echo "Cloning GitLab repository..."
git clone "https://oauth2:$GITLAB_TOKEN@${GITLAB_REPO_URL#*://}" "$REPO_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to clone the repository."
    exit 1
fi

# 遍历你 VPS 上的三个文件
SOURCE_DIR="/etc/s-box"
for file_name in "jh_sub.txt" "sing_box_client.json" "clash_meta_client.yaml"; do
    FILE_PATH="$SOURCE_DIR/$file_name"
    FILE_TYPE=""

    case "$file_name" in
        "jh_sub.txt")
            FILE_TYPE="jh"
            ;;
        "sing_box_client.json")
            FILE_TYPE="singbox"
            ;;
        "clash_meta_client.yaml")
            FILE_TYPE="clash"
            ;;
        *)
            echo "Unknown file type for $file_name"
            continue
            ;;
    esac

    echo "---"
    echo "Processing file: $FILE_PATH"

    python3 "$SCRIPT_DIR/upload_and_merge.py" "$FILE_PATH" "$REPO_DIR" "$FILE_TYPE"

    if [ $? -ne 0 ]; then
        echo "Error: Python script failed for file $FILE_PATH. Aborting."
        rm -rf "$REPO_DIR"
        exit 1
    fi
done

echo "---"
echo "Entering repository directory..."
cd "$REPO_DIR"

echo "Adding changes to Git..."
git add .

if git status --porcelain | grep .; then
    echo "Changes detected, committing and pushing..."
    git commit -m "chore: Update config files from a VPS"
    git push origin main
else
    echo "No changes to commit."
fi

echo "---"
echo "Cleaning up temporary directory..."
cd ..
rm -rf "$REPO_DIR"

echo "Script finished successfully."
