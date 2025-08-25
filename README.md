# 🤖 VPS 节点文件自动化同步工具

## 📦 项目简介

本项目旨在为拥有多个 VPS 的用户提供一个自动化解决方案，以同步和管理各服务器上的配置文件。通过本脚本，可将各 VPS 相同路径下的节点文件（`/etc/s-box/jh_sub.txt`, `/etc/s-box/sing_box_client.json`, `/etc/s-box/clash_meta_client.yaml`）自动合并至同一个 GitLab 仓库，实现无人值守的节点管理。

---

## 🛠 使用前准备

### 🔐 GitLab 设置提醒

请在你的 GitLab 项目设置中完成以下配置：

-   打开：`Settings → Repository → Protected branches`
-   启用：**Allow force push**
-   使用 Token 时，建议设置为最小权限（仅允许 push），并注意 Token 的有效期与保存方式

### 请提前准备以下信息（均为必填）：

-   `GITLAB_TOKEN`：你的 GitLab 项目 Token
-   `GIT_USER_NAME`：你的 GitLab 用户名（注意是用户名，而非昵称）
-   `GIT_USER_EMAIL`：你的 GitLab 邮箱
-   `GITLAB_REPO_URL`：你的 GitLab 项目完整 URL

---

## 🚀 一行命令自动部署

本脚本的核心优势在于其零交互自动化。你只需在每个 VPS 上运行一个简单的命令，即可完成所有配置、依赖安装和文件同步。

将以下命令中的参数替换为你的实际信息，即可一键完成所有流程：

```bash
GITLAB_TOKEN="<你的GitLab访问令牌>" \
GIT_USER_NAME="<你的GitLab用户名>" \
GIT_USER_EMAIL="<你的GitLab邮箱>" \
GITLAB_REPO_URL="https://gitlab.com/<你的GitLab用户名>/all.git" \
bash -c "$(wget -qO- https://raw.githubusercontent.com/guangwit9/ArgoSB_merge/main/setup_vps.sh)"
