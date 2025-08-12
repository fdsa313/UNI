-- 알츠하이머 케어 앱 데이터베이스 테이블 구조

-- 환자 기록 테이블 (메인 테이블)
CREATE TABLE IF NOT EXISTS patient_records (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) UNIQUE NOT NULL,
    quiz_results JSONB DEFAULT '[]',
    medication_history JSONB DEFAULT '[]',
    mood_trend JSONB DEFAULT '[]',
    cognitive_score DECIMAL(5,2) DEFAULT 0.0,
    recommendations TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 퀴즈 결과 테이블 (개별 퀴즈 결과 저장)
CREATE TABLE IF NOT EXISTS quiz_results (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    score INTEGER NOT NULL,
    total INTEGER NOT NULL,
    time VARCHAR(50),
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (patient_name) REFERENCES patient_records(patient_name) ON DELETE CASCADE
);

-- 약물 복용 기록 테이블 (일별 복용 현황)
CREATE TABLE IF NOT EXISTS medication_logs (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    morning BOOLEAN DEFAULT FALSE,
    lunch BOOLEAN DEFAULT FALSE,
    evening BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(patient_name, date)
);

-- 기분 기록 테이블 (일별 기분 상태)
CREATE TABLE IF NOT EXISTS mood_logs (
    id SERIAL PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    mood VARCHAR(50) NOT NULL,
    score INTEGER NOT NULL CHECK (score >= 1 AND score <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(patient_name, date)
);

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('patient', 'caregiver')),
    phone VARCHAR(20),
    caregiver_password VARCHAR(255),  -- 보호자 모드 비밀번호
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 기존 users 테이블에 caregiver_password 칼럼 추가 (이미 존재하는 경우)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'users' AND column_name = 'caregiver_password'
    ) THEN
        ALTER TABLE users ADD COLUMN caregiver_password VARCHAR(255);
    END IF;
END $$;

-- 뷰 생성 (통합 데이터 조회용)
CREATE OR REPLACE VIEW patient_summary AS
SELECT 
    pr.patient_name,
    pr.cognitive_score,
    pr.recommendations,
    COUNT(qr.id) as total_quizzes,
    AVG(CASE WHEN qr.total > 0 THEN (qr.score::DECIMAL / qr.total) * 100 ELSE 0 END) as avg_quiz_score,
    COUNT(ml.id) as total_medication_days,
    AVG(CASE WHEN ml.morning OR ml.lunch OR ml.evening THEN 1.0 ELSE 0.0 END) * 100 as medication_compliance_rate,
    AVG(ml2.score) as avg_mood_score
FROM patient_records pr
LEFT JOIN quiz_results qr ON pr.patient_name = qr.patient_name
LEFT JOIN medication_logs ml ON pr.patient_name = ml.patient_name
LEFT JOIN mood_logs ml2 ON pr.patient_name = ml2.patient_name
GROUP BY pr.patient_name, pr.cognitive_score, pr.recommendations;

-- 샘플 데이터 삽입 (테스트용)
INSERT INTO patient_records (patient_name, quiz_results, medication_history, mood_trend, cognitive_score, recommendations) 
VALUES 
    ('김철수님', 
     '[{"date": "2024-08-11", "score": 4, "total": 5, "time": "15분"}, {"date": "2024-08-10", "score": 3, "total": 5, "time": "20분"}]',
     '[{"date": "2024-08-11", "morning": true, "lunch": true, "evening": false}, {"date": "2024-08-10", "morning": true, "lunch": true, "evening": true}]',
     '[{"date": "2024-08-11", "mood": "좋음", "score": 4}, {"date": "2024-08-10", "mood": "보통", "score": 3}]',
     75.0,
     ARRAY['정기적인 퀴즈 참여로 인지 능력 향상', '약물 복용 시간 준수 필요']
    )
ON CONFLICT (patient_name) DO NOTHING;

-- 인덱스 생성 (성능 향상)
CREATE INDEX IF NOT EXISTS idx_patient_records_name ON patient_records(patient_name);
CREATE INDEX IF NOT EXISTS idx_quiz_results_patient_date ON quiz_results(patient_name, date);
CREATE INDEX IF NOT EXISTS idx_medication_logs_patient_date ON medication_logs(patient_name, date);
CREATE INDEX IF NOT EXISTS idx_mood_logs_patient_date ON mood_logs(patient_name, date);

-- 권한 설정 (필요한 경우)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- 테이블 설명
COMMENT ON TABLE users IS '사용자 정보 및 보호자 비밀번호 테이블';

-- 컬럼 설명
COMMENT ON COLUMN users.id IS '사용자 고유 ID';
COMMENT ON COLUMN users.email IS '사용자 이메일';
COMMENT ON COLUMN users.name IS '사용자 이름';
COMMENT ON COLUMN users.role IS '사용자 역할 (patient: 환자, caregiver: 보호자)';
COMMENT ON COLUMN users.phone IS '사용자 전화번호';
COMMENT ON COLUMN users.caregiver_password IS '보호자 모드 진입용 비밀번호';
COMMENT ON COLUMN users.created_at IS '생성 시간';
COMMENT ON COLUMN users.updated_at IS '수정 시간';
