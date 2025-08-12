const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// 데이터베이스 파일 경로
const dbPath = path.join(__dirname, '../../database.sqlite');

// 데이터베이스 연결
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('데이터베이스 연결 오류:', err.message);
  } else {
    console.log('✅ SQLite 데이터베이스에 연결되었습니다:', dbPath);
    initDatabase();
  }
});

// 데이터베이스 초기화
function initDatabase() {
  // 환자 기록 테이블 생성
  db.run(`
    CREATE TABLE IF NOT EXISTS patient_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_name TEXT UNIQUE NOT NULL,
      quiz_results TEXT DEFAULT '[]',
      medication_history TEXT DEFAULT '[]',
      mood_trend TEXT DEFAULT '[]',
      cognitive_score REAL DEFAULT 0.0,
      recommendations TEXT DEFAULT '[]',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `, (err) => {
    if (err) {
      console.error('환자 기록 테이블 생성 오류:', err.message);
    } else {
      console.log('✅ 환자 기록 테이블이 생성되었습니다.');
    }
  });

  // 사용자 테이블 생성
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      name TEXT NOT NULL,
      role TEXT NOT NULL,
      patient_phone TEXT,
      caregiver_phone TEXT,
      caregiver_password TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `, (err) => {
    if (err) {
      console.error('사용자 테이블 생성 오류:', err.message);
    } else {
      console.log('✅ 사용자 테이블이 생성되었습니다.');
    }
  });

  // 약물 복용 기록 테이블 생성
  db.run(`
    CREATE TABLE IF NOT EXISTS medication_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_name TEXT NOT NULL,
      date TEXT NOT NULL,
      morning BOOLEAN DEFAULT 0,
      lunch BOOLEAN DEFAULT 0,
      evening BOOLEAN DEFAULT 0,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(patient_name, date)
    )
  `, (err) => {
    if (err) {
      console.error('약물 복용 기록 테이블 생성 오류:', err.message);
    } else {
      console.log('✅ 약물 복용 기록 테이블이 생성되었습니다.');
    }
  });
}

// 데이터베이스 연결 종료
function closeDatabase() {
  db.close((err) => {
    if (err) {
      console.error('데이터베이스 연결 종료 오류:', err.message);
    } else {
      console.log('✅ 데이터베이스 연결이 종료되었습니다.');
    }
  });
}

module.exports = {
  db,
  closeDatabase
};
