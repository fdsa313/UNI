const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const supabase = require('../config/supabase');

class AuthController {
  // 회원가입
  static async register(req, res) {
    try {
      const { email, password, name, role, phone } = req.body;

      // 필수 필드 검증
      if (!email || !password || !name || !role) {
        return res.status(400).json({
          success: false,
          message: '이메일, 비밀번호, 이름, 역할은 필수입니다.'
        });
      }

      // 역할 검증
      if (!['patient', 'caregiver'].includes(role)) {
        return res.status(400).json({
          success: false,
          message: '역할은 patient 또는 caregiver여야 합니다.'
        });
      }

      // 이메일 중복 확인
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: '이미 존재하는 이메일입니다.'
        });
      }

      // 비밀번호 해시화
      const hashedPassword = await bcrypt.hash(password, 12);

      // Supabase Auth로 사용자 생성
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            name,
            role,
            phone
          }
        }
      });

      if (authError) {
        return res.status(400).json({
          success: false,
          message: authError.message
        });
      }

      // 사용자 정보를 데이터베이스에 저장
      const userData = {
        id: authData.user.id,
        email,
        name,
        role,
        phone,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      const user = await User.create(userData);

      // JWT 토큰 생성
      const token = jwt.sign(
        { userId: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '7d' }
      );

      res.status(201).json({
        success: true,
        message: '회원가입이 완료되었습니다.',
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            phone: user.phone
          },
          token
        }
      });

    } catch (error) {
      console.error('회원가입 오류:', error);
      res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.'
      });
    }
  }

  // 로그인
  static async login(req, res) {
    try {
      const { email, password } = req.body;

      // 필수 필드 검증
      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: '이메일과 비밀번호는 필수입니다.'
        });
      }

      // Supabase Auth로 로그인
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password
      });

      if (authError) {
        console.error('Supabase Auth 오류:', authError);
        return res.status(401).json({
          success: false,
          message: '이메일 또는 비밀번호가 올바르지 않습니다.'
        });
      }

      console.log('Supabase Auth 성공:', authData.user.id);

      // 사용자 정보 조회
      const user = await User.findById(authData.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: '사용자를 찾을 수 없습니다.'
        });
      }

      // JWT 토큰 생성
      const token = jwt.sign(
        { userId: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '7d' }
      );

      res.json({
        success: true,
        message: '로그인이 완료되었습니다.',
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            phone: user.phone
          },
          token,
          supabaseSession: {
            accessToken: authData.session.access_token,
            refreshToken: authData.session.refresh_token,
            userId: authData.user.id
          }
        }
      });

    } catch (error) {
      console.error('로그인 오류:', error);
      res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.'
      });
    }
  }

  // 로그아웃
  static async logout(req, res) {
    try {
      const { error } = await supabase.auth.signOut();
      
      if (error) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      res.json({
        success: true,
        message: '로그아웃이 완료되었습니다.'
      });

    } catch (error) {
      console.error('로그아웃 오류:', error);
      res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.'
      });
    }
  }

  // 현재 사용자 정보 조회
  static async getCurrentUser(req, res) {
    try {
      const userId = req.user.userId;
      const user = await User.findById(userId);

      if (!user) {
        return res.status(404).json({
          success: false,
          message: '사용자를 찾을 수 없습니다.'
        });
      }

      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            phone: user.phone
          }
        }
      });

    } catch (error) {
      console.error('사용자 정보 조회 오류:', error);
      res.status(500).json({
        success: false,
        message: '서버 오류가 발생했습니다.'
      });
    }
  }
}

module.exports = AuthController;
