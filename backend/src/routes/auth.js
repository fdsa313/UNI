const express = require('express');
const AuthController = require('../controllers/authController');
const { authMiddleware, requireRole } = require('../middleware/auth');

const router = express.Router();

// 회원가입
router.post('/register', AuthController.register);

// 로그인
router.post('/login', AuthController.login);

// 로그아웃
router.post('/logout', authMiddleware, AuthController.logout);

// 현재 사용자 정보 조회
router.get('/me', authMiddleware, AuthController.getCurrentUser);

// 환자만 접근 가능한 엔드포인트 예시
router.get('/patient-only', authMiddleware, requireRole(['patient']), (req, res) => {
  res.json({
    success: true,
    message: '환자 전용 페이지입니다.',
    data: { user: req.user }
  });
});

// 보호자만 접근 가능한 엔드포인트 예시
router.get('/caregiver-only', authMiddleware, requireRole(['caregiver']), (req, res) => {
  res.json({
    success: true,
    message: '보호자 전용 페이지입니다.',
    data: { user: req.user }
  });
});

module.exports = router;
