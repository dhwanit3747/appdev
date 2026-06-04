const fs = require('fs');
const path = require('path');
const dataPath = path.join('assets','data','distros.json');
const backupPath = dataPath + '.bak.' + Date.now();
const cleaned = 'cleaned_missing.txt';
const limit = parseInt(process.argv[2]||'200',10);
if (!fs.existsSync(dataPath)) { console.error('distros.json not found at', dataPath); process.exit(2); }
if (!fs.existsSync(cleaned)) { console.error('cleaned file not found:', cleaned); process.exit(2); }
const orig = fs.readFileSync(dataPath,'utf8');
fs.writeFileSync(backupPath, orig, 'utf8');
console.log('backup written to', backupPath);
let arr;
try { arr = JSON.parse(orig); } catch(e){ console.error('Failed to parse distros.json:', e.message); process.exit(2); }
const existingNames = new Set(arr.map(x=> (x.name||'').toLowerCase()));
const lines = fs.readFileSync(cleaned,'utf8').split(/\r?\n/).map(s=>s.trim()).filter(Boolean);
let added = 0;
for (let i=0;i<lines.length && added<limit;i++){
  const name = lines[i];
  if (existingNames.has(name.toLowerCase())) continue;
  const obj = {
    name: name,
    description: "Placeholder entry imported from timeline",
    long_description: "",
    website: "",
    download: "",
    iso_size: null,
    base: "",
    family: "",
    logo: "",
    first_release: "",
    latest_version: "",
    package_manager: "",
    default_desktop: "",
    available_desktops: [],
    release_model: "",
    target_audience: [],
    use_cases: [],
    init_system: "",
    pros: [],
    cons: [],
    popularity_rank: null,
    color: "#CCCCCC"
  };
  arr.push(obj);
  existingNames.add(name.toLowerCase());
  added++;
}
fs.writeFileSync(dataPath, JSON.stringify(arr, null, 2), 'utf8');
console.log('appended', added, 'entries to', dataPath);
