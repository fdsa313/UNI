// 
function nowKstString() {
  const kst = new Date(Date.now() + 9 * 60 * 60 * 1000);
  const two = (n) => String(n).padStart(2, '0');
  const y = kst.getUTCFullYear();
  const m = two(kst.getUTCMonth() + 1);
  const d = two(kst.getUTCDate());
  const h = two(kst.getUTCHours());
  const mi = two(kst.getUTCMinutes());
  const s = two(kst.getUTCSeconds());
  return `${y}-${m}-${d} ${h}:${mi}:${s}`;
}
// console.log(`Current KST time: ${nowKstString()}`);

// console.log(Date().toISOString());

const now = new Date();
console.log(now.toISOString());
// 예: "2025-08-10T06:20:54.123Z"
