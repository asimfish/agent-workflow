#!/usr/bin/env bash
# TOOLS 会话: 系统工具 & 临时 shell
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../config/config.sh" 2>/dev/null || true

SESSION="TOOLS"
tmux new-session -d -s "$SESSION" -x 220 -y 50

tmux rename-window -t "$SESSION:0" 'shell'
tmux send-keys -t "$SESSION:shell" \
  "cd ${WORKFLOW_DIR} && echo '=== TOOLS: workflow root ===' && ls" C-m

# 右侧: htop / 资源监控
tmux split-window -t "$SESSION:shell" -h -p 40
tmux send-keys -t "$SESSION:shell" \
  "command -v htop &>/dev/null && htop || top" C-m

# 窗口 1: git 操作
tmux new-window -t "$SESSION" -n 'git'
tmux send-keys -t "$SESSION:git" \
  "cd ${WORKFLOW_ROOT:-$HOME/projects} && git status 2>/dev/null || echo 'Not a git repo'" C-m

tmux select-window -t "$SESSION:shell"
echo "[TOOLS] 会话已启动"
