// worker.js
const { Worker } = require('bullmq');
const IORedis = require('ioredis');
const admin = require('firebase-admin');

admin.initializeApp({ /* serviceAccount */ });

const connection = new IORedis(process.env.REDIS_URL || 'redis://127.0.0.1:6379', {
  maxRetriesPerRequest: null,
});

/** "YYYY-MM-DD HH:mm:ss" (KST) -> UTC ms */
function parseKstToUtcMs(kstString) {
  const m = /^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2}):(\d{2})$/.exec(kstString);
  if (!m) throw new Error('invalid KST datetime format');
  const [_, yy, MM, dd, hh, mm, ss] = m.map(Number);
  return Date.UTC(yy, MM - 1, dd, hh - 9, mm, ss);
}

/** 지금 KST Date 객체 (UTC now + 9h) */
function nowKstDate() {
  return new Date(Date.now() + 9 * 60 * 60 * 1000);
}

/** UTC ISO -> KST "YYYY-MM-DD HH:mm:ss" (디버깅용) */
function formatUtcAsKst(isoOrDate) {
  const d = typeof isoOrDate === 'string' ? new Date(isoOrDate) : isoOrDate; // UTC 기준
  const kst = new Date(d.getTime() + 9 * 60 * 60 * 1000);
  const two = (n) => String(n).padStart(2, '0');
  const y = kst.getUTCFullYear();
  const m = two(kst.getUTCMonth() + 1);
  const day = two(kst.getUTCDate());
  const h = two(kst.getUTCHours());
  const mi = two(kst.getUTCMinutes());
  const s = two(kst.getUTCSeconds());
  return `${y}-${m}-${day} ${h}:${mi}:${s}`;
}

new Worker(
  'notify',
  async (job) => {
    if (job.name !== 'sendNotification') return;

    const { notificationId } = job.data;
    if (!notificationId) return;

    // DB에서 알림/토큰 조회 (여기선 목업)
    // const notif = await db.getNotification(notificationId);
    // const tokens = await db.getActiveTokensByUserId(notif.userId);
    const notif = {
      id: notificationId,
      userId: 'test-user',
      title: '테스트 알림',
      body: '이것은 테스트 메시지입니다.',
      deepLink: 'app://test',
      sent: false,
      sendAt: '2025-08-10 15:20:54', // KST 문자열(예시)
    };
    const tokens = ['test-token-1', 'test-token-2'];

    if (!notif || notif.sent) return;
    if (!Array.isArray(tokens) || tokens.length === 0) return;

    // (안전장치) 워커가 실행되었을 때도 KST 기준 시간 검증
    try {
      const targetUtcMs = parseKstToUtcMs(notif.sendAt);
      const nowUtcMs = Date.now();
      if (nowUtcMs + 2_000 < targetUtcMs) {
        // 아직 시간이 안 됐다면 (시계 스큐 등) 재지정(선택)
        const delay = Math.max(0, targetUtcMs - nowUtcMs);
        await job.updateProgress({ rescheduledDelayMs: delay });
        await job.moveToDelayed(Date.now() + delay);
        return;
      }
    } catch (e) {
      console.error('[Worker] invalid sendAt format in DB:', notif.sendAt, e);
      return;
    }

    const payload = {
      notification: { title: notif.title, body: notif.body },
      data: { deepLink: notif.deepLink || '' },
      tokens,
    };

    // console.log('[Worker] sending KST:', notif.sendAt);
    // console.log('[Worker] sending UTC:', formatUtcAsKst(new Date().toISOString()));

    const res = await admin.messaging().sendEachForMulticast(payload);

    // 결과 처리 & sent=true 마킹
    // await db.handleFcmResults(tokens, res);
    // await db.markNotificationSent(notif.id);
  },
  {
    connection,
    concurrency: 5,
    // lockDuration: 30000
  }
);
