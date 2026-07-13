# Orca 조율 스튜디오

**누구나 자기만의 Orca 조율 모드**를 만들고, 자기 컴퓨터에 설치할 수 있게 돕는 정적 웹 도구입니다.

- 서버에 설정이 저장되지 않음 (브라우저에서만 생성)
- 사람마다 팀장/실무 AI·모드 이름을 다르게 설정 가능
- 변수 변경 → 설치 안내·다운로드 `.md`·AI 설치 요청문이 **그 사용자 설정으로** 맞춤 생성
- JinJing 등 **특정 PC 전용 파일 불필요**

## 사용자 흐름

1. 사이트 접속  
2. 조율이 뭔지 보기 (탭 1–2)  
3. 내 모드 정하기 (탭 3)  
4. 설치 방법 / `.md` 다운로드 / AI 요청문 복사 (탭 4)  
5. 자기 `$HOME/.orca/<모드>/` 에 저장 + Orca Quick Command 등록  

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

## 배움의 달인

- [유튜브](https://www.youtube.com/@%EB%B0%B0%EC%9B%80%EC%9D%98%EB%8B%AC%EC%9D%B8-p5v)
- [오픈채팅](https://open.kakao.com/o/gubGYQ7g)
- [뉴스레터](https://newsletter.teaboard.link/)

## 라이선스

개인·교육 목적 사용 환영. Orca 상표·제품은 각 소유자 권리.
