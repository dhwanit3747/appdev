const fs = require('fs');
const path = require('path');
const dataPath = path.join('assets','data','distros.json');
if (!fs.existsSync(dataPath)) {
  console.error('distros.json not found', dataPath);
  process.exit(1);
}
const raw = fs.readFileSync(dataPath, 'utf8');
const list = JSON.parse(raw);
const fixes = {
  'ngstrÃ¶m': 'Ångström',
  'Caixa MÃ¡gica': 'Caixa Mágica'
};
let changed = 0;
for (const entry of list) {
  if (entry.name in fixes) {
    entry.name = fixes[entry.name];
    entry.description = entry.description.replace('timeline: ' + Object.keys(fixes).find(k => k === entry.name), 'timeline: ' + fixes[entry.name]);
    changed++;
  }
}
if (changed) {
  fs.writeFileSync(dataPath, JSON.stringify(list, null, 2), 'utf8');
}
console.log('Fixed', changed, 'encoding artifact names.');
