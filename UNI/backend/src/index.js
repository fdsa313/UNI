const express = require('express');
const cors = require('cors');
require('dotenv').config();
const supabase = require('./config/supabase');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어
app.use(cors({
  origin: true, // 모든 origin 허용 (개발 환경에서만)
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));
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
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    console.log('로그인 시도:', { email, password });
    
    // Supabase에서 사용자 찾기
    const { data: users, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .eq('password', password)
      .limit(1);
    
    if (error) {
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.'
      });
    }
    
    console.log('조회된 사용자:', users);
    
    if (users && users.length > 0) {
      const user = users[0];
      res.json({
        success: true,
        message: '로그인이 완료되었습니다.',
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            patientPhone: user.patient_phone,
            caregiverPhone: user.caregiver_phone
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
  } catch (error) {
    console.error('로그인 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 회원가입 API
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, name, patientPhone, caregiverPhone } = req.body;
    
    console.log('회원가입 시도:', { email, name, patientPhone, caregiverPhone });
    
    // 필수 필드 검증
    if (!email || !password || !name || !patientPhone || !caregiverPhone) {
      return res.status(400).json({
        success: false,
        message: '모든 필드를 입력해주세요.'
      });
    }
    
    // 이메일 중복 확인
    const { data: existingUsers, error: checkError } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .limit(1);
    
    if (checkError) {
      console.error('중복 확인 오류:', checkError);
      return res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.'
      });
    }
    
    if (existingUsers && existingUsers.length > 0) {
      return res.status(400).json({
        success: false,
        message: '이미 존재하는 이메일입니다.'
      });
    }
    
    // 새 사용자 생성
    const { data: newUser, error: insertError } = await supabase
      .from('users')
      .insert([
        {
          email,
          password,
          name,
          role: 'patient',
          patient_phone: patientPhone,
          caregiver_phone: caregiverPhone
        }
      ])
      .select()
      .single();
    
    if (insertError) {
      console.error('사용자 생성 오류:', insertError);
      return res.status(500).json({
        success: false,
        message: '회원가입에 실패했습니다.'
      });
    }
    
    console.log('새 사용자 등록 성공:', newUser);
    
    res.status(201).json({
      success: true,
      message: '회원가입이 완료되었습니다.',
      data: {
        user: {
          id: newUser.id,
          email: newUser.email,
          name: newUser.name,
          role: newUser.role,
          patientPhone: newUser.patient_phone,
          caregiverPhone: newUser.caregiver_phone
        },
        token: `token-${Date.now()}`
      }
    });
  } catch (error) {
    console.error('회원가입 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
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

// 환자 데이터 저장 API
app.post('/api/patients/:patientName/data', async (req, res) => {
  try {
    const { patientName } = req.params;
    const { quizResults, medicationHistory, moodTrend, cognitiveScore, recommendations } = req.body;
    
    console.log('환자 데이터 저장 시도:', { patientName, quizResults, medicationHistory, moodTrend, cognitiveScore });
    
    // Supabase에 환자 데이터 저장/업데이트
    const { data, error } = await supabase
      .from('patient_records')
      .upsert({
        patient_name: patientName,
        quiz_results: quizResults,
        medication_history: medicationHistory,
        mood_trend: moodTrend,
        cognitive_score: cognitiveScore,
        recommendations: recommendations,
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'patient_name'
      });
    
    if (error) {
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '데이터 저장 중 오류가 발생했습니다.'
      });
    }
    
    console.log('환자 데이터 저장 성공:', data);
    
    res.status(201).json({
      success: true,
      message: '환자 데이터가 저장되었습니다.',
      data: data
    });
  } catch (error) {
    console.error('환자 데이터 저장 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 환자 데이터 조회 API
app.get('/api/patients/:patientName/data', async (req, res) => {
  try {
    const { patientName } = req.params;
    
    console.log('환자 데이터 조회 시도:', patientName);
    
    // Supabase에서 환자 데이터 조회
    const { data, error } = await supabase
      .from('patient_records')
      .select('*')
      .eq('patient_name', patientName)
      .single();
    
    if (error) {
      if (error.code === 'PGRST116') {
        // 데이터가 없는 경우
        return res.status(404).json({
          success: false,
          message: '환자 데이터를 찾을 수 없습니다.'
        });
      }
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '데이터 조회 중 오류가 발생했습니다.'
      });
    }
    
    console.log('환자 데이터 조회 성공:', data);
    
    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('환자 데이터 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 퀴즈 결과 저장 API
app.post('/api/patients/:patientName/quiz', async (req, res) => {
  try {
    const { patientName } = req.params;
    const { score, total, time, date } = req.body;
    
    console.log('퀴즈 결과 저장 시도:', { patientName, score, total, time, date });
    
    // Supabase에 퀴즈 결과 저장
    const { data, error } = await supabase
      .from('quiz_results')
      .insert({
        patient_name: patientName,
        score: score,
        total: total,
        time: time,
        date: date,
        created_at: new Date().toISOString()
      });
    
    if (error) {
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '퀴즈 결과 저장 중 오류가 발생했습니다.'
      });
    }
    
    console.log('퀴즈 결과 저장 성공:', data);
    
    res.status(201).json({
      success: true,
      message: '퀴즈 결과가 저장되었습니다.',
      data: data
    });
  } catch (error) {
    console.error('퀴즈 결과 저장 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 약물 복용 기록 저장 API
app.post('/api/patients/:patientName/medication', async (req, res) => {
  try {
    const { patientName } = req.params;
    const { date, morning, lunch, evening } = req.body;
    
    console.log('약물 복용 기록 저장 시도:', { patientName, date, morning, lunch, evening });
    
    // Supabase에 약물 복용 기록 저장
    const { data, error } = await supabase
      .from('medication_logs')
      .upsert({
        patient_name: patientName,
        date: date,
        morning: morning,
        lunch: lunch,
        evening: evening,
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'patient_name,date'
      });
    
    if (error) {
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '약물 복용 기록 저장 중 오류가 발생했습니다.'
      });
    }
    
    console.log('약물 복용 기록 저장 성공:', data);
    
    res.status(201).json({
      success: true,
      message: '약물 복용 기록이 저장되었습니다.',
      data: data
    });
  } catch (error) {
    console.error('약물 복용 기록 저장 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// ===== 영상 API =====
// 메모리 샘플 데이터 (개발용)
const videosData = [
  {
    id: 'vid-1',
    title: '가족의 응원 영상',
    description: '앱 종료 시 재생되는 가족의 응원 메시지',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    thumbnailUrl: 'https://i.ytimg.com/vi/aqz-KE-bpKQ/hqdefault.jpg',
    category: 'exit',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

// 모든 영상 목록
app.get('/api/videos', (req, res) => {
  res.json(videosData);
});

// 특정 영상 조회
app.get('/api/videos/:id', (req, res) => {
  const video = videosData.find(v => v.id === req.params.id);
  if (!video) {
    return res.status(404).json({
      success: false,
      message: '영상을 찾을 수 없습니다.'
    });
  }
  res.json(video);
});

// 약물 복용 기록 조회 API
app.get('/api/patients/:patientName/medication/:date', async (req, res) => {
  try {
    const { patientName, date } = req.params;
    
    console.log('약물 복용 기록 조회 시도:', { patientName, date });
    
    // Supabase에서 약물 복용 기록 조회
    const { data, error } = await supabase
      .from('medication_logs')
      .select('*')
      .eq('patient_name', patientName)
      .eq('date', date)
      .single();
    
    if (error) {
      if (error.code === 'PGRST116') {
        // 데이터가 없는 경우
        return res.status(404).json({
          success: false,
          message: '약물 복용 기록을 찾을 수 없습니다.'
        });
      }
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '데이터 조회 중 오류가 발생했습니다.'
      });
    }
    
    console.log('약물 복용 기록 조회 성공:', data);
    
    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('약물 복용 기록 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`🚀 서버가 포트 ${PORT}에서 실행 중입니다.`);
  console.log(`📱 API 문서: http://localhost:${PORT}`);
  console.log(`🔐 인증 엔드포인트: http://localhost:${PORT}/api/auth`);
});

module.exports = app;
