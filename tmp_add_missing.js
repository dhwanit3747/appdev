const fs = require('fs');
const path = require('path');
const distrosPath = path.join(__dirname, 'assets', 'data', 'distros.json');
const missingPath = path.join(__dirname, 'timeline_missing.txt');
const data = JSON.parse(fs.readFileSync(distrosPath, 'utf8'));
const existing = new Set(data.map(d => d.name));
const missing = fs.readFileSync(missingPath, 'utf8').split(/\r?\n/).map(s => s.trim()).filter(s => s && s.length > 1 && !existing.has(s));
for (const name of missing) {
  data.push({
    name,
    description: `Placeholder entry for ${name}.`,
    long_description: `Placeholder distro record for ${name} from the Linux distribution timeline.`,
    website: "",
    download: "",
    iso_size: 0.0,
    base: "Independent",
    family: "independent",
    logo: "",
    first_release: "Unknown",
    latest_version: "Unknown",
    package_manager: "Unknown",
    default_desktop: "Unknown",
    available_desktops: [],
    release_model: "Unknown",
    target_audience: [],
    use_cases: [],
    init_system: "Unknown",
    pros: ["Placeholder data"],
    cons: ["Placeholder data"],
    popularity_rank: 999,
    color: "#7B3FE4"
  });
}
fs.writeFileSync(distrosPath, JSON.stringify(data, null, 2), 'utf8');
console.log('Added', missing.length, 'placeholder distro entries. Total now', data.length);
