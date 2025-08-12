# 알츠하이머 케어 앱

## 프로젝트 개요
알츠하이머 환자와 보호자를 위한 Flutter 기반 모바일 애플리케이션입니다.

## 주요 기능
- 환자 모드: 약물 복용 알림, 퀴즈, 기분 체크
- 보호자 모드: 환자 관리, 진행 상황 모니터링
- 비상 연락처 관리
- 앱 종료 방지

## 보호자모드 비밀번호 설정 문제 해결

### 문제 상황
보호자모드에 진입할 때 설정하는 비밀번호가 계속 오류가 발생하는 경우

### 해결 방법

#### 1. 데이터베이스 테이블 확인
기존 `users` 테이블에 `caregiver_password` 칼럼이 있는지 확인하세요:

```sql
-- users 테이블 구조 확인
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'caregiver_password';
```

#### 2. 칼럼이 없는 경우 추가
`caregiver_password` 칼럼이 없다면 다음 명령어로 추가하세요:

```sql
-- users 테이블에 보호자 비밀번호 칼럼 추가
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS caregiver_password VARCHAR(255);

-- 기존 데이터가 있다면 NULL로 설정
UPDATE users 
SET caregiver_password = NULL 
WHERE caregiver_password IS NULL;
```

#### 3. Supabase RLS 정책 설정
`users` 테이블에 대한 Row Level Security 정책을 설정하세요:

```sql
-- RLS 활성화
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 사용자 자신의 정보만 접근 가능하도록 정책 설정
CREATE POLICY "Users can manage their own data" ON users
    FOR ALL USING (auth.uid()::text = id::text);
```

#### 4. 앱에서 로그인 상태 확인
보호자 비밀번호를 설정하기 전에 Supabase에 로그인되어 있는지 확인하세요.

#### 5. 디버그 로그 확인
앱 실행 시 콘솔에서 다음 로그를 확인하세요:
- `=== 보호자 비밀번호 설정 시작 ===`
- `✅ Supabase 클라이언트 상태: 연결됨`
- `✅ 현재 사용자: [이메일]`

### 일반적인 오류 원인

1. **Supabase 연결 실패**
   - 인터넷 연결 확인
   - Supabase URL과 API 키 확인

2. **사용자 인증 실패**
   - 앱에서 로그아웃 후 다시 로그인
   - Supabase Auth 상태 확인

3. **데이터베이스 권한 문제**
   - RLS 정책 설정 확인
   - 사용자 권한 확인

4. **테이블 구조 문제**
   - 테이블 스키마 확인
   - 필수 컬럼 존재 여부 확인

### 문제 해결 후 확인사항

1. 비밀번호 설정 성공 메시지 표시
2. 보호자 모드 진입 시 비밀번호 입력 화면 표시
3. 비밀번호 초기화 기능 정상 작동

## 개발 환경 설정

### 필수 요구사항
- Flutter 3.0+
- Dart 3.0+
- Supabase 계정 및 프로젝트

### 설치 및 실행
```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 환경 변수 설정
`.env` 파일에 Supabase 설정을 추가하세요:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 기술 스택
- **Frontend**: Flutter, Dart
- **Backend**: Supabase (PostgreSQL, Auth, Real-time)
- **State Management**: Provider
- **Database**: PostgreSQL

## 라이선스
이 프로젝트는 MIT 라이선스 하에 배포됩니다.
