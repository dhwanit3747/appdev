const fs = require('fs');
const path = require('path');
const svg = fs.readFileSync(path.join(__dirname, 'timeline.svg'), 'utf16le');
const regex = new RegExp('>[^<>]+<','g');
const names = new Set();
for (const m of svg.match(regex) || []) {
  const t = m.slice(1, -1).trim();
  if (!t) continue;
  if (/^[0-9-]+$/.test(t)) continue;
  if (/https?:\/\//.test(t)) continue;
  if (/©|Original source|Published under|Version |Linux Distributions Timeline/.test(t)) continue;
  if (t.length > 40) continue;
  names.add(t);
}
const data = JSON.parse(fs.readFileSync(path.join(__dirname, 'assets', 'data', 'distros.json'), 'utf8'));
const existing = new Set(data.map(d => d.name));
const missing = [...names].filter(n => !existing.has(n)).sort((a,b)=>a.localeCompare(b,'en',{sensitivity:'base'}));
console.log('unique', names.size, 'missing', missing.length);
console.log(missing.slice(0,40).join('\n'));
fs.writeFileSync(path.join(__dirname, 'timeline_missing.txt'), missing.join('\n'), 'utf8');
