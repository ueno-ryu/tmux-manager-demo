#!/bin/bash
# 매니저 터미널 - 워커에게 명령을 내리고 결과를 수신

SESSION_NAME="manager-worker-demo"
WORKER_WINDOW="worker"
INSTALL_DIR="${HOME}/tmux-manager-demo"
CMD_FIFO="${INSTALL_DIR}/cmd.fifo"
RESULT_FIFO="${INSTALL_DIR}/result.fifo"

# Cleanup handler
cleanup() {
    echo "Cleaning up..."
    rm -f "$CMD_FIFO" "$RESULT_FIFO"
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null
}
trap cleanup EXIT INT TERM

# FIFO 초기화 (파이프 생성)
init_ipc() {
    if [ ! -p "$CMD_FIFO" ]; then
        rm -f "$CMD_FIFO" 2>/dev/null
        mkfifo "$CMD_FIFO"
    fi
    if [ ! -p "$RESULT_FIFO" ]; then
        rm -f "$RESULT_FIFO" 2>/dev/null
        mkfifo "$RESULT_FIFO"
    fi
}

# tmux 세션 시작
start_session() {
    tmux has-session -t "$SESSION_NAME" 2>/dev/null

    if [ $? != 0 ]; then
        echo "Creating tmux session: $SESSION_NAME"
        tmux new-session -d -s "$SESSION_NAME" -n manager
        tmux new-window -t "$SESSION_NAME" -n "$WORKER_WINDOW"
        tmux send-keys -t "$SESSION_NAME:$WORKER_WINDOW" "bash ${INSTALL_DIR}/worker.sh" C-m
    fi
}

# 워커에 명령 전송
send_command() {
    local cmd="$1"
    echo "$cmd" > "$CMD_FIFO"
    echo "[MANAGER] Sent command: $cmd"
}

# 워커로부터 결과 수신 (blocking)
receive_result() {
    # RESULT_FIFO에서 블로킹 읽기
    if [ -p "$RESULT_FIFO" ]; then
        if read -r response < "$RESULT_FIFO"; then
            # STATUS|MESSAGE 형식 파싱
            local status=$(echo "$response" | cut -d'|' -f1)
            local message=$(echo "$response" | cut -d'|' -f2-)

            # 상태에 따라 다른 스타일로 출력
            case "$status" in
                SUCCESS)
                    echo "[MANAGER] ✓ $message"
                    ;;
                ERROR)
                    echo "[MANAGER] ✗ $message"
                    ;;
                PROGRESS)
                    echo "[MANAGER] ⟳ $message"
                    ;;
                *)
                    echo "[MANAGER] ? $response"
                    ;;
            esac
        fi
    else
        echo "[MANAGER] Error: RESULT_FIFO not found"
    fi
}

# 대화형 명령 프롬프트
command_prompt() {
    while true; do
        echo ""
        echo "=== MANAGER TERMINAL ==="
        echo "Available commands:"
        echo "  1) echo <message>  - Worker echoes message"
        echo "  2) calc <expr>     - Worker calculates expression"
        echo "  3) status          - Get worker status"
        echo "  4) quit            - Exit manager"
        echo ""
        read -p "[MANAGER] Enter command: " input

        if [ "$input" = "quit" ]; then
            echo "Exiting..."
            send_command "QUIT"
            break
        fi

        send_command "$input"
        receive_result
    done
}

# 메인
main() {
    init_ipc
    start_session
    echo "[MANAGER] Ready. Attach to tmux session: tmux attach -t $SESSION_NAME"
    echo "[MANAGER] Worker window: ${SESSION_NAME}:${WORKER_WINDOW}"
    command_prompt
}

main
