#!/bin/bash
# 워커 터미널 - 매니저의 명령을 수행하고 결과를 반환

INSTALL_DIR="${HOME}/tmux-manager-demo"
CMD_FIFO="${INSTALL_DIR}/cmd.fifo"
RESULT_FIFO="${INSTALL_DIR}/result.fifo"
WORKER_ID="[WORKER-$$]"

# 결과를 매니저에게 전송
send_result() {
    local status="$1"
    local message="$2"
    echo "${status}|${message}" > "$RESULT_FIFO"
    echo "${WORKER_ID} Result sent: ${status} - ${message}"
}

# 명령 파싱 및 실행
execute_command() {
    local input="$1"

    # 명령과 인자 분리
    local cmd=$(echo "$input" | awk '{print $1}')
    local args=$(echo "$input" | cut -s -d' ' -f2-)

    case "$cmd" in
        echo)
            if [ -z "$args" ]; then
                send_result "ERROR" "Usage: echo <message>"
            else
                send_result "SUCCESS" "$args"
            fi
            ;;
        calc)
            if [ -z "$args" ]; then
                send_result "ERROR" "Usage: calc <expression>"
            else
                # bc로 계산 (소수점 지원)
                local result=$(echo "$args" | bc 2>/dev/null)
                if [ $? -eq 0 ]; then
                    send_result "SUCCESS" "${args} = ${result}"
                else
                    send_result "ERROR" "Invalid expression: ${args}"
                fi
            fi
            ;;
        status)
            report_status
            ;;
        *)
            send_result "ERROR" "Unknown command: ${cmd} (try: echo, calc, status)"
            ;;
    esac
}

# 상태 보고
report_status() {
    send_result "SUCCESS" "Worker alive - PID:$$ - Uptime: $(ps -o etime= -p "$$" | xargs)"
}

# 메인 루프
main() {
    echo "${WORKER_ID} Starting..."
    echo "${WORKER_ID} Waiting for commands..."

    while true; do
        # FIFO에서 명령 읽기 (blocking)
        if [ -p "$CMD_FIFO" ]; then
            if read -r cmd < "$CMD_FIFO"; then
                echo "${WORKER_ID} Received: ${cmd}"

                # QUIT 명령 처리
                if [ "$cmd" = "QUIT" ]; then
                    send_result "SUCCESS" "Worker shutting down"
                    break
                fi

                # 명령 실행
                execute_command "$cmd"
            fi
        else
            echo "${WORKER_ID} Warning: CMD_FIFO not found, waiting..."
            sleep 1
        fi
    done

    echo "${WORKER_ID} Exiting..."
}

main
