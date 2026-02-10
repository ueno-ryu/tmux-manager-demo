# Tmux Manager-Worker Demo

tmux 기반 매니저-워커 통신 시스템 데모입니다. FIFO(Named Pipe)를 사용한 IPC(프로세스 간 통신) 방식으로, 두 터미널 창이 서로 메시지를 주고받습니다.

## 아키텍처

```
┌─────────────────┐         FIFO          ┌─────────────────┐
│   Manager       │ ◄────────────────────► │   Worker        │
│   (manager.sh)  │    cmd.fifo            │   (worker.sh)   │
│                 │ ◄────────────────────► │                 │
│                 │    result.fifo         │                 │
└─────────────────┘                         └─────────────────┘
         │                                           │
         └─────────────── tmux session ──────────────┘
```

## 빠른 시작

### 한 줄로 실행

```bash
curl -s https://raw.githubusercontent.com/[YOUR_USERNAME]/tmux-manager-demo/main/quickstart.sh | bash
```

또는:

```bash
bash <(curl -s https://raw.githubusercontent.com/[YOUR_USERNAME]/tmux-manager-demo/main/quickstart.sh)
```

### 수동 설치

```bash
# 1. 클론
git clone https://github.com/[YOUR_USERNAME]/tmux-manager-demo.git
cd tmux-manager-demo

# 2. 실행
bash manager.sh
```

## 사용법

매니저가 시작되면 다음 명령을 사용할 수 있습니다:

| 명령 | 설명 | 예시 |
|------|------|------|
| `echo <message>` | 워커가 메시지를 반복 | `echo Hello World` |
| `calc <expr>` | 사칙연산 계산 | `calc 2+2*3` |
| `status` | 워커 상태 확인 | `status` |
| `quit` | 종료 | `quit` |

## tmux 단축키

- `Ctrl+b c` - 새 창 생성
- `Ctrl+b n` - 다음 창으로 이동
- `Ctrl+b p` - 이전 창으로 이동
- `Ctrl+b 0` - 0번 창으로 이동 (manager)
- `Ctrl+b 1` - 1번 창으로 이동 (worker)
- `Ctrl+b d` - 세션 분리 (detach)
- `Ctrl+b [` - 스크롤 모드 진입 (q로 종료)

## 파일 구조

```
tmux-manager-demo/
├── manager.sh      # 매니저 스크립트 (명령 전송)
├── worker.sh       # 워커 스크립트 (명령 수행)
├── quickstart.sh   # 원스텟 설치 스크립트
└── README.md
```

## IPC 프로토콜

### 명령 형식 (Manager → Worker)
```
<COMMAND> <ARGUMENTS>
```

### 결과 형식 (Worker → Manager)
```
<STATUS>|<MESSAGE>
```

- **STATUS**: `SUCCESS`, `ERROR`, `PROGRESS`
- **MESSAGE**: 결과 또는 오류 메시지

## 요구사항

- `bash` 4.0+
- `tmux` 3.0+
- `bc` (계산용)

macOS:
```bash
brew install tmux
```

Ubuntu/Debian:
```bash
sudo apt-get install tmux bc
```

## 라이선스

MIT License
