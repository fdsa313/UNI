// Firebase 웹 설정
// 개발용 기본 설정
const firebaseConfig = {
  apiKey: "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  authDomain: "aunithon-dev.firebaseapp.com",
  projectId: "aunithon-dev",
  storageBucket: "aunithon-dev.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};

// Firebase 초기화
if (typeof firebase !== 'undefined') {
  firebase.initializeApp(firebaseConfig);
}
