#!/usr/bin/env bash
# SAT 会话: Status, Analytics & Tracking
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../config/config.sh" 2>/dev/null || true

SESSION="SAT"
tmux new-session -d -s "$SESSION" -x 220 -y 50

# 主面板: 综合状态
tmux rename-window -t "$SESSION:0" 'status'
tmux send-keys -t "$SESSION:status" \
  "echo '=== SAT: Status Dashboard ===' && echo && echo 'Tasks:' && ls ${WORKFLOW_DIR}/codex/tasks/ 2>/dev/null | wc -l && echo 'Results:' && ls ${WORKFLOW_DIR}/codex/results/ 2>/dev/null | wc -l" C-m

# 右上: GitHub Issues
tmux split-window -t "$SESSION:status" -h -p 50
tmux send-keys -t "$SESSION:status" \
  "[ -n \"$GH_REPO\" ] && gh issue list --repo $GH_REPO --label agent-task --state open || echo 'GH_REPO 未配置'" C-m

# 下: 日志
tmux split-window -t "$SESSION:status" -v -p 30
tmux send-keys -t "$SESSION:status" \
  "tail -f ${WORKFLOW_DIR}/logs/github.log 2>/dev/null || echo '等待日志...'" C-m

tmux select-window -t "$SESSION:status"
echo "[SAT] 会话已启动"
