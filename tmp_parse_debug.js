const fs = require('fs');
const path = require('path');
const svg = fs.readFileSync(path.join(__dirname, 'timeline.svg'), 'utf8');
const regex = new RegExp('>([^<>]+)<','g');
const items=[];
for(const m of svg.match(regex) || []){
  const t = m.slice(1,-1);
  items.push(JSON.stringify(t));
}
fs.writeFileSync(path.join(__dirname,'debug_items.txt'), items.join('\n'),'utf8');
console.log('wrote debug_items.txt', items.length);
