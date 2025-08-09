const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// 사용자 정보를 저장할 배열
const users = [
  {
    id: 'test-user-id',
    email: 'test@test.com',
    password: 'password123',
    name: '테스트 사용자',
    role: 'patient',
    patientPhone: '010-1234-5678',
    caregiverPhone: '010-8765-4321'
  }
];

// 미들웨어
app.use(cors());
app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '알츠하이머 케어 앱 API 서버',
    version: '1.0.0'
  });
});

// 테스트 라우트
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'API 서버가 정상적으로 작동합니다!'
  });
});

// 로그인 API
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // 저장된 사용자 중에서 찾기
  const user = users.find(u => u.email === email && u.password === password);
  
  if (user) {
    res.json({
      success: true,
      message: '로그인이 완료되었습니다.',
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          patientPhone: user.patientPhone,
          caregiverPhone: user.caregiverPhone
        },
        token: `token-${Date.now()}`
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: '이메일 또는 비밀번호가 올바르지 않습니다.'
    });
  }
});

// 회원가입 API
app.post('/api/auth/register', (req, res) => {
  const { email, password, name, patientPhone, caregiverPhone } = req.body;
  
  // 필수 필드 검증
  if (!email || !password || !name || !patientPhone || !caregiverPhone) {
    return res.status(400).json({
      success: false,
      message: '모든 필드를 입력해주세요.'
    });
  }
  
  // 이메일 중복 확인
  const existingUser = users.find(user => user.email === email);
  if (existingUser) {
    return res.status(400).json({
      success: false,
      message: '이미 존재하는 이메일입니다.'
    });
  }
  
  // 새 사용자 생성
  const newUser = {
    id: `user-${Date.now()}`,
    email,
    password,
    name,
    role: 'patient', // 기본값
    patientPhone,
    caregiverPhone
  };
  
  users.push(newUser);
  
  console.log('새 사용자 등록:', { email, name, patientPhone, caregiverPhone });
  
  res.status(201).json({
    success: true,
    message: '회원가입이 완료되었습니다.',
    data: {
      user: {
        id: newUser.id,
        email: newUser.email,
        name: newUser.name,
        role: newUser.role,
        patientPhone: newUser.patientPhone,
        caregiverPhone: newUser.caregiverPhone
      },
      token: `token-${Date.now()}`
    }
  });
});

// 약물 정보 API
app.get('/api/medications', (req, res) => {
  res.json({
    success: true,
    medications: [
      {
        id: 'med-1',
        name: '혈압약',
        time: '08:00',
        dosage: '1정',
        instructions: '식후 30분 복용'
      },
      {
        id: 'med-2', 
        name: '당뇨약',
        time: '12:00',
        dosage: '1정',
        instructions: '식전 30분 복용'
      }
    ]
  });
});

// 약물 정보 저장 API
app.post('/api/medications', (req, res) => {
  const { name, time, dosage, instructions } = req.body;
  
  const newMedication = {
    id: `med-${Date.now()}`,
    name,
    time,
    dosage,
    instructions
  };
  
  res.status(201).json({
    success: true,
    medication: newMedication
  });
});

// 복용 기록 저장 API
app.post('/api/medication-logs', (req, res) => {
  const { medicationId, time, takenAt } = req.body;
  
  res.status(201).json({
    success: true,
    message: '복용 기록이 저장되었습니다.'
  });
});

// 기분 기록 저장 API
app.post('/api/moods', (req, res) => {
  const { mood, recordedAt } = req.body;
  
  res.status(201).json({
    success: true,
    message: '기분 기록이 저장되었습니다.'
  });
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`🚀 서버가 포트 ${PORT}에서 실행 중입니다.`);
  console.log(`📱 API 문서: http://localhost:${PORT}`);
  console.log(`🔐 인증 엔드포인트: http://localhost:${PORT}/api/auth`);
});

module.exports = app;
