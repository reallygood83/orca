# Orca 조율 스튜디오

Orca **orchestration(조율)** 을 쉽게 이해하고, JinJing·MOA처럼 **나만의 모드 팩**을 만들어 설치하는 정적 웹 도구입니다.

- 서버·로그인·API 없음 (순수 HTML)
- 변수 변경 → 설치 안내·다운로드 `.md` 자동 동기화
- Vercel / GitHub Pages 배포 가능

## 바로 쓰기

배포 URL (Vercel 연결 후): 이 저장소 → Vercel Import

로컬:

```bash
open index.html
# 또는
npx serve .
```

## Vercel 배포

1. [Vercel](https://vercel.com) → **Add New Project** → `reallygood83/orca` Import  
2. Framework Preset: **Other** (또는 자동 감지)  
3. Build Command: 비움  
4. Output Directory: `.` (루트)  
5. Deploy  

이후 `main` 푸시마다 자동 재배포됩니다.

```bash
# CLI (선택)
npx vercel --yes
```

## 배움의 달인

- [유튜브](https://www.youtube.com/@%EB%B0%B0%EC%9B%80%EC%9D%98%EB%8B%AC%EC%9D%B8-p5v)
- [오픈채팅](https://open.kakao.com/o/gubGYQ7g)
- [뉴스레터](https://newsletter.teaboard.link/)

## 라이선스

개인·교육 목적 사용 환영. Orca 자체 상표·제품은 각 소유자 권리.
