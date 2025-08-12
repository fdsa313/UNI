-- Supabase 테이블 설정 스크립트
-- 이 스크립트를 Supabase SQL Editor에서 실행하세요

-- 1. 사용자 테이블 생성
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'patient',
  patient_phone TEXT,
  caregiver_phone TEXT,
  caregiver_password TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 환자 기록 테이블 생성
CREATE TABLE IF NOT EXISTS patient_records (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  patient_name TEXT UNIQUE NOT NULL,
  quiz_results JSONB DEFAULT '[]'::jsonb,
  medication_history JSONB DEFAULT '[]'::jsonb,
  mood_trend JSONB DEFAULT '[]'::jsonb,
  cognitive_score REAL DEFAULT 0.0,
  recommendations JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 약물 복용 기록 테이블 생성
CREATE TABLE IF NOT EXISTS medication_logs (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  patient_name TEXT NOT NULL,
  date TEXT NOT NULL,
  morning BOOLEAN DEFAULT false,
  lunch BOOLEAN DEFAULT false,
  evening BOOLEAN DEFAULT false,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(patient_name, date)
);

-- 4. 퀴즈 결과 테이블 생성
CREATE TABLE IF NOT EXISTS quiz_results (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  patient_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  total INTEGER NOT NULL,
  time INTEGER NOT NULL,
  date TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 인덱스 생성 (성능 향상)
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_patient_records_name ON patient_records(patient_name);
CREATE INDEX IF NOT EXISTS idx_medication_logs_patient_date ON medication_logs(patient_name, date);
CREATE INDEX IF NOT EXISTS idx_quiz_results_patient ON quiz_results(patient_name);

-- 6. RLS (Row Level Security) 활성화
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;

-- 7. RLS 정책 설정 (개발 환경용 - 모든 접근 허용)
CREATE POLICY "Allow all access for development" ON users FOR ALL USING (true);
CREATE POLICY "Allow all access for development" ON patient_records FOR ALL USING (true);
CREATE POLICY "Allow all access for development" ON medication_logs FOR ALL USING (true);
CREATE POLICY "Allow all access for development" ON quiz_results FOR ALL USING (true);

-- 8. 테스트 데이터 삽입 (선택사항)
INSERT INTO users (id, email, password, name, role, patient_phone, caregiver_phone, caregiver_password, created_at) 
VALUES (
  '66207360-dd77-4055-8ad0-42867f2236dc',
  'fdsa2258@naver.com',
  '197413',
  '최명일',
  'patient',
  '010-3717-4019',
  '010-2258-4019',
  '197413',
  '2025-08-12T16:13:29.290886Z'
) ON CONFLICT (id) DO NOTHING;

-- 9. 테이블 정보 확인
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name IN ('users', 'patient_records', 'medication_logs', 'quiz_results')
ORDER BY table_name, ordinal_position;
