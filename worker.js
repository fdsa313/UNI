// worker.js
const { Worker } = require('bullmq');
const IORedis = require('ioredis');
const admin = require('firebase-admin');

admin.initializeApp({ /* serviceAccount */ });
// const connection = new IORedis(process.env.REDIS_URL || 'redis://127.0.0.1:6379');
const connection = new IORedis(process.env.REDIS_URL || 'redis://127.0.0.1:6379', {
  maxRetriesPerRequest: null
});

new Worker(
  'notify',
  async job => {
    if (job.name !== 'sendNotification') return;



    // --- MOCK: DB에서 가져온 것처럼 직접 값 할당 ---
    // const notif = {
    //   id: job.data.notificationId,
    //   sent: false,
    //   userId: 'test-user',
    //   title: '테스트 알림',
    //   body: '이것은 테스트 메시지입니다.',
    //   deepLink: 'app://test'
    // };
    
    // --- MOCK: 토큰도 직접 할당 ---
    // const tokens = ['test-token-1', 'test-token-2'];

    // DB: const notif = await db.getNotification(job.data.notificationId);
    if (!notif || notif.sent) return;

    // DB: const tokens = await db.getActiveTokensByUserId(notif.userId);
    if (!tokens.length) return;

    // const payload = {
    //   notification: { title: notif.title, body: notif.body },
    //   data: { deepLink: notif.deepLink || '' },
    //   tokens
    // };

    
    // console.log('FCM에 보낼 payload:', payload);
    
    const res = await admin.messaging().sendEachForMulticast(payload);
    // DB: await db.handleFcmResults(tokens, res);
    // DB: await db.markNotificationSent(notif.id);
  },
  {
    connection,
    concurrency: 5,
    // 선택: 아주 긴 작업이 없다면 기본값(30s) 유지
    // lockDuration: 30000
  }
);



