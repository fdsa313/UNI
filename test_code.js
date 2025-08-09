// CJS
const { ulid, monotonicFactory } = require('ulid');

const id1 = ulid();                 // 일반 ULID
const nextULID = monotonicFactory(); // 같은 ms 내에서도 정렬 보장
const id2 = nextULID();

console.log('vid_' + id1);
// console.log('qz_' + id2);
console.log('vid_' + id1);
console.log(typeof('vid_' + id1));