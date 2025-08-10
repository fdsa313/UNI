// worker.js
const { Worker } = require('bullmq');
const IORedis = require('ioredis');
const admin = require('firebase-admin');

admin.initializeApp({ /* serviceAccount */ });

const connection = new IORedis(process.env.REDIS_URL || 'redis://127.0.0.1:6379', {
  maxRetriesPerRequest: null,
});

// (선택) KST <-> UTC 포맷 유틸 (워커에선 딱히 필요는 없지만 디버깅용)
function formatUtcAsKst(isoOrDate) {
  const d = typeof isoOrDate === 'string' ? new Date(isoOrDate) : isoOrDate; // UTC
  const kst = new Date(d.getTime() + 9 * 60 * 60 * 1000);
  const two = (n) => String(n).padStart(2, '0');
  const y = kst.getUTCFullYear();
  const m = two(kst.getUTCMonth() + 1);
  const day = two(kst.getUTCDate());
  const h = two(kst.getUTCHours());
  const min = two(kst.getUTCMinutes());
  const s = two(kst.getUTCSeconds());
  return `${y}-${m}-${day} ${h}:${min}:${s}`;
}

new Worker(
  'notify',
  async (job) => {
    if (job.name !== 'sendNotification') return;

    const { notificationId } = job.data;
    if (!notificationId) return;

    // --- DB에서 알림/토큰 조회 (의사코드) ---
    // const notif = await db.getNotification(notificationId);
    // const tokens = await db.getActiveTokensByUserId(notif.userId);

    // 데모 목업 (실서비스에선 위 DB 코드로 교체)
    const notif = {
      notificationId: notificationId,
      sent: false,
      userId: 'test-user',
      title: '테스트 알림',
      body: '이것은 테스트 메시지입니다.',
      deepLink: 'app://test',
      sendAtUtc: new Date().toISOString(),
    };
    const tokens = ['test-token-1', 'test-token-2'];

    if (!notif || notif.sent) return;
    if (!Array.isArray(tokens) || tokens.length === 0) return;

    const payload = {
      notification: { title: notif.title, body: notif.body },
      data: { deepLink: notif.deepLink || '' },
      tokens,
    };

    // console.log('[Worker] send at (KST):', formatUtcAsKst(notif.sendAtUtc));
    const res = await admin.messaging().sendEachForMulticast(payload);

    // --- 전송 결과 처리 & sent 마킹 (의사코드) ---
    // await db.handleFcmResults(tokens, res);
    // await db.markNotificationSent(notif.id);
  },
  {
    connection,
    concurrency: 5,
    // lockDuration: 30000
  }
);
