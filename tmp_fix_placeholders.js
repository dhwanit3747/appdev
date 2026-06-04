const fs = require('fs');
const path = require('path');
const dataPath = path.join('assets','data','distros.json');
const backupPath = dataPath + '.bak3.' + Date.now();
if (!fs.existsSync(dataPath)) {
  console.error('distros.json not found at', dataPath);
  process.exit(1);
}
const raw = fs.readFileSync(dataPath,'utf8');
fs.writeFileSync(backupPath, raw, 'utf8');
const list = JSON.parse(raw);
let fixed = 0;
for (const entry of list) {
  if (typeof entry.description === 'string' && entry.description.includes('Placeholder entry imported from timeline')) {
    entry.description = `A Linux distribution imported from the timeline: ${entry.name}.`;
    entry.long_description = `This distro was imported from the Linux distribution timeline. Detailed release metadata is not available yet, but this entry has been structured to match the rest of the app.`;
    entry.website = entry.website || "";
    entry.download = entry.download || "";
    entry.iso_size = entry.iso_size === null || entry.iso_size === undefined ? 2.0 : entry.iso_size;
    entry.base = entry.base || "Independent";
    entry.family = entry.family || "independent";
    entry.logo = entry.logo || "";
    entry.first_release = entry.first_release || "Unknown";
    entry.latest_version = entry.latest_version || "Unknown";
    entry.package_manager = entry.package_manager || "Unknown";
    entry.default_desktop = entry.default_desktop || "Unknown";
    entry.available_desktops = Array.isArray(entry.available_desktops) ? entry.available_desktops : [];
    entry.release_model = entry.release_model || "Unknown";
    entry.target_audience = Array.isArray(entry.target_audience) && entry.target_audience.length ? entry.target_audience : ["Desktop"];
    entry.use_cases = Array.isArray(entry.use_cases) && entry.use_cases.length ? entry.use_cases : ["Desktop"];
    entry.init_system = entry.init_system || "Unknown";
    entry.pros = Array.isArray(entry.pros) && entry.pros.length ? entry.pros : ["Imported from timeline"];
    entry.cons = Array.isArray(entry.cons) && entry.cons.length ? entry.cons : ["Detailed metadata not yet available"];
    entry.popularity_rank = entry.popularity_rank === null || entry.popularity_rank === undefined ? 50 : entry.popularity_rank;
    if (!entry.color || entry.color === "#CCCCCC") {
      entry.color = "#999999";
    }
    fixed++;
  }
}
fs.writeFileSync(dataPath, JSON.stringify(list, null, 2), 'utf8');
console.log(`Fixed ${fixed} placeholder entries. Backup saved as ${backupPath}`);
