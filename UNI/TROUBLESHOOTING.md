# 보호자모드 비밀번호 설정 문제 해결 가이드

## 🔍 문제 상황
보호자모드에 진입할 때 설정하는 비밀번호가 계속 오류가 발생하는 경우

## 🚨 주요 오류 원인

### 1. Supabase 인증 문제
- **로그**: `❌ 로그인된 사용자가 없음`
- **원인**: Supabase Auth 세션이 제대로 설정되지 않음
- **해결**: 로그인 후 로컬 사용자 데이터 저장 방식으로 우회

### 2. 데이터베이스 테이블 문제
- **로그**: `❌ caregiver_passwords 테이블이 존재하지 않음`
- **원인**: 필요한 데이터베이스 테이블이 생성되지 않음
- **해결**: SQL 스크립트 실행으로 테이블 생성

### 3. 네트워크 연결 문제
- **로그**: `Failed to fetch`, `AuthRetryableFetchException`
- **원인**: 인터넷 연결 또는 Supabase 서버 접근 문제
- **해결**: 네트워크 연결 확인 및 Supabase 설정 검증

## 🛠️ 단계별 해결 방법

### Step 1: 데이터베이스 테이블 생성

Supabase SQL 편집기에서 다음 명령어를 실행하세요:

```sql
-- 보호자 비밀번호 테이블 생성
CREATE TABLE IF NOT EXISTS caregiver_passwords (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_caregiver_passwords_user_id ON caregiver_passwords(user_id);

-- RLS 정책 설정
ALTER TABLE caregiver_passwords ENABLE ROW LEVEL SECURITY;

-- 사용자 자신의 비밀번호만 접근 가능하도록 정책 설정
CREATE POLICY "Users can manage their own caregiver passwords" ON caregiver_passwords
    FOR ALL USING (auth.uid() = user_id);
```

### Step 2: 앱에서 로그인 테스트

1. 앱을 완전히 종료
2. 다시 실행하여 로그인
3. 콘솔에서 다음 로그 확인:
   ```
   ✅ Supabase 초기화 성공
   로그인 시도: [이메일]
   ✅ Supabase 사용자 데이터 로컬 저장 완료
   ```

### Step 3: 보호자모드 진입 테스트

1. 홈 화면에서 보호자모드 아이콘 클릭
2. 콘솔에서 다음 로그 확인:
   ```
   === 보호자 비밀번호 존재 여부 확인 ===
   Supabase Auth 사용자: [사용자ID 또는 null]
   ✅ 로컬 사용자 데이터 발견: [이메일]
   ✅ 사용자 ID: [사용자ID]
   ```

### Step 4: 비밀번호 설정 테스트

1. 새 비밀번호 입력 (4자 이상)
2. 비밀번호 확인 입력
3. "비밀번호 설정" 버튼 클릭
4. 콘솔에서 다음 로그 확인:
   ```
   === 비밀번호 설정 시도 ===
   ✅ caregiver_passwords 테이블 존재 확인
   ✅ 새 비밀번호 생성 응답: [응답]
   ✅ 비밀번호 설정 성공!
   ```

## 🔧 추가 디버깅

### 로그 확인 방법
1. Flutter 앱 실행 시 콘솔 출력 모니터링
2. `flutter run -d chrome` 실행 후 브라우저 개발자 도구 확인
3. Supabase 대시보드에서 실시간 로그 확인

### 일반적인 오류 메시지

| 오류 메시지 | 원인 | 해결 방법 |
|------------|------|-----------|
| `❌ 로그인된 사용자가 없음` | Supabase 세션 문제 | 로그인 후 재시도 |
| `❌ caregiver_passwords 테이블이 존재하지 않음` | DB 테이블 누락 | SQL 스크립트 실행 |
| `❌ Supabase 연결 실패` | 네트워크/설정 문제 | 연결 상태 및 API 키 확인 |
| `❌ 데이터베이스 작업 중 오류` | 권한/구조 문제 | RLS 정책 및 테이블 구조 확인 |

## ✅ 성공 확인 방법

### 1. 비밀번호 설정 성공
- ✅ 성공 메시지: "비밀번호가 성공적으로 설정되었습니다."
- ✅ 화면 전환: 비밀번호 입력 화면으로 변경

### 2. 보호자 모드 진입 성공
- ✅ 비밀번호 입력 후 보호자 모드 화면으로 이동
- ✅ 보호자 모드 기능 정상 작동

### 3. 비밀번호 초기화 성공
- ✅ 초기화 후 비밀번호 설정 화면으로 복귀
- ✅ 새로운 비밀번호 재설정 가능

## 🚀 예방 방법

### 1. 정기적인 테스트
- 앱 업데이트 후 보호자모드 기능 테스트
- 새로운 사용자 계정으로 기능 검증

### 2. 모니터링
- Supabase 대시보드에서 에러 로그 확인
- 앱 콘솔에서 디버그 메시지 모니터링

### 3. 백업 및 복구
- 정기적인 데이터베이스 백업
- 문제 발생 시 이전 상태로 복구 가능하도록 준비

## 📞 추가 지원

문제가 지속되면 다음 정보를 포함하여 문의해주세요:

1. **오류 로그**: 콘솔에 표시된 전체 오류 메시지
2. **재현 단계**: 문제가 발생하는 정확한 단계
3. **환경 정보**: Flutter 버전, 디바이스 정보
4. **Supabase 설정**: 프로젝트 URL, API 키 (민감 정보 제외)

---

**참고**: 이 가이드는 현재 구현된 로컬 사용자 데이터 저장 방식을 기반으로 합니다. 향후 Supabase Auth 통합이 완료되면 더 안정적인 인증 방식으로 전환될 예정입니다.
