// queue.js
const { Queue } = require('bullmq');
const IORedis = require('ioredis');

const connection = new IORedis(process.env.REDIS_URL || 'redis://127.0.0.1:6379');

// NOTE: v2+ 에서는 QueueScheduler 불필요
const notifyQueue = new Queue('notify', {
  connection,
  // 선택: 기본 잡 옵션(완료 시 자동 삭제 등)
  defaultJobOptions: {
    removeOnComplete: true,
    removeOnFail: false
  }
});


module.exports = { notifyQueue };
