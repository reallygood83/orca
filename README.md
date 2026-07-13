# Orca 조율 스튜디오

**누구나 자기만의 Orca 조율 모드**를 만들고, 자기 컴퓨터에 설치할 수 있게 돕는 정적 웹 + CLI 도구입니다.

- 서버에 설정이 저장되지 않음 (브라우저에서만 생성)
- 사람마다 팀장/실무 AI·**모델 명령**·모드 이름을 다르게 설정
- **모델은 `dispatch`가 아니라 worker `--command`에 지정** (스키마·REQUEST 템플릿 제공)
- 리뷰 워커(선택), supervised vs handoff 구분
- CLI `generate-pack.sh` → `$HOME/.orca/<mode>/` 팩 + `SKILL.md` 생성
- 에이전트 스킬: `skills/orca-mode-pack/` (JinJing형 모드 생성·실행)

JinJing 등 **특정 PC 전용 파일 없이** 이 레포/스튜디오만으로 자기 모드를 만들 수 있습니다.

## 사용자 흐름

1. 사이트 접속 (또는 `open index.html`)
2. 조율이 뭔지 보기 (탭 1–2)
3. 내 모드 정하기 (탭 3) — 모델 프리셋 / 리뷰 워커 / 조율 유형
4. 설치 방법 · `.md` 다운로드 · AI 요청문 복사 (탭 4)
5. `$HOME/.orca/<모드>/` 저장 + Orca Quick Command 등록
6. (선택) `SKILL.md` → `~/.agents/skills/<모드>/`

## CLI 팩 생성

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

산출: `PLAYBOOK.md`, `prompts/quick-command.txt`, `meta.json`, `SKILL.md`, `REQUEST.filled.md` …

## 필요 정보 템플릿 (에이전트/채팅용)

- [`templates/REQUEST.template.md`](templates/REQUEST.template.md) — 사람이 채우는 표
- [`templates/mode-pack.schema.json`](templates/mode-pack.schema.json) — JSON 스키마
- [`skills/orca-mode-pack/SKILL.md`](skills/orca-mode-pack/SKILL.md) — `/orchestration-mode` 스킬

설치 예:

```bash
mkdir -p ~/.agents/skills/orca-mode-pack/references
cp skills/orca-mode-pack/SKILL.md ~/.agents/skills/orca-mode-pack/
cp skills/orca-mode-pack/references/* ~/.agents/skills/orca-mode-pack/references/
```

## 로컬

```bash
open index.html
# 또는
npx serve .
```

## Vercel

1. 이 저장소 Import  
2. Framework: Other · Build 없음 · Output 루트  
3. Deploy → `main` 푸시 시 자동 재배포  

## 엔진 스킬 (별도)

조율 런타임 자체:

```bash
npx skills add https://github.com/stablyai/orca --skill orchestration
npx skills add https://github.com/stablyai/orca --skill orca-cli
```

## 배움의 달인

- [유튜브](https://www.youtube.com/@%EB%B0%B0%EC%9B%80%EC%9D%98%EB%8B%AC%EC%9D%B8-p5v)
- [오픈채팅](https://open.kakao.com/o/gubGYQ7g)
- [뉴스레터](https://newsletter.teaboard.link/)

## 라이선스

개인·교육 목적 사용 환영. Orca 상표·제품은 각 소유자 권리.
