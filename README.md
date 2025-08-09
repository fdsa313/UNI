# 알츠하이머 케어 앱 (Alzheimer Care App)

## 📱 프로젝트 소개

알츠하이머 환자와 보호자를 위한 종합 케어 애플리케이션입니다. 환자의 약물 관리, 기분 체크, 긴급 연락처 기능과 보호자의 관리 기능을 제공합니다.

## ✨ 주요 기능

### 🏠 환자 모드
- **긴급 전화**: 보호자, 응급실, 담당의사 연락
- **약물 관리**: 복용 시간 알림 및 복용 기록
- **기분 체크**: 일일 기분 상태 기록
- **다음 복용 시간**: 타이머 기능

### 👨‍⚕️ 보호자 모드
- **약물 설정**: 복용 시간, 약물 정보 관리
- **퀴즈 설정**: 환자가 풀 퀴즈 선택
- **환자 관리**: 환자 정보, 상태 관리
- **복용 기록**: 약 복용 이력 확인
- **진행 상황**: 퀴즈 결과, 활동 분석
- **긴급 연락처**: 응급 상황 연락처 관리

### 🔐 인증 시스템
- 회원가입 (환자/보호자 연락처 포함)
- 로그인/로그아웃
- 사용자별 맞춤 인사말

### 🎬 특별 기능
- **앱 종료 시 가족 영상 재생**: 15초 카운트다운과 함께 가족 영상 재생

## 🛠 기술 스택

### Frontend
- **Flutter** - 크로스 플랫폼 모바일 앱 개발
- **Dart** - 프로그래밍 언어
- **HTTP** - API 통신
- **SharedPreferences** - 로컬 데이터 저장

### Backend
- **Node.js** - 서버 런타임
- **Express.js** - 웹 프레임워크
- **CORS** - 크로스 오리진 리소스 공유
- **JSON** - 데이터 형식

## 📦 설치 및 실행

### 1. 저장소 클론
```bash
git clone https://github.com/fdsa313/UNI.git
cd UNI
```

### 2. 백엔드 서버 실행
```bash
cd backend
npm install
npm run dev
```

### 3. Flutter 앱 실행
```bash
cd alzheimer_care_app
flutter pub get
flutter run -d chrome
```

## 🚀 사용 방법

### 회원가입
1. 앱 실행 후 "회원가입" 클릭
2. 이름, 이메일, 환자 연락처, 보호자 연락처, 비밀번호 입력
3. 전화번호는 자동으로 010-0000-0000 형식으로 포맷팅

### 로그인
1. 이메일과 비밀번호 입력
2. 로그인 성공 시 사용자 이름으로 맞춤 인사말 표시

### 환자 모드 사용
1. 홈 화면에서 긴급 전화, 약물 복용, 기분 체크
2. 상단 우측 아이콘 클릭으로 보호자 모드 진입

### 보호자 모드 사용
1. 비밀번호 입력 후 보호자 모드 진입
2. 약물 설정, 퀴즈 설정 등 관리 기능 사용

## 📁 프로젝트 구조

```
UNI/
├── alzheimer_care_app/          # Flutter 앱
│   ├── lib/
│   │   ├── screens/            # 화면들
│   │   ├── services/           # API 서비스
│   │   └── main.dart           # 앱 진입점
│   └── pubspec.yaml            # Flutter 의존성
├── backend/                     # Node.js 서버
│   ├── src/
│   │   └── index.js            # 서버 메인 파일
│   └── package.json            # Node.js 의존성
└── README.md                   # 프로젝트 설명
```

## 🔧 API 엔드포인트

### 인증
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인

### 약물 관리
- `GET /api/medications` - 약물 목록 조회
- `POST /api/medications` - 약물 정보 저장

### 기록
- `POST /api/medication-logs` - 복용 기록 저장
- `POST /api/moods` - 기분 기록 저장

## 🎨 UI/UX 특징

- **따뜻한 색상**: 오렌지 계열의 따뜻한 색상 사용
- **직관적 인터페이스**: 알츠하이머 환자도 쉽게 사용 가능
- **큰 버튼과 텍스트**: 시력이 좋지 않은 사용자를 고려
- **긴급 기능 강조**: 빨간색으로 긴급 전화 버튼 강조

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 👥 개발팀

- **Frontend**: Flutter/Dart
- **Backend**: Node.js/Express
- **Database**: In-memory (개발용)

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 GitHub Issues를 통해 연락해주세요.

---

**알츠하이머 케어 앱으로 사랑하는 가족을 더욱 따뜻하게 케어하세요!** ❤️
