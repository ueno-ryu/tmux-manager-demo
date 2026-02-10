#!/bin/bash
# Tmux Manager-Worker Demo - Quickstart Installer
# 이 스크립트를 실행하면 모든 것을 자동으로 설정합니다

set -e

REPO_URL="${1:-https://github.com/ueno-ryu/tmux-manager-demo.git}"
INSTALL_DIR="$HOME/tmux-manager-demo"

echo "=== Tmux Manager-Worker Demo Installer ==="
echo ""

# 의존성 체크
check_dependencies() {
    echo "Checking dependencies..."

    if ! command -v tmux &> /dev/null; then
        echo "❌ tmux not found. Please install tmux first."
        echo "   macOS: brew install tmux"
        echo "   Ubuntu: sudo apt-get install tmux"
        exit 1
    fi

    if ! command -v bc &> /dev/null; then
        echo "❌ bc not found. Please install bc first."
        echo "   macOS: bc is usually pre-installed"
        echo "   Ubuntu: sudo apt-get install bc"
        exit 1
    fi

    echo "✓ All dependencies satisfied"
}

# 기존 설치 확인
if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Existing installation found at $INSTALL_DIR"
    read -p "Remove and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "Aborted."
        exit 0
    fi
fi

# 설치
echo "Installing to $INSTALL_DIR..."
git clone "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 실행 권한 설정
chmod +x manager.sh worker.sh quickstart.sh

# 기존 tmux 세션 정리
echo "Cleaning up old tmux sessions..."
tmux has-session -t manager-worker-demo 2>/dev/null && \
    tmux kill-session -t manager-worker-demo

echo ""
echo "✓ Installation complete!"
echo ""
echo "Starting manager..."
sleep 1

# 매니저 시작
bash manager.sh
