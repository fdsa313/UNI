# Alzheimer Care App

알츠하이머 환자와 보호자를 위한 케어 앱입니다.

## 🚀 주요 기능

### 환자 모드
- **앱 종료 방지**: 실수로 앱을 종료하는 것을 방지
- **약물 복용 관리**: 복용 시간 알림 및 약물 정보 관리
- **퀴즈 활동**: 인지 능력 향상을 위한 퀴즈 제공
- **긴급 연락처**: 응급 상황 시 빠른 연락처 연결

### 보호자 모드
- **환자 위치 찾기**: GPS를 통한 실시간 위치 추적 및 확인
- **약물 설정**: 복용 시간, 약물 정보 관리
- **퀴즈 설정**: 환자가 풀 퀴즈 선택 및 난이도 조정
- **환자 관리**: 환자 정보, 상태 관리
- **진행 상황**: AI 보고서, 활동 분석
- **긴급 연락처**: 응급 상황 연락처 관리

## 📱 위치 찾기 기능

### GPS 위치 추적
- **실시간 위치 확인**: 환자의 현재 위치를 정확한 GPS 좌표로 확인
- **주소 변환**: GPS 좌표를 읽기 쉬운 주소로 자동 변환
- **위치 추적**: 실시간으로 환자의 위치 변화를 모니터링
- **정확도 표시**: 위치 정확도를 미터 단위로 표시

### 지도 표시 기능
- **앱 내 지도**: OpenStreetMap을 사용한 내장 지도
- **실시간 마커**: 환자의 현재 위치를 지도에 파란색 마커로 표시
- **위치 정보 오버레이**: 지도 상단에 상세한 위치 정보 표시
- **부드러운 이동**: 위치 변경 시 지도가 자동으로 환자 위치로 이동

### 사용 방법
1. 보호자 모드에서 "환자 위치 찾기" 메뉴 선택
2. "현재 위치 찾기" 버튼으로 즉시 위치 확인
3. "실시간 위치 추적" 버튼으로 지속적인 모니터링
4. **"앱 내 지도"** 버튼으로 내장 지도에서 위치 확인
5. "외부 지도" 버튼으로 외부 지도 앱에서 위치 확인

### 권한 요구사항
- **Android**: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- **iOS**: `NSLocationWhenInUseUsageDescription`

## 🛠️ 기술 스택

### Frontend
- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Dart**: 프로그래밍 언어

### Backend
- **Supabase**: 백엔드 서비스 (인증, 데이터베이스)
- **Node.js**: 서버 사이드 로직

### 위치 서비스
- **geolocator**: GPS 위치 추적
- **geocoding**: 좌표-주소 변환
- **permission_handler**: 권한 관리
- **flutter_map**: OpenStreetMap 기반 지도 표시
- **latlong2**: 지도 좌표 시스템

## 📋 설치 및 실행

### 필수 요구사항
- Flutter SDK 3.8.1 이상
- Dart SDK
- Android Studio / Xcode (모바일 개발용)

### 설치 단계
1. 저장소 클론
```bash
git clone https://github.com/fdsa313/AlzheimerUnithon.git
cd AlzheimerUnithon/UNI/alzheimer_care_app
```

2. 의존성 설치
```bash
flutter pub get
```

3. 앱 실행
```bash
# 웹 버전
flutter run -d chrome

# 모바일 버전
flutter run
```

## 🔧 설정

### 환경 변수
`.env` 파일을 생성하고 다음 정보를 입력하세요:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 데이터베이스 설정
Supabase에서 다음 테이블을 생성해야 합니다:
```sql
-- 사용자 테이블에 보호자 비밀번호 컬럼 추가
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS caregiver_password VARCHAR(255);
```

## 🚨 문제 해결

### 위치 권한 문제
- **Android**: 설정 > 앱 > 권한에서 위치 권한 허용
- **iOS**: 설정 > 개인정보 보호 및 보안 > 위치 서비스에서 허용

### GPS 연결 문제
- GPS가 활성화되어 있는지 확인
- 실외에서 테스트 (실내에서는 정확도가 떨어질 수 있음)
- 인터넷 연결 상태 확인

### 보호자 모드 접근 문제
- 보호자 비밀번호가 설정되어 있는지 확인
- 비밀번호를 잊어버린 경우 "비밀번호 초기화" 기능 사용

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 👥 기여자

UNITHON 팀

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 등록해 주세요.
