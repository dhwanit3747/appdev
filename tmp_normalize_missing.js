const fs = require('fs');
const input = 'timeline_missing.txt';
const out = 'cleaned_missing.txt';
if (!fs.existsSync(input)) {
  console.error('Input file not found:', input);
  process.exit(2);
}
const data = fs.readFileSync(input, 'utf8');
const lines = data.split(/\r?\n/).map(s => s.trim()).filter(Boolean);
const names = lines.map(s => {
  s = s.replace(/^[\d\.\-_]+/, '').trim();
  s = s.replace(/[\u0000-\u001F\u007F]+/g, '').trim();
  s = s.replace(/^[^A-Za-z0-9ÅåÄäÖöÉéÈèÁáÎîÙùÔôÜüÝýČčŠšŽž]+|[^A-Za-z0-9ÅåÄäÖöÉéÈèÁáÎîÙùÔôÜüÝýČčŠšŽž]+$/g, '').trim();
  s = s.replace(/\s{2,}/g, ' ');
  return s;
}).filter(s => s && s.length > 1 && !/^\d{1,4}$/.test(s) && !/^\W+$/.test(s) && !/^(19|20)\d{2}$/.test(s) && !/^[\s\-–—]+$/.test(s));
const uniq = [];
const seen = new Set();
for (const n of names) {
  if (seen.has(n.toLowerCase())) continue;
  if (/^(linux|gnu|distribution|timeline|year|years|linuxdistribution|wikipedia)$/i.test(n)) continue;
  seen.add(n.toLowerCase());
  uniq.push(n);
}
fs.writeFileSync(out, uniq.join('\n'), 'utf8');
console.log('input', lines.length, 'normalized', names.length, 'unique', uniq.length);
console.log('wrote', out);
