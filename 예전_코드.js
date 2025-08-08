import dotenv from 'dotenv';
// const cors = require('cors');   // 상단에 추가
import cors from 'cors';

dotenv.config();

// const express = require('express');
import express from 'express';
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json()); // 이거도 꼭 있어야 함
app.use(cors());                // dotenv 아래에 추가

app.get('/', (req, res) => {
  res.send('서버 잘 돌아간다!');
});
// =====================
// const path = require('path');
import path from 'path';
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// const __dirname = path.dirname(fileURLToPath(import.meta.url));

// 🔥 이 줄이 HTML, JS, CSS 파일을 서빙해줌
app.use(express.static(path.join(__dirname, 'public')));

// =====================


// cloudinary 및 multer 설정
// const multer = require('multer');
// const { v2: cloudinary } = require('cloudinary');
// const { CloudinaryStorage } = require('multer-storage-cloudinary');
import multer from 'multer';
import { v2 as cloudinary } from 'cloudinary';
import { CloudinaryStorage } from 'multer-storage-cloudinary';


cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

const cloudinaryStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'blog_uploads', // Cloudinary에 저장될 폴더명
    allowed_formats: ['jpg', 'png', 'webp', 'gif'],
  },
});

const upload = multer({ storage: cloudinaryStorage });

// storage.js
// const storage = require('../../js/storage/storage');
// import * as storage from '../../js/storage/storage.js';
import * as storage from '../../`/blog/storage.js';


// ME
app.get('/me',verifyToken, (req, res) => {
  // 인증 됐다면 user_id, nickname 들어있는 페이로드 넘겨주기
  res.status(200).json(req.user);
});

// (이미지) 파일 url 반환
app.post('/upload', upload.single('image'), (req, res) => {
  res.json({ imageUrl: req.file.path});
});

// ==============게시물==============
// 게시물 등록
app.post('/posts', (req, res) => {
  const post = req.body;
  storage.addPost(post);
  res.json({ success: true, message: '포스트 등록 완료' });
});
// main에서 게시물들 불러오가
app.get('/posts', (req, res) => {
  const posts = storage.getPosts();
  res.json(posts);
});
// post에서 특정 게시물 불러오기
app.get('/posts/:post_id', (req, res) => {
  const post_id = req.params.post_id;
  const post = storage.getPostById(Number(req.params.post_id));
  res.status(200).json(post);
});
// 특정 게시물
app.put('/put', (req, res) => {
  console.log("---server.js_put: 일단 눌리긴 함");
  const post = req.body
  storage.editPost(post);
  res.status(200).json({success: true, message: "수정 완료!"});
});

// 게시물 삭제
app.delete('/posts/:post_id', (req, res) => {
  const post_id = req.params.post_id;
  storage.deletePost(Number(post_id));
  res.json({success: true, message: "삭제 성공!"});
});

// ==============댓글==============
app.get('/comments', (req, res) => {
  const {post_id} = req.query;
  const comments = storage.getCommentsByPostId(Number(post_id));
  res.json(comments);
});

app.post('/comments', (req, res) => {
  const comment = req.body;
  storage.addComment(comment);
  res.json({success: true, message: "댓글 등록 성공!"});
});

import jwt from 'jsonwebtoken';

// ==============로그인==============
app.post('/login', (req, res) => {
  const id = req.body.id;
  const pw = req.body.pw;
  const user = storage.getUsersById(id);
  // id에 해당하는 user가 없거나, 비번이 틀리거나
  if(!user || pw != user.user_pw) {
    return res.status(401).json({sucess: false, message: "아이디 또는 비밀번호가 잘못 되었습니다.\n아이디와 비밀번호를 정확히 입력해 주세요."});
  }
  // 성공 시, jwt줌
  // 자동으로 헤더 넣어주고, user_id로 페이로드 만들어주고, 서명까지 써줌
  const token = jwt.sign(
    { user_id: user.user_id,
      nickname: user.user_nickname
    },
      SECRET_KEY,
    { expiresIn: '1h' } // 1시간 유효
  );

  res.status(200).json({ success: true, token, id: id });
  
});
// ==============회원가입==============
app.post('/register', (req, res) => {
const {register_id, register_pw} = req.body;

// 신규 등록자
if(!storage.getUsersById(register_id)) {
    const user = {
    user_id: register_id,
    user_pw: register_pw,
    user_nickname: getRandomNickname(),
    // user_profile 희망사항 ㅇㅅㅇ
    }
    storage.addUser(user);
    res.status(200).json({success: true, message:"동물맨션 입소완료. 이제 안아주러 가봐요"});
}
else {
    // 기존 유저
    res.status(400).json({success: false, message: "🐣 이미 가입된 계정입니다. 로그인을 진행해 주세요!"});
}
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


// ======유틸들. 많아지면 따로 파일 뺄 거임 ㅇㅅㅇ=====
function getRandomNickname() {
  const adjectives = [
    '귀여운', '졸린', '신나는', '배고픈', '수줍은', '활기찬', '따뜻한', '엉뚱한', '기발한', '느긋한'
  ];

  const activities = [
    '산책가는', '캠핑가는', '운동가는', '출근하는', '소풍가는', '마트가는', '등교하는', '퇴근하는', '놀러가는', '야근하는'
  ];

  const nouns = [
    '고양이', '강아지', '라면', '솥', '베개', '포크', '우산', '장화', '토스트', '달걀', '커튼', '머그컵', '칫솔'
  ];

  const pick = arr => arr[Math.floor(Math.random() * arr.length)];

  return `${pick(activities)} ${pick(adjectives)} ${pick(nouns)}`;
}

// 서버 실행
app.listen(3000, () => {
  console.log('✅ 서버 실행 중 http://localhost:3000');
});