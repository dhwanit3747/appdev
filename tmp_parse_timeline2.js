const fs = require('fs');
const path = require('path');
const svg = fs.readFileSync(path.join(__dirname, 'timeline.svg'), 'utf16le');
const textRegex = /<text[^>]*>([\s\S]*?)<\/text>/gi;
const names = new Set();
let m;
while ((m = textRegex.exec(svg)) !== null) {
  let text = m[1];
  text = text.replace(/<tspan[^>]*>/gi, '');
  text = text.replace(/<[^>]+>/g, '');
  text = text.replace(/&amp;/g, '&').trim();
  if (!text) continue;
  if (/^[0-9\-\s]+$/.test(text)) continue;
  if (/https?:\/\//.test(text)) continue;
  if (/©|Original source|Published under|Version|Linux Distributions Timeline/.test(text)) continue;
  if (text.length > 40) continue;
  names.add(text);
}
const data = JSON.parse(fs.readFileSync(path.join(__dirname, 'assets', 'data', 'distros.json'), 'utf8'));
const existing = new Set(data.map(d => d.name));
const missing = [...names].filter(n => !existing.has(n)).sort((a,b)=>a.localeCompare(b,'en',{sensitivity:'base'}));
console.log('unique', names.size, 'missing', missing.length);
console.log(missing.slice(0,80).join('\n'));
fs.writeFileSync(path.join(__dirname, 'timeline_missing.txt'), missing.join('\n'), 'utf8');
