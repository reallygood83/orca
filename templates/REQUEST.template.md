# Orca Mode Pack — REQUEST

> 이 파일을 채우거나, 채팅에 같은 항목을 붙여 주세요.  
> 에이전트/스튜디오/generate-pack.sh 가 PLAYBOOK · Quick Command · meta.json 을 생성합니다.

---

## 1. 모드 정체성

| 필드 | 값 | 설명 |
|------|-----|------|
| modeName | `my-orch` | 폴더명 `$HOME/.orca/<modeName>/` · 소문자·하이픈 |
| displayName | `MyOrch` | Orca Quick Command 라벨 |
| triggers | `my-orch, 조율, orchestrate` | 부를 때 쓰는 말 (쉼표) |
| coordination | `supervised` | `supervised` = 끝까지 대기 · `handoff` = 넘기고 손 뗌 |

---

## 2. 팀장 (Coordinator)

| 필드 | 값 |
|------|-----|
| agent | `grok` |
| notes | 분해 · dispatch · wait · FINAL 합성 |

팀장은 보통 **지금 대화 중인 에이전트**입니다. 별도 모델 커맨드가 필요하면 적으세요.

| coordinatorCommand (optional) | |
|-------------------------------|--|
| | _(비우면 현재 세션 사용)_ |

---

## 3. 실무 워커 (Workers) — 모델은 여기에

> **dispatch 에는 모델 옵션이 없습니다.**  
> `command` 한 줄에 agent + model + effort 를 모두 넣습니다.

### Worker A — implement (필수)

| 필드 | 값 | 예시 |
|------|-----|------|
| role | `implement` | implement / review / test / research |
| agent | `codex` | codex / claude / grok / opencode |
| model | `gpt-5.6` | CLI가 받는 모델 id |
| effort | `xhigh` | Codex reasoning 등 (없으면 비움) |
| command | `codex -m gpt-5.6 -c model_reasoning_effort="xhigh"` | **실제 터미널 명령** |

### Worker B — review (선택)

| 필드 | 값 |
|------|-----|
| role | `review` |
| agent | `claude` |
| model | `sonnet` |
| effort | |
| command | `claude --model sonnet` |
| ownership | `review-only` | review-only = 수정 권한 없음 |

### Worker C (선택)

| 필드 | 값 |
|------|-----|
| role | |
| agent | |
| model | |
| effort | |
| command | |

---

## 4. 실행 정책

| 필드 | 값 | 옵션 |
|------|-----|------|
| worktreePolicy | `auto` | `active` 같은 폴더 · `isolated` 새 worktree · `auto` 상황별 |
| maxConcurrent | `3` | 1–6 |
| waitTimeoutMs | `900000` | check --wait 기본 15분 창 |
| finalSections | `요약, 태스크별 결과, 결정/트레이드오프, 수정 파일, 리스크/다음 액션` | FINAL 목차 |

---

## 5. 프로젝트 오버레이 (선택)

| 필드 | 값 |
|------|-----|
| projectRules | 예: 테스트 명령, PII 금지, DESIGN.md 준수 |
| repoOverlayPath | `.orca/<modeName>.md` |

---

## 6. 첫 실행 Goal (선택)

```text
Goal:
```

---

## 생성 후 산출물

```text
$HOME/.orca/<modeName>/
  PLAYBOOK.md              # 운영 체제
  README.md
  meta.json                # 기계 판독
  prompts/quick-command.txt
  prompts/coordinator-start.md
  SKILL.md                 # 에이전트 스킬 후보 (선택 설치)
```

설치:

1. Orca → Settings → Quick Commands → Label=`displayName` · Global · Text=`quick-command.txt`
2. (선택) `npx skills add` 또는 `~/.agents/skills/<modeName>/` 에 SKILL.md 복사
3. Goal 붙여 실행
