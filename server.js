const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const path = require('path');
const  { notifyQueue } = require('./queue.js');
const SECRET_KEY = 'secret_key';
const jwt = require('jsonwebtoken');

// CJS
const { ulid, monotonicFactory } = require('ulid');

app.use(express.json());

// 퀴즈
// 퀴즈 문제, 정답 주기
app.get('/quizzes/:quizId', (req, res) => { // TODO: 이쪽은 고민 중
  const quizId = req.params.quizId;
  // DB: const quiz = db.getQuiz(quizId); 
  res.status(200).json({quiz: quiz});
});
// 퀴즈 객체 배열 주기
app.get('/quizzes', verifyToken, (req, res) => {
  // DB: const quizzes = db.getAllQuizzes(req.user.userId);
  res.status(200).json({quizzes: quizzes});
});
// 퀴즈 POST
app.post('/quizzes', verifyToken, (req, res) => {
  const quizId = getQuizId();
  const imgFile = req.body.imgFile;
  const answer = req.body.answer;
  const quiz = {
    userId: req.user.userId,
    quizId,
    imgFile,
    answer
  };
  // DB: db.saveQuiz(quiz);
  res.status(201).json({message: "잘 추가됨", quiz});
});
// 퀴즈 DELETE
app.delete('/quizzes/:quizId', (req, res) => {
  // DB: db.deletequiz(req.params.quizId);
  res.status(200).json({message: "잘 삭제됨"})
});


// 푸쉬토큰 등록
app.post('/register-token', verifyToken, async (req, res) => {
  const userId = req.user.userId; // 인증된 사용자 ID
  const { token, platform, timezone } = req.body;
//   DB: await db.upsertDeviceToken({ userId, token, platform, timezone });
  res.status(200).json({ success: true, message: '토큰이 등록되었습니다.' });
});

// 알림 DB에 저장하는 코드
app.post('/reminders', async (req, res) => {
  const { userId, title, body, sendAt /* ISO(UTC) */ } = req.body;
  // DB: const notif = await db.createNotification({ userId, title, body, sendAt });

  const jobId = `notif:${notif.id}`;                     // 멱등 키
  const delay = Math.max(0, new Date(sendAt).getTime() - Date.now());

  await notifyQueue.add(
    'sendNotification',
    { notificationId: notif.id },
    {
      jobId,
      delay,
      attempts: 5,
      backoff: { type: 'exponential', delay: 30000 },
      removeOnComplete: true,
      removeOnFail: false
    }
  );

  res.json({ id: notif.id });
});
// 알림 수정하는 코드
app.patch('/reminders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, body, sendAt } = req.body;

    // DB:  const old = await db.getNotification(id);
    if (!old) return res.status(404).json({ error: 'not found' });
    if (old.sent) return res.status(409).json({ error: 'already sent' });

    const update = {};
    if (typeof title === 'string') update.title = title;
    if (typeof body === 'string') update.body = body;

    let newSendAt = old.sendAt;
    if (typeof sendAt === 'string') {
      const t = new Date(sendAt);
      if (isNaN(t.getTime())) return res.status(400).json({ error: 'invalid sendAt' });
      if (t.getTime() <= Date.now()) return res.status(400).json({ error: 'sendAt must be future' });
      update.sendAt = t.toISOString();
      newSendAt = update.sendAt;
    }

    // DB: const notif = await db.updateNotification(id, update);

    // 큐에서 기존 예약 잡 제거
    const jobId = `notif:${id}`;
    const oldJob = await notifyQueue.getJob(jobId);
    if (oldJob) await oldJob.remove();                   // ← 올바른 제거 방식

    // 새 예약 잡 추가
    const delay = Math.max(0, new Date(newSendAt).getTime() - Date.now());
    await notifyQueue.add(
      'sendNotification',
      { notificationId: id },
      {
        jobId,
        delay,
        attempts: 5,
        backoff: { type: 'exponential', delay: 30000 },
        removeOnComplete: true,
        removeOnFail: false
      }
    );

    res.json({
      id: notif.id,
      title: notif.title,
      body: notif.body,
      sendAt: notif.sendAt
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'internal' });
  }
});
// 알림 삭제하는 코드
app.delete('/reminders/:id', async (req, res) => {
  const { id } = req.params;
  // DB: db.deleteNotification(id);
  const jobId = `notif:${id}`;
  const job = await notifyQueue.getJob(jobId);
  if (job) await job.remove();

  res.status(200).json({ success: true, message: '알림이 삭제되었습니다.' });
});


