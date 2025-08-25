自动化 VPS 节点文件同步至 GitLab
这是一个用于自动化 VPS 节点文件同步的脚本项目。它能够将多个 VPS 上相同路径下的配置文件（clash_meta_client.yaml, sing_box_client.json, jh_sub.txt）合并到同一个 GitLab 仓库中，以避免手动复制和文件冲突。

项目原理
一键安装与同步：通过一个简单的 bash 命令，脚本会自动在 VPS 上安装必要的依赖（git, python3, pyyaml）。

GitLab 仓库操作：脚本使用你提供的 GitLab Token 认证，从远程仓库拉取最新文件。

智能文件合并：

Clash 和 Sing-box 文件：脚本会解析新旧文件，提取所有节点信息并合并。如果节点名称相同，会保留最新文件中的配置。

jh_sub.txt：脚本会将新旧文件中的所有行合并并自动去重，确保内容唯一。

提交与推送：合并完成后，脚本会将更新后的文件自动提交并推送到你的 GitLab 仓库，保持文件同步。

快速开始
准备 GitLab 仓库

在 GitLab 上创建一个新项目，项目名为 all，默认分支为 main。

前往你的 GitLab 用户设置 -> Access Tokens，创建一个新的 Personal Access Token，并确保勾选 read_repository 和 write_repository 权限。

准备 GitHub 仓库

在 GitHub 上创建一个新仓库，用于存放本项目的脚本。

将以下三个文件上传到你的 GitHub 仓库根目录：upload_and_merge.py, gitlab_uploader.sh, setup_vps.sh。

运行一键同步命令

在你的每个 VPS 上，打开终端，以 root 用户身份运行以下命令。将 <...> 替换为你自己的信息。

注意：此命令会在 VPS 上安装必要的软件，并需要磁盘空间。如果遇到空间不足错误，请先清理 VPS 存储。

Bash

GITLAB_TOKEN="<你的GitLab访问令牌>" \
GIT_USER_NAME="<你的GitLab用户名>" \
GIT_USER_EMAIL="<你的GitLab邮箱>" \
GITLAB_REPO_URL="https://gitlab.com/<你的GitLab用户名>/all.git" \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<你的GitHub用户名>/<你的GitHub仓库名>/main/setup_vps.sh)"
文件说明
setup_vps.sh：这个是核心的一键安装和运行脚本。它会检查 VPS 依赖，下载其他脚本，并启动自动化流程。

gitlab_uploader.sh：这个脚本负责 Git 操作，包括克隆 GitLab 仓库、调用 Python 脚本进行合并、以及最后的提交与推送。

upload_and_merge.py：这个 Python 脚本包含核心的文件合并逻辑，它会处理不同格式的配置文件，并确保节点信息不会丢失或冲突。
