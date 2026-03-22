#!/usr/bin/env bash
# WAM 会话: Worker Activity Monitor — 并行 Worker 监控
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../config/config.sh" 2>/dev/null || true

SESSION="WAM"
tmux new-session -d -s "$SESSION" -x 220 -y 50

# 左侧主面板: 日志流
tmux rename-window -t "$SESSION:0" 'monitor'
tmux send-keys -t "$SESSION:monitor" \
  "tail -f ${WORKFLOW_DIR}/logs/dispatch.log 2>/dev/null || echo '等待日志...' && sleep 2 && tail -f ${WORKFLOW_DIR}/logs/dispatch.log" C-m

# 右侧: 任务状态
tmux split-window -t "$SESSION:monitor" -h -p 40
tmux send-keys -t "$SESSION:monitor" \
  "watch -n 2 'for f in ${WORKFLOW_DIR}/codex/results/*.json; do [ -f \"\$f\" ] && jq -r \"[.id,.status] | @tsv\" \"\$f\"; done 2>/dev/null | column -t'" C-m

# 窗口 1: GitHub Actions 监控
tmux new-window -t "$SESSION" -n 'gh-actions'
tmux send-keys -t "$SESSION:gh-actions" \
  "[ -n \"$GH_REPO\" ] && watch -n 30 'gh run list --repo $GH_REPO --limit 10' || echo 'GH_REPO 未配置'" C-m

tmux select-window -t "$SESSION:monitor"
echo "[WAM] 会话已启动"
