const express = require('express');
const cors = require('cors');
require('dotenv').config();
const supabase = require('./config/supabase');

const app = express();
const PORT = process.env.PORT || 3000;

// 미들웨어
app.use(cors());
app.use(express.json());

// 기본 라우트
app.get('/', (req, res) => {
  res.json({
    message: 'Alzheimer Care App Backend API',
    version: '1.0.0',
    status: 'running'
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
            caregiverPhone: user.caregiver_phone,
            created_at: user.created_at
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
    
    if (!email || !password || !name) {
      return res.status(400).json({
        success: false,
        message: '필수 정보가 누락되었습니다.'
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

// 환자 데이터 저장 API
app.post('/api/progress/:patientName', async (req, res) => {
  const { patientName } = req.params;
  const patientData = req.body;
  
  try {
    console.log(`환자 데이터 저장: ${patientName}`, patientData);
    
    const newPatientRecord = {
      patient_name: patientName,
      quiz_results: patientData.quizResults || [],
      medication_history: patientData.medicationHistory || [],
      mood_trend: patientData.moodTrend || [],
      cognitive_score: patientData.cognitiveScore || 0.0,
      recommendations: patientData.recommendations || [],
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    // Supabase에 환자 데이터 저장
    const { data, error } = await supabase
      .from('patient_records')
      .upsert(newPatientRecord, { 
        onConflict: 'patient_name',
        ignoreDuplicates: false 
      })
      .select()
      .single();
    
    if (error) {
      console.error('Supabase 저장 오류:', error);
      return res.status(500).json({
        success: false,
        message: '데이터 저장 중 오류가 발생했습니다.',
        error: error.message
      });
    }
    
    console.log('환자 데이터 저장 성공:', data);
    
    res.json({
      success: true,
      message: '환자 데이터가 성공적으로 저장되었습니다.',
      data: data
    });
  } catch (error) {
    console.error('환자 데이터 저장 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 환자 진행상황 데이터 조회 API
app.get('/api/progress/:patientName', async (req, res) => {
  const { patientName } = req.params;
  
  try {
    console.log(`진행상황 조회: ${patientName}`);
    
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
      data: {
        quizResults: data.quiz_results || [],
        medicationCompliance: data.medication_history ? data.medication_history.length : 0,
        moodTrend: data.mood_trend || [],
        cognitiveScore: data.cognitive_score || 0,
        recommendations: data.recommendations || []
      }
    });
  } catch (error) {
    console.error('진행상황 조회 오류:', error);
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

// 약물 복용 기록 저장 API (기존)
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
    
    res.json({
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

// 약물 복용 기록 저장 API (Flutter 앱용)
app.post('/api/medication-logs', async (req, res) => {
  try {
    const { patientName, time, takenAt } = req.body;
    
    console.log('약물 복용 기록 저장 시도 (Flutter):', { patientName, time, takenAt });
    
    // 현재 날짜 가져오기
    const today = new Date().toISOString().substring(0, 10);
    
    // 한국어 시간을 영어로 변환
    let timeKey = '';
    if (time === '아침' || time === 'morning') {
      timeKey = 'morning';
    } else if (time === '점심' || time === 'lunch') {
      timeKey = 'lunch';
    } else if (time === '저녁' || time === 'evening') {
      timeKey = 'evening';
    }
    
    console.log('변환된 시간 키:', timeKey);
    
    // 먼저 기존 환자 기록이 있는지 확인
    const { data: existingRecord, error: checkError } = await supabase
      .from('patient_records')
      .select('*')
      .eq('patient_name', patientName)
      .single();
    
    if (checkError && checkError.code !== 'PGRST116') {
      console.error('기존 기록 확인 오류:', checkError);
      return res.status(500).json({
        success: false,
        message: '기존 기록 확인 중 오류가 발생했습니다.'
      });
    }
    
    if (existingRecord) {
      // 기존 기록이 있는 경우, medication_history 업데이트
      const medicationHistory = existingRecord.medication_history || [];
      
      // 오늘 날짜의 기록 찾기
      let todayRecord = medicationHistory.find(record => record.date === today);
      
      if (todayRecord) {
        // 오늘 기록이 있으면 해당 시간 업데이트
        todayRecord[timeKey] = true;
      } else {
        // 오늘 기록이 없으면 새로 생성
        todayRecord = {
          date: today,
          morning: timeKey === 'morning',
          lunch: timeKey === 'lunch',
          evening: timeKey === 'evening'
        };
        medicationHistory.push(todayRecord);
      }
      
      // patient_records 테이블 업데이트
      const { data: updateData, error: updateError } = await supabase
        .from('patient_records')
        .update({
          medication_history: medicationHistory,
          updated_at: new Date().toISOString()
        })
        .eq('patient_name', patientName);
      
      if (updateError) {
        console.error('환자 기록 업데이트 오류:', updateError);
        return res.status(500).json({
          success: false,
          message: '환자 기록 업데이트 중 오류가 발생했습니다.'
        });
      }
      
      console.log('환자 기록 업데이트 성공:', updateData);
      
      res.status(201).json({
        success: true,
        message: '약물 복용 기록이 저장되었습니다.',
        data: updateData
      });
    } else {
      // 기존 기록이 없는 경우 새로 생성
      const newRecord = {
        patient_name: patientName,
        medication_history: [{
          date: today,
          morning: timeKey === 'morning',
          lunch: timeKey === 'lunch',
          evening: timeKey === 'evening'
        }],
        quiz_results: [],
        mood_trend: [],
        cognitive_score: 0,
        recommendations: ['첫 약물 복용 기록을 시작했습니다'],
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };
      
      const { data: insertData, error: insertError } = await supabase
        .from('patient_records')
        .insert(newRecord);
      
      if (insertError) {
        console.error('새 환자 기록 생성 오류:', insertError);
        return res.status(500).json({
          success: false,
          message: '새 환자 기록 생성 중 오류가 발생했습니다.'
        });
      }
      
      console.log('새 환자 기록 생성 성공:', insertData);
      
      res.status(201).json({
        success: true,
        message: '약물 복용 기록이 저장되었습니다.',
        data: insertData
      });
    }
  } catch (error) {
    console.error('약물 복용 기록 저장 오류 (Flutter):', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 약물 복용 상태 조회 API
app.get('/api/medication-status/:patientName/:date', async (req, res) => {
  try {
    const { patientName, date } = req.params;
    
    console.log('약물 복용 상태 조회:', { patientName, date });
    
    // Supabase에서 환자 기록 조회
    const { data, error } = await supabase
      .from('patient_records')
      .select('medication_history')
      .eq('patient_name', patientName)
      .single();
    
    if (error) {
      if (error.code === 'PGRST116') {
        // 데이터가 없는 경우
        return res.json({
          success: true,
          data: {
            morning: false,
            lunch: false,
            evening: false
          }
        });
      }
      console.error('Supabase 오류:', error);
      return res.status(500).json({
        success: false,
        message: '데이터 조회 중 오류가 발생했습니다.'
      });
    }
    
    // 해당 날짜의 약물 복용 기록 찾기
    const medicationHistory = data.medication_history || [];
    const todayRecord = medicationHistory.find(record => record.date === date);
    
    if (todayRecord) {
      console.log('약물 복용 상태 조회 성공:', todayRecord);
      
      res.json({
        success: true,
        data: {
          morning: todayRecord.morning || false,
          lunch: todayRecord.lunch || false,
          evening: todayRecord.evening || false
        }
      });
    } else {
      // 해당 날짜 기록이 없는 경우
      res.json({
        success: true,
        data: {
          morning: false,
          lunch: false,
          evening: false
        }
      });
    }
  } catch (error) {
    console.error('약물 복용 상태 조회 오류:', error);
    res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
});

// 테스트용 사용자 데이터 추가 API
app.post('/api/test/setup-user', async (req, res) => {
  try {
    const testUser = {
      id: '66207360-dd77-4055-8ad0-42867f2236dc',
      email: 'fdsa2258@naver.com',
      password: '197413',
      name: '최명일',
      role: 'patient',
      patient_phone: '010-3717-4019',
      caregiver_phone: '010-2258-4019',
      caregiver_password: '197413',
      created_at: '2025-08-12T16:13:29.290886'
    };
    
    // Supabase에 테스트 사용자 추가
    const { data, error } = await supabase
      .from('users')
      .upsert(testUser, {
        onConflict: 'id'
      })
      .select()
      .single();
    
    if (error) {
      console.error('테스트 사용자 추가 오류:', error);
      return res.status(500).json({
        success: false,
        message: '테스트 사용자 추가에 실패했습니다.',
        error: error.message
      });
    }
    
    console.log('테스트 사용자 추가 성공:', data);
    
    res.json({
      success: true,
      message: '테스트 사용자가 성공적으로 추가되었습니다.',
      data: data
    });
  } catch (error) {
    console.error('테스트 사용자 추가 오류:', error);
    res.status(500).json({
      success: false,
      message: '테스트 사용자 추가에 실패했습니다.',
      error: error.message
    });
  }
});

// 서버 시작
app.listen(PORT, () => {
  console.log(`🚀 서버가 포트 ${PORT}에서 실행 중입니다.`);
  console.log(`📱 API 문서: http://localhost:${PORT}`);
  console.log(`🔐 인증 엔드포인트: http://localhost:${PORT}/api/auth`);
  console.log(`🧪 테스트 사용자 설정: POST http://localhost:${PORT}/api/test/setup-user`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM 신호를 받았습니다. 서버를 종료합니다...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT 신호를 받았습니다. 서버를 종료합니다...');
  process.exit(0);
});