// QUIZ
app.get('/quizzes', (req, res) => {
  const quizzes = []; // DB: db.getAllQuizzes();
  res.status(200).json({ quizzes });
});
app.post('/quizzes', (req, res) => {
  const { imgFile, answer } = req.body;
  const quizID = getQuizId;
  const quiz = { quizID, imgFile, answer };
  // DB: db.addQuiz(quiz);
  res.status(201).json({ success: true, message: '퀴즈가 추가되었습니다.', quiz });
});
app.delete('/quizzes/:quizId', (req, res) => {
  // DB: db.deleteQuiz(req.params.quizId);
  res.status(200).json({ success: true, message: '퀴즈가 삭제되었습니다.' });
});


// 영상
app.get('/videos', verifyToken, (req, res) => {
  const videos = []; // DB: db.getAllVideos(userId);
  res.status(200).json({ videos });
});
app.post('/videos', verifyToken, (req, res) => {
  const userId = req.user.userId; // 인증된 사용자 ID
  const video = {
    userId,
    videoId: getVideoId(), 
    title: req.body.title,
    url: req.body.url,
  }
});

// 로그인
app.post('/login', (req, res) => {
  const id = req.body.id;
  const pw = req.body.pw;
  // DB: const user = db.getUsersById(id);
  // id에 해당하는 user가 없거나, 비번이 틀리거나
  if(!user || pw != user.userPw) {
    return res.status(401).json({sucess: false, message: "아이디 또는 비밀번호가 잘못 되었습니다.\n아이디와 비밀번호를 정확히 입력해 주세요."});
  }
  // 성공 시, jwt줌
  // 자동으로 헤더 넣어주고, userId로 페이로드 만들어주고, 서명까지 써줌
  const token = jwt.sign(
    { userId: user.userId },
      SECRET_KEY,
    { expiresIn: '1h' } // 1시간 유효
  );

  res.status(200).json({ success: true, token, id: id });
});


// ==============회원가입============== 
app.post('/signup', (req, res) => {
  const {signupId, signupPw} = req.body;

  // 신규 등록자
  if(!storage.getUsersById(signupId)) { // DB: db.getUserById(userId)
      const user = {
        userId: signupId,
        userPw: signupPw
      };
      storage.addUser(user); // DB: db.addUser(user);
      res.status(200).json({success: true, message:"회원가입 완료"});
  }
  else {
      // 기존 유저
      res.status(400).json({success: false, message: "이미 가입된 계정입니다. 로그인을 진행해 주세요!"});
  }
});
// ME
app.get('/me',verifyToken, (req, res) => {
  // 인증 됐다면 userId 들어있는 페이로드 넘겨주기
  res.status(200).json(req.user);
});

// VERIFY
function verifyToken(req, res, next) {
  // 알아서 라우터 쪽의 req에 user정보 넣어줌
  const authHeader = req.headers.authorization;
  const token = authHeader.split(' ')[1];
  try{
    const decoded = jwt.verify(token, SECRET_KEY);
    req.user = decoded;
    next();
  } catch(err) {
    // NOTE: 토큰에 문제가 있거나 토큰 자체가 없는 상황에 따라 에러 코드 세분화 핗요
    return res.status(401).json({message:"유효하지 않은 토큰"});
  }
}


// ID 생성 함수
function getVideoId() {
  return 'vid_' + ulid();
}
function getQuizId() {
  return 'qz_' + ulid();
}



app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});


