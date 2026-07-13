# Orca 조율 스튜디오

**공개 사이트 (여기로 배포·공유):** https://orca-lime.vercel.app  

누구나 **자기만의 Orca 조율 모드**를 만들고, **자기 컴퓨터**에 설치하는 정적 웹 + CLI 도구입니다.

> 자세한 배포·사용 안내: **[사용방법.md](./사용방법.md)**

## 배포 한 줄 요약

| 역할 | 할 일 |
|------|--------|
| **당신 (운영자)** | **https://orca-lime.vercel.app** 링크 공유 |
| **사용자 · 웹** | 탭 3–4로 모드 만들고 Quick Command 등록 |
| **사용자 · 스킬** | 터미널 한 줄로 `orca-mode-pack` 설치 (아래) |
| **설정 저장** | **사용자 PC** only. 서버에 안 쌓임 |

### 사용자 원클릭 (스킬)

```bash
curl -fsSL https://orca-lime.vercel.app/install.sh | bash
```

→ `~/.agents/skills/orca-mode-pack/` + `generate-pack.sh`  
→ 에이전트: `/orchestration-mode`

네 — **Vercel 사이트 + 같은 도메인의 install.sh** 로 배포합니다.

## 사용자 흐름 (사이트)

1. https://orca-lime.vercel.app 접속  
2. 탭 1–2: 개념  
3. 탭 3: 팀장·실무 모델·(선택) 리뷰 워커  
4. 탭 4: 설치 안내 · `.md` 다운로드 · AI 설치 요청문  
5. `$HOME/.orca/<모드>/` 저장 + Orca Quick Command (Global)  
6. (선택) `SKILL.md` → `~/.agents/skills/<모드>/`

## 운영자: Vercel

이미 연결됨 (`homepage`: orca-lime.vercel.app).

- `main`에 푸시 → 자동 재배포  
- 새 환경이면: Vercel Import → Framework **Other** · Build 없음 · Output 루트  

공유 문구 예:

```text
Orca 조율 모드 만들기: https://orca-lime.vercel.app
```

## CLI 팩 생성 (선택)

```bash
bash generate-pack.sh \
  --name my-orch \
  --display "MyOrch" \
  --coord grok \
  --worker codex \
  --worker-cmd 'codex -m gpt-5.6 -c model_reasoning_effort="xhigh"' \
  --review-cmd 'claude --model sonnet' \
  --max 3 \
  --wt auto \
  --coordination supervised \
  --triggers 'my-orch, 조율'
```

## 템플릿·스킬

| 경로 | 용도 |
|------|------|
| [`templates/REQUEST.template.md`](templates/REQUEST.template.md) | 채팅/에이전트에 붙이는 필요정보 표 |
| [`templates/mode-pack.schema.json`](templates/mode-pack.schema.json) | JSON 스키마 |
| [`skills/orca-mode-pack/`](skills/orca-mode-pack/) | `/orchestration-mode` 에이전트 스킬 |
| [`generate-pack.sh`](generate-pack.sh) | CLI로 팩 생성 |
| [`사용방법.md`](사용방법.md) | **배포·사용 전체 가이드 (한글)** |

## 엔진 스킬 (사용자 PC, 1회)

```bash
npx skills add https://github.com/stablyai/orca --skill orchestration
npx skills add https://github.com/stablyai/orca --skill orca-cli
```

## 로컬 미리보기

```bash
open index.html
# 또는
npx serve .
```

## 배움의 달인

- [유튜브](https://www.youtube.com/@%EB%B0%B0%EC%9B%80%EC%9D%98%EB%8B%AC%EC%9D%B8-p5v)
- [오픈채팅](https://open.kakao.com/o/gubGYQ7g)
- [뉴스레터](https://newsletter.teaboard.link/)

## 라이선스

개인·교육 목적 사용 환영. Orca 상표·제품은 각 소유자 권리.
