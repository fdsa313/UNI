# 알츠하이머 케어 앱 MCP 서버

## 🚀 개요
이 서버는 알츠하이머 케어 Flutter 앱의 백엔드 API를 제공합니다. 환자 데이터, 퀴즈 결과, 약물 복용 기록 등을 Supabase 데이터베이스에 저장하고 관리합니다.

## 📋 주요 기능

### 🔐 인증
- 사용자 로그인/회원가입
- JWT 토큰 기반 인증 (향후 구현 예정)

### 👥 환자 관리
- 환자별 개별 데이터 저장/조회
- 진행상황 추적
- AI 권장사항 관리

### 📊 데이터 저장
- 퀴즈 결과 저장
- 약물 복용 기록
- 기분 상태 기록
- 인지 능력 점수

## 🛠️ 설치 및 설정

### 1. 의존성 설치
```bash
cd UNI/backend
npm install
```

### 2. 환경 변수 설정
`.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
# 서버 설정
PORT=3000
NODE_ENV=development

# Supabase 설정
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# JWT 시크릿 (향후 구현 예정)
JWT_SECRET=your_jwt_secret
```

### 3. Supabase 프로젝트 설정
1. [Supabase](https://supabase.com)에서 새 프로젝트 생성
2. 프로젝트 URL과 API 키 복사
3. `.env` 파일에 입력

### 4. 데이터베이스 테이블 생성
Supabase SQL 편집기에서 `database_setup.sql` 파일의 내용을 실행하세요:

```sql
-- database_setup.sql 파일의 내용을 복사하여 실행
```

## 🚀 서버 실행

### 개발 모드
```bash
npm run dev
```

### 프로덕션 모드
```bash
npm start
```

서버는 `http://localhost:3000`에서 실행됩니다.

## 📡 API 엔드포인트

### 인증
- `POST /api/auth/login` - 로그인
- `POST /api/auth/register` - 회원가입

### 환자 데이터
- `GET /api/patients/:patientName/data` - 환자 데이터 조회
- `POST /api/patients/:patientName/data` - 환자 데이터 저장/업데이트

### 퀴즈
- `POST /api/patients/:patientName/quiz` - 퀴즈 결과 저장

### 약물
- `POST /api/patients/:patientName/medication` - 약물 복용 기록 저장
- `GET /api/medications` - 약물 정보 조회

### 기분
- `POST /api/moods` - 기분 기록 저장

## 🗄️ 데이터베이스 구조

### 주요 테이블
- `patient_records` - 환자 기본 정보 및 통합 데이터
- `quiz_results` - 퀴즈 결과 상세 기록
- `medication_logs` - 약물 복용 일별 기록
- `mood_logs` - 기분 상태 일별 기록

### 데이터 관계
```
patient_records (1) ←→ (N) quiz_results
patient_records (1) ←→ (N) medication_logs
patient_records (1) ←→ (N) mood_logs
```

## 🔧 개발 가이드

### 새 API 엔드포인트 추가
1. `src/index.js`에 라우트 추가
2. 필요한 경우 컨트롤러 분리
3. 데이터베이스 스키마 업데이트

### 에러 처리
모든 API는 일관된 에러 응답 형식을 사용합니다:

```json
{
  "success": false,
  "message": "에러 메시지"
}
```

### 로깅
서버는 모든 API 호출과 에러를 콘솔에 로깅합니다.

## 🧪 테스트

### API 테스트
```bash
# 서버 상태 확인
curl http://localhost:3000/api/test

# 환자 데이터 조회
curl http://localhost:3000/api/patients/김철수님/data
```

## 📱 Flutter 앱 연동

Flutter 앱에서 이 서버를 사용하려면:

1. `ApiService`에서 `baseUrl`을 서버 주소로 설정
2. 각 화면에서 API 호출하여 데이터 저장/조회
3. 에러 처리 및 로딩 상태 관리

## 🚨 주의사항

- 개발 환경에서는 CORS가 모든 origin을 허용합니다
- 프로덕션 환경에서는 적절한 CORS 설정이 필요합니다
- Supabase API 키는 안전하게 관리해야 합니다

## 🔮 향후 계획

- [ ] JWT 토큰 기반 인증
- [ ] 데이터 백업 및 복구
- [ ] 실시간 알림 (WebSocket)
- [ ] 데이터 분석 및 리포트 생성
- [ ] 다국어 지원

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 등록해 주세요.
