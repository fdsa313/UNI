// index.js
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const path = require('path');


// 퀴즈
// 퀴즈 문제, 정답 주기
app.get('/quizzes/answers/:quizId', (req, res) => {
  const quizId = req.params.quizId;
  // DB: const quiz = db.getQuiz(quizId); 
  res.status(200).json({quiz: quiz});
});
// 퀴즈 POST
app.post('/quizzes/answers', (req, res) => {
  const quizId = Date.now();
  const imgFile = req.body.imgFile;
  const answer = req.body.answer;
  const quiz = {
    quizId,
    imgFile,
    answer
  };
  // DB: db.saveQuiz(quiz);
});
// 퀴즈 DELETE
app.delete('/quizzes/answers/:quizId', (req, res) => {
  // DB: db.deletequiz(req.params.quizId);
  res.status(200).json({message: "잘 삭제됨"})
});
// 

// 로그인
app.post('/login', (req, res) => {
  const id = req.body.id;
  const pw = req.body.pw;
  const user = storage.getUsersById(id);
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
const SECRET_KEY = 'secret_key';
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


app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});







